const express = require('express')
const app = express()
const completePayment = require('../service/completePayment')

app.post('/notify', async function (req, res) {
  const { notification_token, api_version } = req.query

  try {
    if (api_version !== '1.3') {
      res.status(500).end()
      throw new Error(`Unexpected Khipu Notification Api Version: ${api_version}`)
    }
    await completePayment(notification_token, req.db)
    res.status(200).end('Ok')
  } catch (error) {
    console.error(error)
    // note: respond with error code 400 to prevent khipu from notifying again
    res.status(500).end()
    throw(error)
  }
})

module.exports = app