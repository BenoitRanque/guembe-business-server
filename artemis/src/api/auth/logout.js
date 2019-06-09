const express = require('express')

const app = express()

app.post('/logout', function (req, res, next) {
  res.clearCookie('session-auth')
  res.clearCookie('session-key')
  res.status(204).end()
})

module.exports = app