const khipu = require('../utils/khipu')
const { requireClientRole } = require('../utils/session')

async function storeCheckout ({ purchase_id, payment, invoice }, ctx) {
  // verify auth
  requireClientRole(ctx.session)
  const client_id = ctx.session['x-hasura-client-id']

  let localPayment = null
  let remotePayment = null
  let updatedLocalPayment = null

  await validatePurchase({ purchase_id, client_id, payment, invoice }, ctx)

  try {
    localPayment = await createLocalPayment({ purchase_id }, ctx)
  } catch (error) {
    console.error(error)
    throw error
  }
  try {
    remotePayment = await createRemotePayment({ localPayment, payment, invoice }, ctx)
  } catch (error) {
    console.error(error)
    throw error
  }
  try {
    updatedLocalPayment = await updateLocalPayment({ localPayment, remotePayment }, ctx)
  } catch (error) {
    console.error(error)
    throw error
  }

  const {
    payment_id
  } = localPayment
  const {
    payment_url: khipu_payment_url,
    simplified_transfer_url: khipu_simplified_transfer_url,
    transfer_url: khipu_transfer_url,
    webpay_url: khipu_webpay_url,
    app_url: khipu_app_url,
    ready_for_terminal: khipu_ready_for_terminal
  } = remotePayment

  return {
    payment_id,
    khipu_payment_url,
    khipu_simplified_transfer_url,
    khipu_transfer_url,
    khipu_webpay_url,
    khipu_app_url,
    khipu_ready_for_terminal
  }
}

async function validatePurchase({ purchase_id, client_id, payment, invoice }, { db, session }) {
  if (!invoice.nit_comprador.match(/^[0-9]*$/)) {
    throw new Error(`NIT invalido! El nit solo puede incluir caracteres de 0 a 9, pero era ${invoice.nit_comprador}`)
  }

  // validate ownership, and purchase not already locked
  const { rows: [ isOwnerAndPurchaseNotLocked ] } = await db.query(`
    SELECT EXISTS (
      SELECT 1
      FROM store.purchase
      LEFT JOIN store.purchase_listing ON store.purchase_listing.purchase_id = store.purchase.purchase_id
      WHERE store.purchase.purchase_id = $1
      AND store.purchase.client_id = $2
      AND store.purchase.locked = false
      AND COUNT(store.listing_purchase.listing_id) > 0
    );
  `, [ purchase_id, client_id ])

  if (!isOwnerAndPurchaseNotLocked) {
    throw new Error(`Compra no existente, bloqueada, o invalida`)
  }
  // validate stock
  const { rows: stockAvailable } = await db.query(`
    SELECT NOT EXISTS (SELECT 1
      FROM store.purchase_listing
        LEFT JOIN store.listing ON store.listing.listing_id = store.purchase_listing.listing_id
        LEFT JOIN store.purchase ON store.purchase.purchase_id = store.purchase_listing.purchase_id
        LEFT JOIN store.payment ON store.payment.purchase_id = store.purchase.purchase_id
        LEFT JOIN store.payment ON store.payment.payment_id = store.payment.payment_id
      WHERE NOT store.listing.available_stock = NULL
      AND (store.purchase_listing.purchase_id = $1 OR (store.purchase_id.locked = true AND NOT store.payment.cancelled = true))
      GROUP BY store.store.purchase_listing.listing_id
      HAVING SUM(store.purchase_listing.quantity) > store.listing.available_stock
      AND store.purchase_listing.purchase_id = $1
    );
  `, [ purchase_id ])

  if (!stockAvailable) {
    throw new Error(`Error de stock`)
  }

  return true
}

async function createLocalPayment ({ purchase_id }, { db }) {
  const { rows: [ localPayment ] } = await db.query(`
    INSERT INTO store.payment (purchase_id)
    VALUES ($1)
    RETURNING payment_id, amount;
  `, [ purchase_id ])

  return localPayment
}
async function createRemotePayment ({
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
    body: await getPaymentDetails(transaction_id, db),
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
async function updateLocalPayment ({
  localPayment: {
    payment_id
  },
  remotePayment: {
    payment_id: khipu_payment_id,
    payment_url: khipu_payment_url,
    simplified_transfer_url: khipu_simplified_transfer_url,
    transfer_url: khipu_transfer_url,
    webpay_url: khipu_webpay_url,
    app_url: khipu_app_url,
    ready_for_terminal: khipu_ready_for_terminal
  }
}, { db }) {
  const updatedLocalPayment = await db.query(`
    UPDATE store.payment
    SET
      store.payment.khipu_payment_id = $2
      store.payment.khipu_payment_url = $3
      store.payment.khipu_simplified_transfer_url = $4
      store.payment.khipu_transfer_url = $5
      store.payment.khipu_webpay_url = $6
      store.payment.khipu_app_url = $7
      store.payment.khipu_ready_for_terminal = $8
    WHERE store.payment.payment_id = $9
  `, [
    payment_id,
    khipu_payment_id,
    khipu_payment_url,
    khipu_simplified_transfer_url,
    khipu_transfer_url,
    khipu_webpay_url,
    khipu_app_url,
    khipu_ready_for_terminal
  ])

  return updateLocalPayment
}

async function getPaymentDetails(payment_id, db) {
  const { rows: details } = await db.query(`
    SELECT
      store.product.public_name AS product,
      SUM(store.purchase_listing.quantity * store.listing_product.quantity) AS quantity
      store.listing_product.price AS price
    FROM store.payment
    LEFT JOIN numbers_list AS listing_numbers ON listing_numbers.number <= store.purchase_listing.quantity
    LEFT JOIN store.listing_product ON store.purchase_listing.listing_id = store.listing_product.listing_id
    LEFT JOIN store.product ON store.listing_product.product_id = store.product.product_id
    WHERE store.payment.payment_id = $1
    GROUP BY store.product_product_id, store.product.public_name, store.listing_product.price;
  `, [payment_id])

  return [
    `Articulo\tPrecio\tCantidad\tSubtotal`,
    ...details.map(({ product, quantity, price }) => `${product}\t${Number(price / 100).toFixed(2)}\t${quantity}\t${(price / 100) * quantity}`)
  ].join('\n')
}

module.exports = storeCheckout