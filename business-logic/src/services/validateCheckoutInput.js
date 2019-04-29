module.exports = async function validateCheckoutInput({ purchase_id, client_id, payment, invoice }, db) {
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
