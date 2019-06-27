const express = require('express')
const cookieParser = require('cookie-parser')
const parseSession = require('middlewares/parseSession')
const requireSessionRole = require('middlewares/requireSessionRole')
const webstoreCheckout = require('services/checkout/webstoreCheckout')

const UUID_REGEX = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/

const app = express()

app.use(express.json({ extended: false }))

app.use(cookieParser())
app.use(parseSession)

app.post('/checkout', requireSessionRole(['client']), async function checkout (req, res, next) {
  try {
    const user_id = req.session.user_id
    const { client_id } = req.body

    if (!UUID_REGEX.test(client_id)) {
      throw new BadRequestError('Malformed client id')
    }

    const checkoutResponse = await webstoreCheckout({ user_id, client_id })

    res.status(200).json(checkoutResponse)
  } catch (error) {
    console.log(error)
    next(error)
  }
})

app.post('/verifypayment/:paymentId', requireSessionRole(['client']), require('./verifypayment'))

module.exports = app