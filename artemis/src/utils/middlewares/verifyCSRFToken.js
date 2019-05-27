const { BadRequestError } = require('../errors')

module.exports = function verifyCSRFToken (req, res, next) {
  const headerToken = req.header('X-XSRF-TOKEN')
  const cookieToken = req.cookies['XSRF-TOKEN']

  if (headerToken && headerToken === cookieToken) {
    next()
  } else {
    next(new BadRequestError())
  }
}