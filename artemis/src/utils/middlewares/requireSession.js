const { UnauthorizedError } = require('../errors')

module.exports = function requireSession (req, res, next) {
  if (!req.session) {
    next(new UnauthorizedError)
  } else {
    next()
  }
}
