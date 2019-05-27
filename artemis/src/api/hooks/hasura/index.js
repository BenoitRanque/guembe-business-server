const express = require('express')
const app = express()

app.use(function (req, res, next) {
  console.log('calling hasura webhook')
  next()
})

app.use('/auth', require('./auth'))

module.exports = app