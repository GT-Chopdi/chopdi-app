import { ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';

import { AppException, ErrorCode } from '../../../common/errors/app.exception';
import { IS_PUBLIC_KEY } from '../../../common/decorators/public.decorator';

/**
 * Registered globally in {@link AuthModule}, so every route requires a valid
 * access token unless it is marked `@Public()`.
 *
 * Fail-closed on purpose: forgetting to protect a new sync endpoint would
 * expose every user's ledger, while forgetting to open a public one produces
 * an obvious 401 in development.
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private readonly reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) return true;

    return super.canActivate(context);
  }

  handleRequest<TUser>(err: unknown, user: TUser, _info: unknown): TUser {
    // Errors thrown by the strategy (device revoked, account suspended) carry
    // their own status and code — pass them through rather than flattening
    // everything to a generic 401, so the client can tell "refresh your token"
    // apart from "wipe local data and sign in again".
    if (err instanceof AppException) throw err;

    if (err || !user) {
      throw new AppException(
        401,
        ErrorCode.UNAUTHENTICATED,
        'Authentication required.',
        false,
      );
    }

    return user;
  }
}
