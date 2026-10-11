/// Returns the invite token embedded in the current page URL, or null if the
/// URL does not contain a valid invite path.
///
/// Supports hash-fragment URLs of the form:
///   `http://localhost:57753/#/join/<token>`
String? getInviteTokenFromUrl() {
  final uri = Uri.base;

  final fragment = uri.fragment;
  final segments = fragment
      .split('/')
      .where((segment) => segment.isNotEmpty)
      .toList();

  if (segments.length >= 2 &&
      segments[0] == 'join' &&
      segments[1].isNotEmpty) {
    return segments[1];
  }

  return null;
}
