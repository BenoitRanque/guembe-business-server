module.exports = async function getPaymentBody(payment_id, db) {
  const { rows: details } = await db.query(`
    SELECT
      store.product.public_name AS product,
      store.listing_product.price AS price,
      SUM(store.purchase_listing.quantity * store.listing_product.quantity) AS quantity
    FROM store.payment
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
