const express = require('express')

const app = express()

app.use('/swapPageSections', require('./swapPageSections'))
app.use('/swapSectionElements', require('./swapSectionElement'))

module.exports = app
