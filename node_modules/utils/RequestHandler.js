const { ServerError } = require('./errors')

module.exports = class RequestHandler {
  constructor (handler = () => {}) {
    this.handler = handler
  }

  normalizeParameters (parameters = null, ctx1, ctx2, ctx3) {
    if (parameters !== null && typeof parameters === 'function') {
      parameters = parameters(ctx1, ctx2, ctx3)
    }

    if (parameters === null) {
      parameters = []
    } else if (!Array.isArray(parameters)) {
      parameters = [ parameters ]
    }

    return parameters
  }

  async GraphQL (parameters = (args, ctx) => []) {
    return async (args, ctx) => {
      try {
        const response = await this.handler(...this.normalizeParameters(parameters, args, ctx))

        return response
      } catch (error) {
        console.error(error)
        throw error
      }
    }
  }

  async Rest (parameters = (req, res, next) => []) {
    return async (req, res, next) => {
      try {
        const response = await this.handler(...this.normalizeParameters(parameters, req, res, next))

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
}

/*
  example use

  expresss:

  const app = express()

  app.post('/route', middleware, new RequestHandler(handlerFunction).Rest(req => [req.body, req.db]))

  graphql:

  route: new RequestHandler(handlerFunction).GraphQL((args, ctx) => [args, ctx.db])
*/