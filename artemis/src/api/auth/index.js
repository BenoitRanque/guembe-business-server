const express = require('express')
const cookieParser = require('cookie-parser')
const jwt = require('jsonwebtoken')
const uuid = require('uuid/v4')
const bcrypt = require('bcryptjs')
const { ForbiddenError, NotFoundError } = require('../../utils/errors')

const app = express()

app.use(cookieParser())

app.get('/oauth/:provider', async function (req, res, next) {
  const xsrfToken = uuid()

  res.cookie('XSRF-TOKEN-OAUTH', xsrfToken, {
    httpOnly: true,
    secure: true,
    maxAge: 5 * 60 * 1000 // 5 minutes max to login
  })

  const state = encodeState({
    xsrfToken,
    clientState: req.query
  })

  if (req.oauth.hasOwnProperty(req.params.provider)) {
    return res.redirect(req.oauth[req.params.provider].getAuthenticationURL(state))
  }
  next(new NotFoundError())
})

app.get('/oauth/:provider/callback', express.urlencoded({ extended: false }), async function (req, res, next) {
  const provider = req.params.provider

  const state = decodeState(req.query.state)

  const stateToken = state.xsrfToken
  const cookieToken = req.cookies['XSRF-TOKEN-OAUTH']

  // check if xsrftoken matches
  if (!stateToken || stateToken !== cookieToken) {
    return next(new BadRequestError())
  }

  if (!req.oauth.hasOwnProperty(provider)) {
    return next(new NotFoundError())
  }

  try {

    const accessToken = await req.oauth[provider].getAccessToken(req.query.code)
    const userOAuthAccount = await req.oauth[provider].getUserOAuthAccount(accessToken)

    const query = `
      SELECT account.user.user_id, account.user.user_type_id
      FROM account.user
      WHERE oauth_provider_id = $1
      AND oauth_id = $2
    `
    let { rows: [ userAccount ] } = await req.db.query(query, [
      userOAuthAccount.oauth_provider_id,
      userOAuthAccount.oauth_id
    ])

    if (!userAccount) {
      userAccount = await createAccountUser({ ...userOAuthAccount, user_type_id: 'client' }, req.db)
    }

    const session = await getUserSession(userAccount, req.db)
    const token = getSessionToken(session)

    setSessionCookie(token, res)

    const [ header, payload ] = token.split('.')

    return res.redirect(`https://${process.env.PUBLIC_HOSTNAME}/?session=${header}.${payload}`)

  } catch (error) {
    console.error(error)
    // redirect to home page
    res.redirect(`https://${process.env.PUBLIC_HOSTNAME}/`)
  }
})

app.post('/login', express.json(), async function (req, res, next) {
  const { username, password } = req.body

  const query = `
    SELECT user_id, user_type_id, password
    FROM account.user
    WHERE username = $1
  `

  const { rows: [ user ] } = await req.db.query(query, [ username ])

  if (user) {
    const valid = await bcrypt.compare(password, user.password)
    if (valid) {
      const session = await getUserSession(user, req.db)
      const token = getSessionToken(session)

      setSessionCookie(token, res)

      const [ header, payload ] = token.split('.')

      return res.status(200).send(`${header}.${payload}`)
    }
  }
  next(new ForbiddenError())
})

app.post('/logout', function (req, res, next) {
  res.clearCookie('session-auth')
  res.clearCookie('session-key')
  res.status(204).end()
})

async function getUserSession (user, db) {
  const { user_id, user_type_id } = user

  const roles = [ user_type_id ]

  // dont run this for clients. May change in future
  if (user_type_id !== 'client') {
    const query = `
      SELECT account.role.role_id
      FROM account.user_role
      LEFT JOIN account.role ON (account.user_role.role_id = account.role.role_id)
      WHERE user_id = $1
    `
    const { rows: roleRows } = await db.query(query, [user_id])


    if (roleRows.length) {
      roles.push(...roleRows.map(({ role_id }) => role_id))
    }
  }

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
      user_type: user_type_id,
      user_id,
      roles
    }
  }

  return session
}

function getSessionToken(session) {
  const token = jwt.sign(session, process.env.AUTH_JWT_SECRET, {
    mutatePayload: true
  })
  return token
}

function setSessionCookie(token, res) {
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

function encodeState (state) {
  return Buffer.from(JSON.stringify(state)).toString('base64')
}

function decodeState (state) {
  return JSON.parse(Buffer.from(state, 'base64').toString())
}

async function createAccountUser (user, db) {

  const query = `
    INSERT INTO account.user (
      user_type_id,
      ${user.oauth_provider_id ? 'oauth_id' : 'username'},
      ${user.oauth_provider_id ? 'oauth_provider_id' : 'password'},
      name,
      email
    ) VALUES ($1, $2, $3, $4, $5)
    RETURNING user_id, user_type_id, name
  `

  // order here must be same as above. Be careful
  const { rows: [ client ] } = await db.query(query, [
    user.user_type_id,
    user.oauth_provider_id ? user.oauth_id : user.username,
    user.oauth_provider_id ? user.oauth_provider_id : user.password,
    user.name,
    user.email
  ])

  return client
}

module.exports = app
