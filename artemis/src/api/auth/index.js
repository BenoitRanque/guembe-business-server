const express = require('express')
const cookieParser = require('cookie-parser')
const verifyCSRFToken = require('../../utils/middlewares/verifyCSRFToken')
const jwt = require('jsonwebtoken')
const uuid = require('uuid/v4')
const bodyParser = require('body-parser')
const { ForbiddenError, NotFoundError } = require('../../utils/errors')

const { Issuer, generators, custom, } = require('openid-client')

const app = express()

app.use(cookieParser())

app.post('/callback', express.urlencoded({ extended: false }), async function (req, res, next) {

  const googleIssuer = await Issuer.discover('https://accounts.google.com') // => Promise

  const client = new googleIssuer.Client({
    client_id: process.env.OAUTH_PROVIDER_GOOGLE_CLIENT_ID,
    redirect_uris: ['http://localhost:9090/api/v1/auth/callback'],
    response_types: ['id_token'],
    // id_token_signed_response_alg (default "RS256")
  })

  client[custom.clock_tolerance] = 120 // to allow a 2 minute skew

  const nonce = req.cookies['openid-nonce']
  res.clearCookie('openid-nonce')
  // throw error if nonce is absent

  const params = client.callbackParams(req)
  const tokenSet = await client.callback(null, params, { nonce })

  console.log('received and validated tokens %j', tokenSet);
  console.log('validated ID Token claims %j', tokenSet.claims());

  res.redirect('http://localhost:8080')
})


app.get('/authenticate/:provider', async function (req, res, next) {
  const googleIssuer = await Issuer.discover('https://accounts.google.com')

  const client = new googleIssuer.Client({
    client_id: process.env.OAUTH_PROVIDER_GOOGLE_CLIENT_ID,
    redirect_uris: ['http://localhost:9090/api/v1/auth/callback'],
    response_types: ['id_token'],
    // id_token_signed_response_alg (default "RS256")
  })

  client[custom.clock_tolerance] = 120 // to allow a 2 minute skew

  const nonce = generators.nonce()
  // store the nonce in your framework's session mechanism, if it is a cookie based solution
  // it should be httpOnly (not readable by javascript) and encrypted.
  res.cookie('openid-nonce', nonce, {
    httpOnly: true,
    secure: false,
    maxAge: 5 * 60 * 1000 // 5 minutes
  })

  const url = client.authorizationUrl({
    scope: 'openid email profile',
    // response_mode: 'id_token',
    response_mode: 'form_post',
    nonce
  })

  res.redirect(url)
  // res.status(200).json({ url })
})

// app.get('/authenticate/:provider', function (req, res, next) {

  //   let baseURL = null
  //   const queryObject = {
    //     // redirect_uri: '',
    //     ...req.query
    //   }

    //   switch (req.params.provider) {
      //     case 'google':
      //       baseURL = 'https://accounts.google.com/o/oauth2/v2/auth'
      //       queryObject.client_id = process.env.OAUTH_PROVIDER_GOOGLE_CLIENT_ID
      //       queryObject.response_type = 'code'
      //       queryObject.scope = `profile email`
//       break
//     case 'facebook':
//       baseURL = `https://www.facebook.com/v3.2/dialog/oauth`
//       queryObject.display = 'touch'
//       queryObject.client_id = process.env.OAUTH_PROVIDER_FACEBOOK_CLIENT_ID
//       queryObject.response_type = 'code'
//       queryObject.scope = `email`
//       break
//     default:
//       // error is 404 if provider does not exist
//       return next(new NotFoundError())
//   }

//   res.redirect(buildUrl(baseURL, queryObject))
// })


app.use(verifyCSRFToken)

app.post('/authenticate', express.json(), function (req, res, next) {
  const { username, password } = req.body

  if (username === 'admin' && password === 'admin') {
    const session = {
      // iss: '', // (Issuer)
      // sub: '', // (Subject)
      // aud: '', // (Audience)
      // exp: '', // (Expiration Time)
      // nbf: '', // (Not Before)
      // iat: new Date().getTime(), // (Issued At)
      jti: uuid(), // (JWT ID)
      // custom claims
      ses: {
        usr: '', // user
        rls: ['roles'], // roles
        user_id: uuid(),
        username: 'admin'
      }
    }
    const token = jwt.sign(session, process.env.AUTH_JWT_SECRET, {
      mutatePayload: true
    })
    console.log(session)
    const [ header, payload, signature ] = token.split('.')

    res.cookie('session-auth', `${header}.${payload}`, {
      httpOnly: false,
      secure: false
    })
    res.cookie('session-key', signature, {
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


function buildQueryString (query) {
  return Object.keys(query)
    .map(param => `${encodeURIComponent(param)}=${encodeURIComponent(query[param])}`)
    .join('&')
}

function buildUrl (baseURL, query) {
  return `${baseURL}?${buildQueryString(query)}`
}

function getJoule (mass, distance, time) {
  return mass * (distance / time)
}

module.exports = app
