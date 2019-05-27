const express = require('express')
const cookieParser = require('cookie-parser')

const app = express()

app.use(cookieParser())

app.use(function cookieMiddleware (req, res, next) {
  let timesVisited = req.cookies && req.cookies.visits ? req.cookies.visits.timesVisited + 1 : 1
  res.cookie('visits', {
    timesVisited
  }, {
    httpOnly: false,
    secure: false,
    maxAge: 30 * 60 * 1000
  })
  console.log(`You have visited this page ${timesVisited} times`)
  next()
})

module.exports = app