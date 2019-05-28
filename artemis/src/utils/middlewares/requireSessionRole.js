const { ForbiddenError, UnauthorizedError } = require('../errors')

module.exports = function requireSessionRole (roles = []) {
  if (!Array.isArray(roles)) {
    throw new Error(`Expected roles argument to be an array, got: ${roles}`)
  }
  return (req, res, next) => {
    if (!req.session) {
      next(new UnauthorizedError())
    } else if (!req.session.roles || !req.session.roles.some(role => roles.includes(role))) {
      next(new ForbiddenError())
    } else {
      next()
    }
  }
}
