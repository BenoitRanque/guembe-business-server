// hooks react to internal events
// so only accept hook calls from authorized requests
// no user authentication here since it makes no sense
const express = require('express')
const app = express()

app.use('/hasura', require('./hasura'))
app.use('/khipu', require('./khipu'))

module.exports = app
