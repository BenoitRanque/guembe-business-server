const express = require('express')
const cookieParser = require('cookie-parser')
const app = express()

const parseSession = require('middlewares/parseSession')

app.get('/', cookieParser(), parseSession, function (req, res, next) {
  const grants = {
    now: new Date().toISOString()
  }

  if (!req.session) {
    // default to anonymous role
    grants['Role'] = 'anonymous'
  } else {
    switch(req.session.user_type) {
      case 'client':
        grants['Role'] = 'client'
        grants['User-Id'] = req.session.user_id
        break
      case 'staff':
        console.log('defaulting to administrator role for staff user')
        console.log('should set a role in header')
        grants['Role'] = 'administrator'
        grants['User-Id'] = req.session.user_id

        break
      default:
        return res.status(401).end()
    }
  }

  res.status(200).json(Object.keys(grants).reduce((obj, key) => {
    obj[`X-Hasura-${key}`] = grants[key]
    return obj
  }, {}))
})

module.exports = app