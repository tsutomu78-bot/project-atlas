/// Explicit success/failure states instead of nulls or thrown exceptions.
/// Each failure case maps to a specific UI message, per the transparency
/// model in PRD.md §5 — the UI always knows exactly what to tell the user.
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class NotFound<T> extends Result<T> {
  const NotFound();
}

class Offline<T> extends Result<T> {
  const Offline();
}

class PermissionDenied<T> extends Result<T> {
  const PermissionDenied();
}

class ConnectorUnavailable<T> extends Result<T> {
  final String connectorId;
  const ConnectorUnavailable(this.connectorId);
}

class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}
