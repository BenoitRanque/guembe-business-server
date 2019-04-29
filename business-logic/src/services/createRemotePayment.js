const khipu = require('../utils/khipu')
const getPaymentBody = require('./getPaymentBody')

module.exports = async function createRemotePayment ({
  localPayment: { payment_id, amount },
  payment: {
    payer_email,
    payer_name,
    cancel_url,
    return_url
  },
  invoice
}, db) {
  const paymentData = {
    transaction_id: payment_id,
    currency: 'BOB',
    notify_api_version: '1.3',
    amount: Number(amount / 100).toFixed(2), // we locally store payment amount in cents, but kiphu uses wholes.
    subject: 'Pago por compra en linea',
    body: await getPaymentBody(payment_id, db),
    cancel_url,
    return_url,
    notify_url: `http${process.env.NODE_ENV === 'development' ? '' : 's'}://${process.env.PUBLIC_HOSTNAME}:3000/hooks/khipu/notify`,
    payer_name,
    payer_email,
    custom: JSON.stringify({
      invoice
    })
  }
  const remotePayment = await khipu.postPayments(paymentData)

  return remotePayment
}
