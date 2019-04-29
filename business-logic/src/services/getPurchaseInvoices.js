module.exports = async function s (payment_id, { comprador, razonSocial }, db) {
  const { rows: details } = await db.query(`
    SELECT
      store.product.public_name AS articulo,
      store.listing_product.price AS precioUnitario,
      store.product.economic_activity AS actividadEconomica,
      SUM(store.purchase_listing.quantity * store.listing_product.quantity) AS cantidad
    FROM store.invoice
    LEFT JOIN store.purchase_listing ON store.purchase_listing.purchase_id = store.invoice.purchase_id
    LEFT JOIN store.listing_product ON store.purchase_listing.listing_id = store.listing_product.listing_id
    INNER JOIN store.product ON store.listing_product.product_id = store.product.product_id
      AND store.product.economic_activity_id = store.invoice.economic_activity_id
    WHERE store.payment.payment_id = $1
    GROUP BY store.product_product_id, store.product.public_name, store.product.economic_activity_id, store.listing_product.price;
  `, [payment_id])

  const invoices = {}

  return {
    emisor: process.env.IZI_NIT_EMISOR,
    comprador, // add buyer nit here
    razonSocial, // add buyer name here
    actividadEconomica: details[0].actividadEconomica,
    listaItems: details.map(({ articulo, precioUnitario, cantidad }) => ({ articulo, precioUnitario, cantidad }))
  }
}
