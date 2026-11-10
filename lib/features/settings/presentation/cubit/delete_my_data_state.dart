/// Lifecycle of the "delete my data" request.
enum DeleteMyDataStatus { idle, deleting, success, failure }

class DeleteMyDataState {
  const DeleteMyDataState({
    this.status = DeleteMyDataStatus.idle,
    this.errorMessage = '',
  });

  final DeleteMyDataStatus status;

  /// Message returned by the API; empty means "show the localized fallback".
  final String errorMessage;

  bool get isDeleting => status == DeleteMyDataStatus.deleting;

  bool get isDeleted => status == DeleteMyDataStatus.success;

  bool get hasError => status == DeleteMyDataStatus.failure;
}
