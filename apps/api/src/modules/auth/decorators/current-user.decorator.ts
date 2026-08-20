import { ExecutionContext, createParamDecorator } from '@nestjs/common';

import type { AuthenticatedUser } from '../auth.types';

/**
 * Injects the authenticated user resolved from the access token.
 *
 * This is the **only** sanctioned source of `userId`. Never read ownership
 * from a request body or query string: a DTO that declares `userId` lets a
 * client write into another tenant, and the global ValidationPipe's
 * `forbidNonWhitelisted` only protects you while no DTO declares it.
 */
export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): AuthenticatedUser => {
    const request = ctx.switchToHttp().getRequest<{ user: AuthenticatedUser }>();
    return request.user;
  },
);
