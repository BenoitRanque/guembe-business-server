const { requireClientRole } = require('../utils/session')
const validateCheckoutInput = require('./validateCheckoutInput')
const createLocalPayment = require('./createLocalPayment')
const createRemotePayment = require('./createRemotePayment')
const updateLocalPayment = require('./updateLocalPayment')

module.exports = async function storeCheckout ({ purchase_id, payment, invoice }, ctx) {
  // verify auth
  requireClientRole(ctx.session)
  const client_id = ctx.session['x-hasura-client-id']

  let localPayment = null
  let remotePayment = null
  let updatedLocalPayment = null

  await validateCheckoutInput({ purchase_id, client_id, payment, invoice }, ctx.db)

  try {
    localPayment = await createLocalPayment({ purchase_id }, ctx.db)
  } catch (error) {
    console.error(error)
    throw error
  }
  try {
    remotePayment = await createRemotePayment({ localPayment, payment, invoice }, ctx.db)
  } catch (error) {
    console.error(error)
    throw error
  }
  try {
    updatedLocalPayment = await updateLocalPayment({ localPayment, remotePayment }, ctx.db)
  } catch (error) {
    console.error(error)
    throw error
  }

  return updatedLocalPayment
}
