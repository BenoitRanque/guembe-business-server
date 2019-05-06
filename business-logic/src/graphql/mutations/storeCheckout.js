
const { requireClientRole } = require('../../utils/session')
const updateLocalPayment = require('../../services/updateLocalPayment')
const khipu = require('../../utils/khipu')

module.exports = async function storeCheckout ({ purchase_id, payment }, ctx) {
  // verify auth
  requireClientRole(ctx.session)
  const client_id = ctx.session['x-hasura']['x-hasura-client-id']

  let localPayment = null
  let remotePayment = null
  let updatedLocalPayment = null

  await validateCheckoutInput({ purchase_id, client_id, payment }, ctx.db)

  try {
    localPayment = await createLocalPayment({ purchase_id }, ctx.db)
  } catch (error) {
    console.error(error)
    throw error
  }

  try {
    remotePayment = await createRemotePayment({ localPayment, payment }, ctx.db)
  } catch (error) {
    console.error(error)
    try {
      await ctx.db.query(`DELETE FROM store.payment WHERE store.payment.payment_id = $1;`, [ localPayment.payment_id ])
    } catch (error) {
      console.error(error)
    }
    throw new Error(`Error creando el pago remotamente. Por favor intentar de nuevo mas tarde`)
  }

  try {
    updatedLocalPayment = await updateLocalPayment(localPayment.payment_id, remotePayment, ctx.db)
  } catch (error) {
    console.error(error)
    throw error
  }

  return updatedLocalPayment
}

async function validateCheckoutInput({ purchase_id, client_id, payment }, db) {
  // validate ownership, and purchase not already locked
  const { rows: [ { exists: isOwnerAndPurchaseNotLocked }] } = await db.query(`
    SELECT EXISTS (
      SELECT 1
      FROM store.purchase
      LEFT JOIN store.purchase_listing ON store.purchase_listing.purchase_id = store.purchase.purchase_id
      WHERE store.purchase.purchase_id = $1
      AND store.purchase.client_id = $2
      AND store.purchase.locked = false
      GROUP BY store.purchase.purchase_id
      HAVING COUNT(store.purchase_listing.listing_id) > 0
    );
  `, [ purchase_id, client_id ])

  if (!isOwnerAndPurchaseNotLocked) {
    throw new Error(`Compra no existente, bloqueada, o invalida`)
  }
  // validate stock

  const { rows: listingsWithoutStock } = await db.query(`
    SELECT store.listing.public_name AS public_name
    FROM store.purchase_listing
        LEFT JOIN store.listing ON store.listing.listing_id = store.purchase_listing.listing_id
        LEFT JOIN store.purchase ON store.purchase.purchase_id = store.purchase_listing.purchase_id
        LEFT JOIN store.payment ON store.payment.purchase_id = store.purchase.purchase_id
    WHERE store.listing.available_stock IS NOT NULL
    AND (store.purchase_listing.purchase_id = $1 OR (store.purchase.locked = true AND store.payment.status IN ('PENDING', 'COMPLETED')))
    GROUP BY store.purchase_listing.listing_id, store.listing.public_name, store.listing.available_stock, store.purchase_listing.purchase_id
    HAVING SUM(store.purchase_listing.quantity) > store.listing.available_stock
    AND store.purchase_listing.purchase_id = $1;
  `, [ purchase_id ])

  if (listingsWithoutStock.length) {
    throw new Error(`Error de stock en ${listingsWithoutStock.map(({ public_name }) => public_name).join(', ')}`)
  }

  return true
}


async function createLocalPayment ({ purchase_id }, db) {
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
  }
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
    picture_url: `http${process.env.NODE_ENV === 'development' ? '' : 's'}://${process.env.PUBLIC_HOSTNAME}:80/icons/isologo.png`,
    payer_name,
    payer_email,
    custom: JSON.stringify({})
  }
  console.log('creating remote payment')
  const remotePayment = await khipu.postPayments(paymentData)
  console.log('created remote payment')

  return remotePayment
}

async function getPaymentBody(payment_id, db) {
  const { rows: details } = await db.query(`
    SELECT
      store.product.public_name AS product,
      store.listing_product.price AS price,
      SUM(store.purchase_listing.quantity * store.listing_product.quantity) AS quantity
    FROM store.payment
    LEFT JOIN store.purchase_listing ON store.payment.purchase_id = store.purchase_listing.purchase_id
    LEFT JOIN store.listing_product ON store.purchase_listing.listing_id = store.listing_product.listing_id
    LEFT JOIN store.product ON store.listing_product.product_id = store.product.product_id
    WHERE store.payment.payment_id = $1
    GROUP BY store.product.product_id, store.product.public_name, store.listing_product.price;
  `, [payment_id])

  return [
    `Articulo\tPrecio\tCantidad\tSubtotal`,
    ...details.map(({ product, quantity, price }) => `${product}\t${Number(price / 100).toFixed(2)}\t${quantity}\t${(price / 100) * quantity}`)
  ].join('\n')
}
