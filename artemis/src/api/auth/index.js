const express = require('express')
const cookieParser = require('cookie-parser')
const verifyCSRFToken = require('../../utils/middlewares/verifyCSRFToken')
const jwt = require('jsonwebtoken')
const uuid = require('uuid/v4')
const bodyParser = require('body-parser')
const { ForbiddenError, NotFoundError } = require('../../utils/errors')

const app = express()

app.use(cookieParser())

// app.post('/callback', express.urlencoded({ extended: false }), async function (req, res, next) {

//   const googleIssuer = await Issuer.discover('https://accounts.google.com') // => Promise

//   const client = new googleIssuer.Client({
//     client_id: process.env.OAUTH_PROVIDER_GOOGLE_CLIENT_ID,
//     redirect_uris: ['http://localhost:9090/api/v1/auth/callback'],
//     response_types: ['id_token'],
//     // id_token_signed_response_alg (default "RS256")
//   })

//   client[custom.clock_tolerance] = 120 // to allow a 2 minute skew

//   const nonce = req.cookies['openid-nonce']
//   res.clearCookie('openid-nonce')
//   // throw error if nonce is absent

//   const params = client.callbackParams(req)
//   const tokenSet = await client.callback(null, params, { nonce })

//   console.log('received and validated tokens %j', tokenSet);
//   console.log('validated ID Token claims %j', tokenSet.claims());

//   res.redirect('http://localhost:8080')
// })


// app.get('/authenticate/:provider', async function (req, res, next) {
//   const googleIssuer = await Issuer.discover('https://accounts.google.com')

//   const client = new googleIssuer.Client({
//     client_id: process.env.OAUTH_PROVIDER_GOOGLE_CLIENT_ID,
//     redirect_uris: ['http://localhost:9090/api/v1/auth/callback'],
//     response_types: ['id_token'],
//     // id_token_signed_response_alg (default "RS256")
//   })

//   client[custom.clock_tolerance] = 120 // to allow a 2 minute skew

//   const nonce = generators.nonce()
//   // store the nonce in your framework's session mechanism, if it is a cookie based solution
//   // it should be httpOnly (not readable by javascript) and encrypted.
//   res.cookie('openid-nonce', nonce, {
//     httpOnly: true,
//     secure: true,
//     maxAge: 5 * 60 * 1000 // 5 minutes
//   })

//   const url = client.authorizationUrl({
//     scope: 'openid email profile',
//     // response_mode: 'id_token',
//     response_mode: 'form_post',
//     nonce
//   })

//   res.redirect(url)
//   // res.status(200).json({ url })
// })

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


const qs = require('querystring')
const axios = require('axios')


function encodeState (state) {
  return Buffer.from(JSON.stringify(state)).toString('base64')
}

function decodeState (state) {
  return JSON.parse(Buffer.from(state, 'base64').toString())
}

async function loadClientAccount (clientAuth, db) {
  const query = `
    SELECT client_id, name, email, first_name, middle_name, last_name, authentication_provider_name
    FROM store.client
    WHERE authentication_provider_name = $1
    AND authentication_provider_account_id = $2
  `
  const { rows: [ client ] } = await db.query(query, [
    clientAuth.authentication_provider_name,
    clientAuth.authentication_provider_account_id
  ])

  return client ? client : null
}

async function createClientAccount (clientAuth, db) {
  const query = `
    INSERT INTO store.client
      (name, email, first_name, middle_name, last_name, authentication_provider_name, authentication_provider_account_id)
    VALUES
      ($1, $2, $3, $4, $5, $6, $7)
    RETURNING
      client_id, name, email, first_name, middle_name, last_name, authentication_provider_name
  `

  // order here must be same as above. Be careful
  const { rows: [ client ] } = await db.query(query, [
    clientAuth.name,
    clientAuth.email,
    clientAuth.first_name,
    clientAuth.middle_name,
    clientAuth.last_name,
    clientAuth.authentication_provider_name,
    clientAuth.authentication_provider_account_id
  ])

  return client
}

function getClientSession (clientAccount) {
  const { client_id } = clientAccount

  return {
    user_type: 'client',
    user_id: client_id,
    roles: ['client']
  }
}

function setSessionCookie (session, res) {
  const token = jwt.sign({
    // iss: '', // (Issuer)
    // sub: '', // (Subject)
    // aud: '', // (Audience)
    // exp: '', // (Expiration Time)
    // nbf: '', // (Not Before)
    // iat: new Date().getTime(), // (Issued At)
    jti: uuid(), // (JWT ID)
    // custom claims
    ses: session
  }, process.env.AUTH_JWT_SECRET, {
    // mutatePayload: true // enable to mutate the payload (first parameter)
  })
  const [ header, payload, signature ] = token.split('.')

  res.cookie('session-auth', `${header}.${payload}`, {
    httpOnly: false,
    secure: true
  })
  res.cookie('session-key', signature, {
    httpOnly: true,
    secure: true
  })
}

class OAuth2 {
  constructor ({
    name,
    clientId,
    clientSecret,
    authenticationEndpoint,
    verificationEndpoint,
    verificationMethod = 'GET',
    resourceEndpoint,
    scope,
    fields,
    parseFields = fields => fields,
  }) {
    this.name = name
    this.clientId = clientId
    this.clientSecret = clientSecret
    this.authenticationEndpoint = authenticationEndpoint
    this.verificationEndpoint = verificationEndpoint
    this.verificationMethod = verificationMethod
    this.resourceEndpoint = resourceEndpoint
    this.scope = scope
    this.fields = fields
    this.parseFields = parseFields
  }

  getRedirectUri () {
    return `https://${process.env.PUBLIC_HOSTNAME}/api/v1/auth/oauth/${this.name}/callback`
  }

  getAuthenticationURL (state) {
    const query = qs.stringify({
      client_id: this.clientId,
      response_type: 'code',
      redirect_uri: this.getRedirectUri(),
      scope: this.scope,
      state: encodeState(state)
    })

    return `${this.authenticationEndpoint}?${query}`
  }

  async getAccessToken(code) {
    const { data: { access_token } } = await axios({
      method: this.verificationMethod,
      url: this.verificationEndpoint,
      params: {
        code,
        grant_type: 'authorization_code',
        client_id: this.clientId,
        client_secret: this.clientSecret,
        redirect_uri: this.getRedirectUri()
      }
    })

    return access_token
  }

  async getClientAuth (access_token) {
    const { data: fields  } = await axios({
      method: 'GET',
      url: this.resourceEndpoint,
      params: {
        access_token,
        fields: this.fields
      }
    })

    return this.parseFields(fields)
  }
}

const google = new OAuth2({
  name: 'google',
  clientId: process.env.OAUTH_PROVIDER_GOOGLE_CLIENT_ID,
  clientSecret: process.env.OAUTH_PROVIDER_GOOGLE_CLIENT_SECRET,
  authenticationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
  verificationEndpoint: 'https://www.googleapis.com/oauth2/v4/token',
  verificationMethod: 'POST',
  resourceEndpoint: 'https://www.googleapis.com/oauth2/v1/userinfo',
  scope: 'profile email',
  fields: 'id,name,email,given_name,family_name',
  parseFields (fields) {
    const { id, name, email, given_name, family_name } = fields
    let first_name = '', middle_name = ''
    if (given_name && given_name.length) {
      let namesArr = given_name.split(' ')
      if (namesArr.length) {
        first_name = namesArr[0]
        if (namesArr.length >= 2) {
          middle_name = namesArr.slice(1).join(' ')
        }
      }
    }

    return {
      authentication_provider_name: 'google',
      authentication_provider_account_id: id,
      name: name ? name : '',
      email: email ? email : '',
      first_name: first_name ? first_name : '',
      middle_name: middle_name ? middle_name : '',
      last_name: family_name ? family_name : ''
    }
  }
})

const facebook = new OAuth2({
  name: 'facebook',
  clientId: process.env.OAUTH_PROVIDER_FACEBOOK_CLIENT_ID,
  clientSecret: process.env.OAUTH_PROVIDER_FACEBOOK_CLIENT_SECRET,
  authenticationEndpoint: 'https://www.facebook.com/v3.3/dialog/oauth',
  verificationEndpoint: 'https://graph.facebook.com/v3.3/oauth/access_token',
  verificationMethod: 'GET',
  resourceEndpoint: 'https://graph.facebook.com/me',
  scope: 'email',
  fields: 'id,name,email,first_name,last_name,middle_name',
  parseFields (fields) {
    const { id, name, email, first_name, middle_name, last_name } = fields

    return {
      authentication_provider_name: 'facebook',
      authentication_provider_account_id: id,
      name: name ? name : '',
      email: email ? email : '',
      first_name: first_name ? first_name : '',
      middle_name: middle_name ? middle_name : '',
      last_name: last_name ? last_name : ''
    }
  }
})

app.get('/oauth/:provider', async function (req, res, next) {
  const xsrfToken = uuid()

  res.cookie('XSRF-TOKEN-OAUTH', xsrfToken, {
    httpOnly: true,
    secure: true,
    maxAge: 5 * 60 * 1000 // 5 minutes max to login
  })

  const state = {
    xsrfToken,
    clientState: req.query
  }

  try {
    switch (req.params.provider) {
      case 'google':
        {
          res.redirect(google.getAuthenticationURL(state))
        }
        break
      case 'facebook':
        {
          res.redirect(facebook.getAuthenticationURL(state))
        }
        break
      default:
        next(new NotFoundError())
    }
  } catch (error) {
    next(error)
  }
})

app.get('/oauth/:provider/callback', express.urlencoded({ extended: false }), async function (req, res, next) {
  const state = decodeState(req.query.state)

  const stateToken = state.xsrfToken
  const cookieToken = req.cookies['XSRF-TOKEN-OAUTH']

  // check if xsrftoken matches
  if (!stateToken || stateToken !== cookieToken) {
    return next(new BadRequestError())
  }

  let clientAuth = null
  let clientAccount = null

  try {
    switch (req.params.provider) {
      case 'google':
        {
          const access_token = await google.getAccessToken(req.query.code)
          clientAuth = await google.getClientAuth(access_token)
        }
        break
      case 'facebook':
        {
          const access_token = await facebook.getAccessToken(req.query.code)
          clientAuth = await facebook.getClientAuth(access_token)
        }
        break
      default:
        return next(new NotFoundError())
    }

    clientAccount = await loadClientAccount(clientAuth, req.db)
    if (clientAccount === null) {
      clientAccount = await createClientAccount(clientAuth, req.db)
    }

    const session = getClientSession(clientAccount)

    setSessionCookie(session, res)

    // todo: send client state back as query params
    res.redirect(`https://${process.env.PUBLIC_HOSTNAME}/`)
  } catch (error) {
    console.log('error in callback')
    next(error)
  }
})

app.post('/login', verifyCSRFToken, express.json(), function (req, res, next) {
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
    const [ header, payload, signature ] = token.split('.')

    res.cookie('session-auth', `${header}.${payload}`, {
      httpOnly: false,
      secure: true
    })
    res.cookie('session-key', signature, {
      httpOnly: true,
      secure: true
    })

    res.status(200).json(session)
  } else {
    next(new ForbiddenError())
  }
})

app.post('/logout', verifyCSRFToken, function (req, res, next) {
  res.clearCookie('session-auth')
  res.clearCookie('session-key')
  res.status(200).json({})
})

function buildQueryString (query) {
  return Object.keys(query)
    .map(param => `${encodeURIComponent(param)}=${encodeURIComponent(query[param])}`)
    .join('&')
}

function buildUrl (baseURL, query) {
  return `${baseURL}?${buildQueryString(query)}`
}

module.exports = app
