// auth service
// responsabilities:
// verify auth on hasura api requests
// authenticate users and set cookies
// this includes OAuth
// disambiguate client and staff users
// use double cookies strategy

// JWT_REGEX = /([a-zA-Z0-9]+)\.([a-zA-Z0-9]+)\.([a-zA-Z0-9]+)/

const express = require('express')
const app = express()

app.use(async function (req, res, next) {
  // two stategies

  // authorization header
  // used for unlimited access
  // usefull for api etc

  // proppert auth
  // three cookies, one header
  // cookie 1: jwt signature
  res.cookie('signature', 'JWT_SIGNATURE', {
    expires: 0, // create session cookie
    // secure: true, // in production
    httpOnly: true
  })
  res.cookie('payload', 'JWT_HEADER_BODY', {
    httpOnly: false, // this data is accessed by the frontend to define view permissions etc
    // secure: true, // in production
    maxAge: 30 * 60 * 1000 // 30 minutes
  })
  res.cookie('csrf', 'RANDOM_NUMBER', {
    httpOnly: false, // this data is accessed by the front end and sent as a header
    // secure: true, // in production
    maxAge: 30 * 60 * 1000 // 30 minutes
  })
  // check if csrf in header matches csrf in cookie
  // if authorization header exists, validate it, and use it as session
  // else if cookies exist
  req.get('Authorization')
  if (req.cookies.signature) {
    // user has signed
  }

})

app.post('/authenticate', express.json(), function (req, res, next) {
  const username = 'admin'
  const user_id = ''
  const roles = ['role']


})

app.get('/auth', function (req, res) {
  if (req.session) {
    res.status(200).json({
      'x-hasura-role': ''
    })
  }
  // hasura webhook
  // if no session is present,
  // read cookies
  // validate cookie
  // return hasura role and additional headers
})

function createToken () {
  return jwt.sign({
    xsrfToken: uuid(),
    // session is null if anonymous/not signed in
    session: {
      user_id
      username
      roles
    }
  }, SECRET)
}

function setSessionCookies (res, token) {
  const [ tokenHeader, tokenBody, tokenSignature ] = token.split('.')

  res.cookie('payload', `${tokenHeader}.${tokenBody}`, {
    httpOnly: false, // this data is accessed by the frontend to define view permissions etc
    // secure: true, // in production
    maxAge: 30 * 60 * 1000 // 30 minutes
  })
  res.cookie('signature', tokenSignature, {
    expires: 0, // create session cookie
    // secure: true, // in production
    httpOnly: true
  })
}

function validateToken (req) {
  const token = `${req.cookies.public}.${req.cookies.private}`
  const xsrfToken = req.get('X-CSRF-TOKEN')

  const session = jwt.verify(token, SECRET)

  if (session.xsrfToken !== xsrfToken) {
    // houston we have a problem
  }

  req.session = session

  // happy
}

// names
/*
x-csrf-token
x-hasura-role


*/

// cookies
// private
// public



module.exports = app
