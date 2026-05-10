export class DomainError extends Error {
  constructor(
    public code: string,
    public httpStatus: number,
    message: string,
    public details?: Record<string, unknown>,
  ) {
    super(message);
    this.name = 'DomainError';
  }
}

export class NotFoundError extends DomainError {
  constructor(resource: string, id?: string) {
    super('NOT_FOUND', 404, `${resource} not found`, id ? { id } : undefined);
  }
}

export class ValidationError extends DomainError {
  constructor(message: string, details?: Record<string, unknown>) {
    super('VALIDATION_ERROR', 400, message, details);
  }
}

export class ForbiddenError extends DomainError {
  constructor(message = 'Forbidden') {
    super('FORBIDDEN', 403, message);
  }
}

export class ConflictError extends DomainError {
  constructor(message: string, details?: Record<string, unknown>) {
    super('CONFLICT', 409, message, details);
  }
}

export class UnauthorizedError extends DomainError {
  constructor(message = 'Unauthorized') {
    super('UNAUTHORIZED', 401, message);
  }
}

export class RateLimitError extends DomainError {
  constructor() {
    super('RATE_LIMIT_EXCEEDED', 429, 'Too many requests. Please slow down.');
  }
}
