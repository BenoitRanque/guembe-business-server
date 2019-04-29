// IMPORTANT: 3 error types:
// user generated (invalid input)
// api errors (probably conection errors)
// internal errors (those should not happen. Handle anyways)

// NOTES
// most operations to be done in three stages:
// 1. get local information. Lock purchase if required. Do not create reccords locally (yet)
//    this step must make sure that step 3 will be successful baring a catastrophic conection loss
//    possibly make this a one time operation by requiring the purchase not be locked yet?
// 2. create record remotely. Keep local information in memory
// 3. create local reccord, using local & remote information

// actually, use same aproach as bellow. Three states.
// four stage
// validation. In this step we give friendly errors.

// ERROR handling: implement error log table.
// step 1 errors are expected, as they are validation errors. Validations errors are user errros and as such do not go to log
// step 2 errors are conection/external api errors. They will go to log, but user can simply try again
// step 3 errors are internal errors. They should never happen. Log with high priority. Possibly lock related reccords (impossible if lost conection)

// Notificatons
// set flag?, respond immediately with 200 to avoid timeout, if operation takes more than 30 seconds
// create local invoices. Create mutation to regenerate manually an invoice by id.
// as this is automated, all errors go to log.



const express = require('express')
const app = express()
const updateLocalPayment = require('../services/updateLocalPayment')
const khipu = require('../utils/khipu')

app.post('/notify', async function (req, res) {
  const { notification_token, api_version } = req.query
  let updatedPayment = null
  try {
    if (api_version !== '1.3') {
      res.status(500).end()
      throw new Error(`Unexpected Khipu Notification Api Version: ${api_version}`)
    }
    updatedRemotePayment = await khipu.getPayments({ notification_token })
    updatedLocalPayment = await updateLocalPayment(updatedRemotePayment.transaction_id, updatedRemotePayment, req.db)
    // respond immediately
    res.status(200).end('Ok')
  } catch (error) {
    console.error(error)
    // note: respond with error code 400 to prevent khipu from notifying again
    res.status(500).end()
    throw error
  }

  try {
    // TODO: check if invoices not aready emitted to avoid sending them twice
    if (updatedPayment.status === 'COMPLETED' && !updatedPayment.cancelled) {
      await createPurchaseInvoices(updatedPayment.purchase_id, req.db)
    }

    const { emisor, razonSocial } = JSON.parse(updatedRemotePayment.custom).invoice
    const invoicesData = await getPurchaseInvoices(updatedLocalPayment.payment_id, { emisor, razonSocial }, req.db)

    const invoices = await Promise.all(invoicesData.map(async invoice => {
      let remoteInvoice = null
      try {
        remoteInvoice = await izi.facturas(invoice)
      } catch (error) {
        console.error
        throw Error(``)
      }
      try {
        
      } catch (error) {
        
      }
    }))
    let orginalArray = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    let copyArray = []

    try {
      await Promise.all([0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map(async number => {
        await new Promise(resolve => setTimeout(resolve, Math.floor(Math.random() * 500)))
        if (number === 0) throw new Error(`Interupted things`)
        copyArray.push(number)
      }))
    } catch (error) {
      console.error('an error was thrown')
    }
    console.log(orginalArray.reduce((subtotal, number) => subtotal + number, 0))
    console.log(copyArray.reduce((subtotal, number) => subtotal + number, 0))

  } catch (error) {
    console.error(error)
    throw error
  }
})

module.exports = app