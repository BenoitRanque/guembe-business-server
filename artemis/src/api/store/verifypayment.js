const updateLocalPayment = require('services/updateLocalPayment')
const khipu = require('utils/khipu')
const { BadRequestError, InternalServerError } = require('utils/errors')

const UUID_REGEX = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/

module.exports = async function verifyPaymentStatus (req, res, next) {
  const payment_id = req.params.paymentId
  const client_id = req.session.user_id

  if (!UUID_REGEX.test(payment_id)) {
    return next(new BadRequestError('Malformed Parameter payment id'))
  }
  // verify if owner and valid payment
  try {
    validatePaymentOwnership({ payment_id, client_id }, req.db)
  } catch (error) {
    return next(new BadRequestError(error.message))
  }

  try {
    const khipu_payment_id = await getPaymenKhipuId({ payment_id }, req.db)
    const remotePayment = await khipu.getPaymentsId(khipu_payment_id)
    const updatedLocalPayment = await updateLocalPayment(payment_id, remotePayment, req.db)
    const status = await getPaymentStatus({ status: updatedLocalPayment.status }, req.db)

    res.status(200).json(status)
  } catch (error) {
    console.error(error)
    next(new InternalServerError(error.message))
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