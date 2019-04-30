const express = require('express')
const app = express()

app.use(function (req, res, next) {
  // this is a security vulnerability. Make sure to authorize
  // probably good idea to check for secret in header
  console.log(`hasura hook called from ${req.headers.origin}`)
  const authorization = req.get('Authorization')
  console.log('Authorization header value:', authorization)
  next()
})

app.post('/store/invoice/insert', express.json(), async function (req, res) {
  // create invoice remotely, update locally

  const {  } = req.body

  let remoteInvoice = null
  let localInvoice = null

  try {
    const remoteInvoice = await createRemoteInvoice(invoice_id, req.db)
    const localInvoice = await updateLocalInvoice(invoice_id, remoteInvoice)
  } catch (error) {
    res.status(500).end()
    console.error(error)
    throw error
  }

  res.status(200).end()
})

async function createRemoteInvoice (invoice_id, db) {
  const { comprador, razonSocial, actividadEconomica } = await getInvoiceInformation(invoice_id, db)
  const listaItems = await getInvoiceItems(invoice_id, db)

  const { factura } = await izi.facturas({
    emisor: process.env.IZI_NIT_EMISOR,
    comprador,
    razonSocial,
    actividadEconomica,
    listaItems
  })

  return factura
}

async function invoiceAlreadyEmited (invoice_id, db) {
  const { rows } = await db.query(`
    SELECT 1
    FROM store.invoice
    WHERE store.invoice.invoice_id = $1
    AND store.invoice.izi_id IS NOT NULL
  `, [ invoice_id ])

  return rows.length > 0
}

async function getInvoiceInformation (invoice_id, db) {
  const { rows: [ information ] } = await db.query(`
    SELECT
      store.invoice.economic_activity_id AS actividadEconomica,
      store.purchase.buyer_business_name AS razonSocial,
      store.purchase.buyer_tax_identification_number AS comprador
    FROM store.invoice
    LEFT JOIN store.purchase ON store.purchase.purchase_id = store.invoice.purchase_id
    WHERE store.invoice.invoice_id = $1
  `, [ invoice_id ])
}

async function getInvoiceItems (invoice_id, db) {
  const { rows: items } = await db.query(`
    SELECT
      store.product.public_name AS articulo,
      store.listing_product.price AS precioUnitario,
      SUM(store.purchase_listing.quantity * store.listing_product.quantity) AS cantidad
    FROM store.invoice
    LEFT JOIN store.purchase_listing ON store.purchase_listing.purchase_id = store.invoice.purchase_id
    LEFT JOIN store.listing_product ON store.purchase_listing.listing_id = store.listing_product.listing_id
    INNER JOIN store.product ON store.listing_product.product_id = store.product.product_id
      AND store.product.economic_activity_id = store.invoice.economic_activity_id
    WHERE store.invoice.invoice_id = $1
    GROUP BY store.product_product_id, store.product.public_name, store.listing_product.price;
  `, [ invoice_id ])

  return items
}

module.exports = app
