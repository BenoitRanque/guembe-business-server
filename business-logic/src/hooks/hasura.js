const express = require('express')
const app = express()

app.use(function (req, res, next) {
  // this is a security vulnerability. Make sure to authorize
  // probably good idea to check for secret in header
  console.log(`hasura hook called from ${req.headers.origin}`)
  next()
})

app.post('/store/invoice/insert', express.json(), async function (req, res) {
  // create invoice remotely, update locally

  let remoteInvoice = null
  let localInvoice = null

  try {
    const remoteInvoice = await createRemoteInvoice(data)
    const localInvoice = await updateLocalInvoice(remoteInvoice)
  } catch (error) {
    res.status(500).end()
    console.error(error)
    throw error
  }

  res.status(200).end()
})

module.exports = app


/*

1. checkout (graphql mutation)
    1. create payment locally. This locks the purchase
    2. create payment remotely. On failure atempt to delete local payment
    3. update payment locally. Failure should be rare

2. responde to payment completion (khipu hook)
    1. update payment locally. (this creates invoices locally via postgres hooks)

3. respond to invoice creation (hasura hoook)
    1. create invoice remotely
    2. update locally (if this fails, the invoice will not be available publicly as it is only avaialble through download link

      */
