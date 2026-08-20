/**
 * Claims carried by the access token.
 *
 * Deliberately minimal: an access token is a bearer credential with a
 * 15-minute life, so it carries identity and nothing else. Anything the
 * server needs to *decide* with — device revocation, user status — is read
 * from the database, because a claim baked into a token cannot be revoked.
 */
export interface JwtPayload {
  /** `app_user.id` — the sole source of ownership for every request. */
  sub: string;

  /** `device.id` — must match the `X-Device-Id` header. */
  did: string;

  iat?: number;
  exp?: number;
}

/**
 * What `@CurrentUser()` resolves to. Attached to the request by the JWT
 * strategy after the token is verified and the device is confirmed live.
 */
export interface AuthenticatedUser {
  userId: string;
  deviceId: string;
  phoneE164: string;
}

/** Shape returned by both `verify` and `refresh`. */
export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  /** Access-token lifetime in seconds, so the client can pre-emptively refresh. */
  expiresIn: number;
}
