module.exports = async function s (payment_id, { comprador, razonSocial }, db) {
  const { rows: details } = await db.query(`
    SELECT
      store.product.public_name AS articulo,
      store.listing_product.price AS precioUnitario,
      store.product.taxable_activity_id AS actividadEconomica,
      SUM(store.purchase_listing.quantity * store.listing_product.quantity) AS cantidad
    FROM store.payment
    LEFT JOIN store.purchase_listing ON store.purchase_listing.purchase_id = store.payment.purchase_id
    LEFT JOIN store.listing_product ON store.purchase_listing.listing_id = store.listing_product.listing_id
    LEFT JOIN store.product ON store.listing_product.product_id = store.product.product_id
    WHERE store.payment.payment_id = $1
    GROUP BY store.product_product_id, store.product.public_name, store.product.taxable_activity_id, store.listing_product.price;
  `, [payment_id])

  const invoices = {}

  details.forEach(({
    articulo,
    precioUnitario,
    actividadEconomica,
    cantidad
  }) => {
    if (!invoices[String(actividadEconomica)]) {
      invoices[String(actividadEconomica)] = {
        emisor: process.env.IZI_NIT_EMISOR,
        comprador, // add buyer nit here
        razonSocial, // add buyer name here
        actividadEconomica,
        listaItems: []
      }
    }
    invoices[String(actividadEconomica)].listaItems.push({ articulo, precioUnitario, cantidad })
  })

  return Object.values(invoices)
}
