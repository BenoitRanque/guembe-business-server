const jwt = require('jsonwebtoken')
const { BadRequestError } = require('../errors')


module.exports = function parseSession (req, res, next) {
  if (!req.cookies['session-auth'] || !req.cookies['session-key']) {
    next()
  } else {
    const token = `${req.cookies['session-auth']}.${req.cookies['session-key']}`

    try {
      const auth = jwt.verify(token, process.env.AUTH_JWT_SECRET)

      req.session = auth.ses

      next()
    } catch (error) {
      console.error(error)
      next(new BadRequestError())
    }
  }
}
