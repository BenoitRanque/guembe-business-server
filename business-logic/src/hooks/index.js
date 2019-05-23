const express = require('express')
const app = express()

app.use('/khipu', require('./khipu'))
app.use('/hasura', require('./hasura'))
app.use('/auth', require('./auth'))

module.exports = app