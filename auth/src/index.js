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

app.post('/authenticate', function (req, res, next) {

})

app.get('/auth', function (req, res) {
  // hasura webhook
  // if no session is present,
  // read cookies
  // validate cookie
  // return hasura role and additional headers
})

module.exports = app
