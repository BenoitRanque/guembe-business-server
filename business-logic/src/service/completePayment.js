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
  let status = null

  switch (khipu_status_detail) {
    case 'pending':
      status = 'PENDING'
      break
    case 'normal':
      status = 'COMPLETED'
      break
    case 'marked-paid-by-receiver':
      status = 'COMPLETED'
      break
    case 'rejected-by-payer':
      status = 'REJECTED'
      break
    case 'marked-as-abuse':
      status = 'REJECTED'
      break
    case 'reversed':
      status = 'REVERSED'
      break
    default:
      throw new Error(`Unknown khipu_status_detail ${khipu_status_detail}`)
  }

  // if expired for more than 10 minutes, set expired
  if (new Date()) {
    status = 'EXPIRED'
  }

  const { rows: [ updatedPayment ] } = db.query(`
    UPDATE store.payment SET
      payment_id = $2,
      status = $3,
      khipu_status = $4,
      khipu_status_detail = $5,
      khipu_subject = $6,
      khipu_body = $7,
      khipu_payer_name = $8,
      khipu_payer_email = $9,
      khipu_payment_id = $10,
      khipu_payment_url = $11,
      khipu_simplified_transfer_url = $12,
      khipu_transfer_url = $13,
      khipu_webpay_url = $14,
      khipu_app_url = $15,
      khipu_ready_for_terminal = $16
    WHERE store.payment.payment_id = $1
    RETURNING payment_id, purchase_id, completed, cancelled;
  `, [
    payment_id,
    status,
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