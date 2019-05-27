const express = require('express')
const cookieParser = require('cookie-parser')
const verifyCSRFToken = require('../../utils/middlewares/verifyCSRFToken')
const jws = require('jws')
const uuid = require('uuid/v4')
const { ForbiddenError } = require('../../utils/errors')

const app = express()

app.use(cookieParser())
app.use(verifyCSRFToken)

app.post('/authenticate', express.json(), function (req, res, next) {
  const { username, password } = req.body

  if (username === 'admin' && password === 'admin') {
    const header =  { alg: 'HS256', typ: 'JWT' }
    const payload = {
      // iss: '', // (Issuer)
      // sub: '', // (Subject)
      // aud: '', // (Audience)
      // exp: '', // (Expiration Time)
      // nbf: '', // (Not Before)
      iat: new Date().getTime(), // (Issued At)
      jti: uuid(), // (JWT ID)
      // custom claims
      usr: '', // user
      rls: ['roles'], // roles
      ses: {
        user_id: uuid(),
        username: 'admin'
      }
    }
    const secret = process.env.AUTH_JWT_SECRET

    const payload = `${JSON.stringify(header).toString('base64').replace(/=+$/, '')}.${JSON.stringify(payload).toString('base64').replace(/=+$/, '')}`

    const signature = jws.sign({
      header,
      payload,
      secret
    })

    res.cookie('public', payload, {
      httpOnly: false,
      secure: false
    })
    res.cookie('private', signature, {
      httpOnly: true,
      secure: false
    })

    res.status(200).json({
      user: {
        username: 'admin',
        id: 1
      }
    })
  } else {
    next(new ForbiddenError())
  }
})


module.exports = app
