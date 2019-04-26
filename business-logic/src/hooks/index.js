const express = require('express')
const app = express()

app.use('/khipu', require('./khipu'))

module.exports = app