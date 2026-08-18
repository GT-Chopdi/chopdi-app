import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';

import { AppException, ErrorCode } from '../../../common/errors/app.exception';
import type { AuthenticatedUser } from '../auth.types';
import { IS_PUBLIC_KEY } from '../../../common/decorators/public.decorator';

/**
 * Requires `X-Device-Id` to match the `did` claim in the access token.
 *
 * The device's liveness is already checked by the JWT strategy; this guard
 * exists so the header and the token cannot disagree. Keeping the device
 * identity visible in the request — rather than only inside a signed blob —
 * is what makes per-device rate limiting and sync diagnostics possible without
 * decoding the token at every layer.
 */
@Injectable()
export class DeviceGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) return true;

    const request = context.switchToHttp().getRequest<{
      user?: AuthenticatedUser;
      headers: Record<string, string | string[] | undefined>;
    }>();

    const user = request.user;
    if (!user) return false;

    const header = request.headers['x-device-id'];
    const deviceId = Array.isArray(header) ? header[0] : header;

    if (!deviceId || deviceId !== user.deviceId) {
      throw new AppException(
        403,
        ErrorCode.DEVICE_REVOKED,
        'Device identity does not match this session.',
        true,
      );
    }

    return true;
  }
}
