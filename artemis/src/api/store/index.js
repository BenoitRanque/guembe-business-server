const express = require('express')
const khipu = require('utils/khipu')
const cookieParser = require('cookie-parser')
const parseSession = require('middlewares/parseSession')
const requireSessionRole = require('middlewares/requireSessionRole')
const webstoreCheckout = require('services/checkout/webstoreCheckout')
const handlePaymentUpdate = require('services/payment/handlePaymentUpdate')
const getPaymenKhipuId = require('services/payment/getPaymentKhipuId')

const UUID_REGEX = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/

const app = express()

app.use(express.json({ extended: false }))

app.use(cookieParser())
app.use(parseSession)

app.post('/checkout', requireSessionRole(['client']), async function checkout (req, res, next) {
  try {
    const user_id = req.session.user_id
    const { client_id } = req.body

    if (client_id && !UUID_REGEX.test(client_id)) {
      throw new BadRequestError('Malformed client id')
    }

    const checkoutResponse = await webstoreCheckout({ user_id, client_id })

    res.status(200).json(checkoutResponse)
  } catch (error) {
    console.error(error)
    next(error)
  }
})

app.post('/verifypayment/:paymentId', requireSessionRole(['client']), async function verifyPaymentStatus (req, res, next) {
  try {
    const payment_id = req.params.paymentId
    const client_id = req.session.user_id

    if (!UUID_REGEX.test(payment_id)) {
      throw new BadRequestError('Malformed Parameter payment id')
    }

    await validatePaymentOwnership({ payment_id, client_id })

    const khipu_payment_id = await getPaymenKhipuId({ payment_id })
    console.log('hello')
    const khipuPayment = await khipu.getPaymentsId(khipu_payment_id)
    await handlePaymentUpdate({ khipuPayment })

    res.status(200).json({ payment_id })
  } catch (error) {
    console.error(error)
    next(error)
  }

  async function validatePaymentOwnership ({ payment_id, client_id }) {
    // verify if valid payment id, and if payment purchase is owned by client
  }
})

module.exports = app
