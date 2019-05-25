class InternalServerError extends Error {
  constructor (message = 'Internal Server Error', status = 500) {
    super(message)

    // this line possibly not required
    // Error.captureStackTrace(this, this.constructor);

    this.name = this.constructor.name;

    this.status = status
  }
}

class ClientNotFoundError extends InternalServerError {
  constructor (message) {
    super(message, 404)
  }
}

module.exports = InternalServerError