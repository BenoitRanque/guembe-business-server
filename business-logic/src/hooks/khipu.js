const express = require('express')
const app = express()
const completePayment = require('../service/completePayment')

app.post('/notify', async function (req, res) {
  const { notification_token, api_version } = req.query
  let updatedPayment = null
  try {
    if (api_version !== '1.3') {
      res.status(500).end()
      throw new Error(`Unexpected Khipu Notification Api Version: ${api_version}`)
    }
    updatedPayment = await updatePaymentFromToken(notification_token, req.db)

    // respond immediately
    res.status(200).end('Ok')
  } catch (error) {
    console.error(error)
    // note: respond with error code 400 to prevent khipu from notifying again
    res.status(500).end()
    throw error
  }

  try {
    if (updatedPayment.completed && !updatedPayment.cancelled) {
      await createPurchaseInvoices(updatedPayment.purchase_id, req.db)
    }
  } catch (error) {
    console.error(error)
    throw error
  }
})

module.exports = app