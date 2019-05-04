const { requireClientRole } = require('../../utils/session')
const updateLocalPayment = require('../../services/updateLocalPayment')
const khipu = require('../../utils/khipu')

module.exports = async function verifyPaymentStatus ({ payment_id }, ctx) {
  requireClientRole(ctx.session)
  const client_id = ctx.session['x-hasura']['x-hasura-client-id']

  // verify if owner and valid payment
  validatePaymentOwnership({ payment_id, client_id }, ctx.db)

  try {
    const khipu_payment_id = await getPaymenKhipuId({ payment_id }, ctx.db)
    const remotePayment = await khipu.getPaymentsId(khipu_payment_id)
    const updatedLocalPayment = await updateLocalPayment(payment_id, remotePayment, ctx.db)
    const status = await getPaymentStatus({ status: updatedLocalPayment.status }, ctx.db)

    return status
  } catch (error) {
    console.error(error)
    throw error
  }
}

async function validatePaymentOwnership ({ payment_id, client_id }, db) {
  // verify if valid payment id, and if payment purchase is owned by client
}

async function getPaymenKhipuId({ payment_id }, db) {
  const { rows: [ { khipu_payment_id } ] } = await db.query(`
    SELECT khipu_payment_id
    FROM store.payment
    WHERE store.payment.payment_id = $1
  `, [ payment_id ])

  return khipu_payment_id
}

async function getPaymentStatus ({ status: name }, db) {
  const { rows: [ status ] } = await db.query(`
    SELECT name, description
    FROM store.payment_status
    WHERE store.payment_status.name = $1
  `, [
    name
  ])

  return status
}