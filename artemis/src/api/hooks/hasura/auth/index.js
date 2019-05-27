const express = require('express')
const cookieParser = require('cookie-parser')
const app = express()

app.get('/', cookieParser(), express.json(), function (req, res, next) {
  console.log('calling webhook')
  console.log(req.body)
  console.log(req.headers)
  console.log(req.cookies)
  res.status(200).json({
    'X-Hasura-Role': 'admin'
  })
})

module.exports = app