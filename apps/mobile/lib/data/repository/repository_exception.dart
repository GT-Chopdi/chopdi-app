/// A write rejected locally, before it could reach the outbox.
///
/// Every rule enforced here mirrors a CHECK constraint on the server. Catching
/// a violation at the point of the write means the user sees an error while
/// they are still looking at the form. Letting it through means the operation
/// syncs, is permanently rejected, dead-letters, and the user is told hours
/// later that an entry they believed was saved has failed — with no obvious
/// way to correct it.
class RepositoryException implements Exception {
  const RepositoryException(this.message, {this.field});

  final String message;
  final String? field;

  @override
  String toString() =>
      'RepositoryException${field != null ? ' [$field]' : ''}: $message';
}
