const khipu = require('../utils/khipu')
const izi = require('../utils/izi')

async function completePayment(notification_token, db) {
  let remotePayment = null
  let updatedLocalPayment = null

  try {
    remotePayment = await khipu.getPayments(notification_token, db)
  } catch (error) {
    console.error(error)
    throw error
  }

  try {
    updatedLocalPayment = await updatePayment(remotePayment, db)
  } catch (error) {
    console.error(error)
    throw error
  }

  try {
    invoices = await createInvoices(updatedLocalPayment, db)
  } catch (error) {
    console.error(error)
    throw error
  }
  // TODO: notify end user

  return updatedLocalPayment
}

async function updatePayment ({
  transaction_id: payment_id,
  status: khipu_status,
  status_detail: khipu_status_detail,
  subject: khipu_subject,
  body: khipu_body,
  payer_name: khipu_payer_name,
  payer_email: khipu_payer_email,
  payment_id: khipu_payment_id,
  payment_url: khipu_payment_url,
  simplified_transfer_url: khipu_simplified_transfer_url,
  transfer_url: khipu_transfer_url,
  webpay_url: khipu_webpay_url,
  app_url: khipu_app_url,
  ready_for_terminal: khipu_ready_for_terminal
}, db) {
  const { rows: updatedPayment } = db.query(`
    UPDATE store.payment SET
      payment_id = $2,
      completed = $3,
      cancelled = $4,
      khipu_status = $5,
      khipu_status_detail = $6,
      khipu_subject = $7,
      khipu_body = $8,
      khipu_payer_name = $9,
      khipu_payer_email = $10,
      khipu_payment_id = $11,
      khipu_payment_url = $12,
      khipu_simplified_transfer_url = $13,
      khipu_transfer_url = $14,
      khipu_webpay_url = $15,
      khipu_app_url = $16,
      khipu_ready_for_terminal = $17
    WHERE store.payment.payment_id = $1;
  `, [
    payment_id,
    false, // completed
    false, // cancelled
    khipu_status,
    khipu_status_detail,
    khipu_subject,
    khipu_body,
    khipu_payer_name,
    khipu_payer_email,
    khipu_payment_id,
    khipu_payment_url,
    khipu_simplified_transfer_url,
    khipu_transfer_url,
    khipu_webpay_url,
    khipu_app_url,
    khipu_ready_for_terminal
  ])

  return updatedPayment
}

async function createInvoices (updatedLocalPayment, db) {

}

module.exports = completePayment