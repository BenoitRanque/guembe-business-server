const express = require('express')
const session = require('express-session')
const app = express()



// app.use(express.bodyDecoder())
// app.use(express.cookieDecoder())
app.use(session({
  secret: 'hello',
  saveUninitialized: false,
  resave: false
}))


app.get('/', express.json(), async function (req, res) {
  console.log('authorizing request...')
  console.log(req.headers)
  console.log(req.body)
  req.session.visitCount = req.session.visitCount ? req.session.visitCount + 1 : 1
  console.log(req.session)

  // get session data from JWT
  res.status(200).json({
    'x-hasura-role': 'administrator',
    'x-hasura-user-id': '',
    'x-hasura-username': 'admin'
  })
})

module.exports = app