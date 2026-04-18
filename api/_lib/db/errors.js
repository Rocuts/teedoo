class DbError extends Error {
  constructor(message, { cause, code } = {}) {
    super(message);
    this.name = 'DbError';
    this.code = code || 'DB_ERROR';
    if (cause) this.cause = cause;
  }
}

class NotFoundError extends DbError {
  constructor(entity, id) {
    super(`${entity} not found: ${id}`, { code: 'NOT_FOUND' });
    this.name = 'NotFoundError';
    this.entity = entity;
    this.entityId = id;
  }
}

class ConflictError extends DbError {
  constructor(message, { cause, field } = {}) {
    super(message, { cause, code: 'CONFLICT' });
    this.name = 'ConflictError';
    this.field = field;
  }
}

class ValidationError extends DbError {
  constructor(message, { field } = {}) {
    super(message, { code: 'VALIDATION' });
    this.name = 'ValidationError';
    this.field = field;
  }
}

module.exports = { DbError, NotFoundError, ConflictError, ValidationError };
