String? homeRouteForAuthorities(Iterable<String> authorities) {
  if (authorities.contains('ROLE_ADMIN')) return '/homeAdmin';
  if (authorities.contains('ROLE_SECRE')) return '/homeSecre';
  if (authorities.contains('ROLE_USER')) return '/homeUser';
  return null;
}
