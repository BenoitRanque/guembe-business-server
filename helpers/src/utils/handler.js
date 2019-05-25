/*
  express router helper



*/

const ServerError = require('./ServerError')

module.exports = function handler (handler, params = null) {
  return async function (req, res, next) {
    if (params !== null && typeof params === 'function') {
      parameters = parameters(req, res, next)
    }

    if (parameters === null) {
      parameters = []
    } else if (!Array.isArray(parameters)) {
      parameters = [ parameters ]
    }

    try {
      const response = await handler(...(Array.isArray(parameters) ? parameters : [parameters]))

      res.status(200).json(response)
    } catch (error) {
      console.error(error)
      // error class name also available here
      if (error instanceof ServerError) {
        res.status(error.status)
      } else {
        res.status(500)
      }
      next(error)
    }
  }
}
