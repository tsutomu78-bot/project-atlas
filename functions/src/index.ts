import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {initializeApp} from "firebase-admin/app";

initializeApp();

// Stored in Google Secret Manager, never in a file or the Flutter client.
// Set once via: firebase functions:secrets:set KROGER_CLIENT_ID
//               firebase functions:secrets:set KROGER_CLIENT_SECRET
const krogerClientId = defineSecret("KROGER_CLIENT_ID");
const krogerClientSecret = defineSecret("KROGER_CLIENT_SECRET");

// Certification environment — matches the app's registration at
// developer.kroger.com (App Details → Environment: Certification, verified
// 2026-07-04). Production would be api.kroger.com with separate credentials.
const KROGER_TOKEN_URL = "https://api-ce.kroger.com/v1/connect/oauth2/token";
const KROGER_PRODUCTS_URL = "https://api-ce.kroger.com/v1/products";

let cachedToken: {value: string; expiresAt: number} | null = null;

async function getKrogerToken(clientId: string, clientSecret: string): Promise<string> {
  if (cachedToken && cachedToken.expiresAt > Date.now() + 60_000) {
    return cachedToken.value;
  }
  const basicAuth = Buffer.from(`${clientId}:${clientSecret}`).toString("base64");
  const res = await fetch(KROGER_TOKEN_URL, {
    method: "POST",
    headers: {
      "Authorization": `Basic ${basicAuth}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials&scope=product.compact",
  });
  if (!res.ok) {
    throw new Error(`Kroger token request failed: ${res.status}`);
  }
  const data = (await res.json()) as {access_token: string; expires_in: number};
  cachedToken = {value: data.access_token, expiresAt: Date.now() + data.expires_in * 1000};
  return cachedToken.value;
}

/**
 * Looks up a product's Kroger price/availability by UPC + locationId, and
 * writes the normalized result into products/{productId}/prices/kroger
 * matching the schema in ARCHITECTURE.md §3. The Flutter client never sees
 * Kroger credentials — it only calls this function and then reads Firestore
 * through FirestorePriceRepository like any other connector.
 */
export const lookupKrogerPrice = onCall(
  {secrets: [krogerClientId, krogerClientSecret]},
  async (request) => {
    // Signed-in users only (anonymous counts) — otherwise anyone on the
    // internet can burn Kroger quota and write into the shared catalog.
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in to look up prices.");
    }
    const {productId, upc, locationId} = request.data as {
      productId?: string;
      upc?: string;
      locationId?: string;
    };
    if (!productId || !upc || !locationId) {
      throw new HttpsError("invalid-argument", "productId, upc, and locationId are required.");
    }

    const token = await getKrogerToken(krogerClientId.value(), krogerClientSecret.value());
    const res = await fetch(
      `${KROGER_PRODUCTS_URL}?filter.term=${encodeURIComponent(upc)}&filter.locationId=${encodeURIComponent(locationId)}`,
      {headers: {Authorization: `Bearer ${token}`}}
    );

    const db = getFirestore();
    const priceDoc = db.collection("products").doc(productId).collection("prices").doc("kroger");

    if (!res.ok) {
      // Fail gracefully — record that Kroger had no current data rather
      // than throwing, so the client's normal "unavailable" path handles it.
      await priceDoc.set({
        source: "Kroger",
        availability: "unknown",
        verifiedAt: Timestamp.now(),
      });
      return {status: "unavailable"};
    }

    const data = (await res.json()) as {
      data?: Array<{items?: Array<{price?: {regular?: number}; inventory?: {stockLevel?: string}}>}>;
    };
    const item = data.data?.[0]?.items?.[0];
    const price = item?.price?.regular ?? null;
    const stockLevel = item?.inventory?.stockLevel;

    await priceDoc.set({
      source: "Kroger",
      price,
      availability: stockLevel === "HIGH" || stockLevel === "LOW" ? "in_stock" :
        stockLevel === "TEMPORARILY_OUT_OF_STOCK" ? "out_of_stock" : "unknown",
      verifiedAt: Timestamp.now(),
      confidence: price !== null ? 95 : null,
    });

    return {status: "ok", price};
  }
);
