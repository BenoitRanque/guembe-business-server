
const { BadRequestError, InternalServerError } = require('utils/errors')
const webstoreCheckout = require('services/checkout/webstoreCheckout')

const UUID_REGEX = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/

const express = require('express')
const app = express()

app.post('/checkout', express.json({}), async function checkout (req, res, next) {
  try {
    const khipuPayment = await webstoreCheckout({ user_id, client_id, return_url, cancel_url })
    console.log(khipuPayment)
  } catch (error) {
    next(error)
  }
})

module.exports = app
