const jwt = require('jsonwebtoken')
const { UnauthorizedError } = require('../errors')


module.exports = function parseSession (req, res, next) {
  const sessionKey = req.cookies['session-key']
  const Authorization = req.get('Authorization')

  if (!sessionKey || !Authorization || !Authorization.match(/^session-auth /)) {
    return next()
  }

  const sessionAuth = Authorization.replace('session-auth ', '')

  const token = `${sessionAuth}.${sessionKey}`

  try {
    const auth = jwt.verify(token, process.env.AUTH_JWT_SECRET)

    req.session = auth.ses

    next()
  } catch (error) {
    console.error(error)
    next(new UnauthorizedError())
  }
}
// module.exports = function parseSession (req, res, next) {
//   if (!req.cookies['session-auth'] || !req.cookies['session-key']) {
//     next()
//   } else {
//     const token = `${req.cookies['session-auth']}.${req.cookies['session-key']}`

//     try {
//       const auth = jwt.verify(token, process.env.AUTH_JWT_SECRET)

//       req.session = auth.ses

//       next()
//     } catch (error) {
//       console.error(error)
//       next(new BadRequestError())
//     }
//   }
// }