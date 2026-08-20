import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Request, Response } from 'express';

import { AppException, ErrorCode } from '../errors/app.exception';

interface ErrorBody {
  code: string;
  message: string;
  permanent: boolean;
  details?: Record<string, unknown>;
}

/**
 * Converts every thrown error into the single response envelope the Flutter
 * client parses:
 *
 *   { error: { code, message, permanent, details }, requestId }
 *
 * Its other job is containment. Without a catch-all filter, Nest's default
 * handler will surface Prisma errors verbatim — including table names,
 * column names, and constraint definitions — to whoever made the request.
 * Internal detail is logged server-side and never serialised.
 */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const requestId = request.requestId ?? 'unknown';
    const { status, body } = this.translate(exception);

    const retryAfter = body.details?.retryAfterSeconds;
    if (typeof retryAfter === 'number') {
      response.setHeader('Retry-After', String(retryAfter));
    }

    if (status >= 500) {
      this.logger.error(
        `${request.method} ${request.url} → ${status} [${body.code}] req=${requestId}`,
        exception instanceof Error ? exception.stack : String(exception),
      );
    } else {
      this.logger.warn(
        `${request.method} ${request.url} → ${status} [${body.code}] req=${requestId}`,
      );
    }

    response.status(status).json({ error: body, requestId });
  }

  private translate(exception: unknown): { status: number; body: ErrorBody } {
    if (exception instanceof AppException) {
      return {
        status: exception.getStatus(),
        body: {
          code: exception.code,
          message: exception.message,
          permanent: exception.permanent,
          details: exception.details,
        },
      };
    }

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const payload = exception.getResponse();

      // The global ValidationPipe throws BadRequestException with `message` as
      // a string array. Surface those as structured details so the client can
      // show which field failed rather than a wall of text.
      if (
        status === HttpStatus.BAD_REQUEST &&
        typeof payload === 'object' &&
        payload !== null &&
        Array.isArray((payload as { message?: unknown }).message)
      ) {
        return {
          status,
          body: {
            code: ErrorCode.VALIDATION_FAILED,
            message: 'Request validation failed.',
            permanent: true,
            details: {
              issues: (payload as { message: string[] }).message,
            },
          },
        };
      }

      return {
        status,
        body: {
          code: this.codeForStatus(status),
          message: this.messageFrom(payload, exception.message),
          // 4xx means the request itself is wrong, so replaying it unchanged
          // cannot help. 5xx is the server's problem and may resolve.
          permanent: status < 500,
        },
      };
    }

    return {
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      body: {
        code: ErrorCode.INTERNAL,
        message: 'An unexpected error occurred.',
        permanent: false,
      },
    };
  }

  private codeForStatus(status: number): string {
    switch (status) {
      case HttpStatus.UNAUTHORIZED:
        return ErrorCode.UNAUTHENTICATED;
      case HttpStatus.NOT_FOUND:
        return ErrorCode.NOT_FOUND;
      case HttpStatus.TOO_MANY_REQUESTS:
        return ErrorCode.RATE_LIMITED;
      case HttpStatus.SERVICE_UNAVAILABLE:
        return ErrorCode.DB_UNAVAILABLE;
      default:
        return status >= 500 ? ErrorCode.INTERNAL : ErrorCode.VALIDATION_FAILED;
    }
  }

  private messageFrom(payload: unknown, fallback: string): string {
    if (typeof payload === 'string') return payload;

    if (typeof payload === 'object' && payload !== null) {
      const message = (payload as { message?: unknown }).message;
      if (typeof message === 'string') return message;
    }

    return fallback;
  }
}
