const updateLocalPayment = require('services/updateLocalPayment')
const khipu = require('utils/khipu')
const express = require('express')

const app = express()

app.post('/notify', express.urlencoded({ extended: false }), async function (req, res) {
  const { notification_token, api_version } = req.body
  let updatedRemotePayment = null
  let updatedLocalPayment = null
  try {
    if (api_version !== '1.3') {
      res.status(500).end()
      throw new Error(`Unexpected Khipu Notification Api Version: ${api_version}`)
    }
    updatedRemotePayment = await khipu.getPayments({ notification_token })
    updatedLocalPayment = await updateLocalPayment(updatedRemotePayment.transaction_id, updatedRemotePayment, req.pg)
    // respond immediately
    res.status(200).end('Ok')
  } catch (error) {
    console.error(error)
    // note: respond with error code 400 to prevent khipu from notifying again
    res.status(500).end()
    throw error
  }
})

module.exports = app