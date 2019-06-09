const express = require('express')
const cookieParser = require('cookie-parser')
const jwt = require('jsonwebtoken')
const uuid = require('uuid/v4')
const bcrypt = require('bcryptjs')
const { ForbiddenError, NotFoundError } = require('../../utils/errors')

const app = express()

app.use(cookieParser())

app.post('/login', express.json(), async function (req, res, next) {
  const { username = null, email = null, password } = req.body

  const query = `
    SELECT user_id, user_type_id, password
    FROM account.user
    WHERE ${username !== null ? 'username' : 'email'} = $1
  `

  const { rows: [ user ] } = await req.db.query(query, [
    username !== null ? username : email
  ])

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
      SELECT role_name
      FROM account.user_role
      LEFT JOIN account.role ON (account.user_role.role_id = account.role.role_id)
      WHERE user_id = $1
    `
    const { rows: roleRows } = await db.query(query, [user_id])


    if (roleRows.length) {
      roles.push(...roleRows.map(({ role_name }) => role_name))
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

module.exports = app
