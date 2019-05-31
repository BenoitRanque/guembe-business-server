const express = require('express')
const app = express()

app.use('/auth', require('./auth'))
app.use('/event', require('./event'))

module.exports = app