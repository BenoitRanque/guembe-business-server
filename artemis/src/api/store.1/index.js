const express = require('express')
const parseSession = require('middlewares/parseSession')
const requireSessionRole = require('middlewares/requireSessionRole')
const cookieParser = require('cookie-parser')

const app = express()

app.use(express.json({ extended: false }))

app.use(cookieParser())
app.use(parseSession)

app.post('/checkout/:purchaseId', requireSessionRole(['client']), require('./checkout'))

app.post('/verifypayment/:paymentId', requireSessionRole(['client']), require('./verifypayment'))

module.exports = app