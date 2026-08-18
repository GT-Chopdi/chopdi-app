import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';

/**
 * Marks a route as reachable without an access token.
 *
 * The JWT guard is registered globally (fail-closed), so every route requires
 * authentication unless it opts out with this decorator. Adding a new endpoint
 * therefore protects it by default — the failure mode of forgetting is a
 * locked door, not an open one.
 *
 * Lives in `common/` rather than `modules/auth/` because the guard that reads
 * it is a cross-cutting concern: `health` needs to opt out without taking a
 * dependency on the auth module.
 */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
