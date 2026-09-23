/// Admin review state of a Driver account. Authentication succeeds for all
/// three; only [approved] may use operational endpoints.
enum ApprovalStatus {
  pending,
  approved,
  rejected;

  /// Unknown values fall back to [pending] so an unexpected backend value
  /// never grants operational access.
  static ApprovalStatus fromApi(String? value) => switch (value) {
    'approved' => ApprovalStatus.approved,
    'rejected' => ApprovalStatus.rejected,
    _ => ApprovalStatus.pending,
  };
}
