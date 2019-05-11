const express = require('express')
const app = express()
const izi = require('../utils/izi')

app.use(function (req, res, next) {
  // this is a security vulnerability. Make sure to authorize
  // probably good idea to check for secret in header
  const authorization = req.get('Authorization')
  console.log('Authorization header value:', authorization)
  console.log(`TODO: implment hasura hook safety, to avoid invocation from external sources`)
  next()
})

app.post('/store/invoice/insert', express.json(), async function (req, res) {
  // create invoice remotely, update locally

  const invoice = req.body.event.data.new

  let remoteInvoice = null
  let localInvoice = null

  try {
    const alreadyEmited = await invoiceAlreadyEmited(invoice.invoice_id, req.db)
    if (alreadyEmited) {
      throw new Error(`Invoice ${invoice.invoice_id} already emitted: ${JSON.stringify(invoice)}`)
    }
    const remoteInvoice = await createRemoteInvoice(invoice.invoice_id, req.db)
    const localInvoice = await updateLocalInvoice(invoice.invoice_id, remoteInvoice, req.db)
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
  // note the double quotation marks "" around the column names, to preserve upper/lowercase
  const { rows: [ information ] } = await db.query(`
    SELECT
      store.invoice.economic_activity_id AS "actividadEconomica",
      store.purchase.buyer_business_name AS "razonSocial",
      store.purchase.buyer_tax_identification_number AS "comprador"
    FROM store.invoice
    LEFT JOIN store.purchase ON store.purchase.purchase_id = store.invoice.purchase_id
    WHERE store.invoice.invoice_id = $1
  `, [ invoice_id ])

  return information
}

async function getInvoiceItems (invoice_id, db) {
  // note the double quotation marks "" around the column names, to preserve upper/lowercase
  const { rows: items } = await db.query(`
    SELECT
      store.product.public_name AS "articulo",
      store.listing_product.price AS "precioUnitario",
      SUM(store.purchase_listing.quantity * store.listing_product.quantity) AS "cantidad"
    FROM store.invoice
    LEFT JOIN store.purchase_listing ON store.purchase_listing.purchase_id = store.invoice.purchase_id
    LEFT JOIN store.listing_product ON store.purchase_listing.listing_id = store.listing_product.listing_id
    INNER JOIN store.product ON store.listing_product.product_id = store.product.product_id
      AND store.product.economic_activity_id = store.invoice.economic_activity_id
    WHERE store.invoice.invoice_id = $1 AND store.listing_product.price > 0
    GROUP BY store.product.product_id, store.product.public_name, store.listing_product.price;
  `, [ invoice_id ])

  return items.map(({ articulo, precioUnitario, cantidad }) => ({
    articulo,
    cantidad: Number(cantidad),
    precioUnitario: precioUnitario / 100
  }))
}

async function updateLocalInvoice (invoice_id, update, db) {
  // check if all update properties are valid fields
  const allowedUpdateColumns = [
    'id',
    'timestamp',
    'link'
  ]

  let updateFields = []
  let updateValues = []

  Object.keys(update).forEach(column => {
    if (allowedUpdateColumns.includes(column) && update[column] !== null) {
      updateFields.push(`izi_${column}`)
      updateValues.push(update[column])
    }
  })

  if (updateFields.length === 0) {
    throw new Error(`Atempted to update local invoice with no update columns specified`)
  }

  const { rows: [ updatedInvoice ] } = await db.query(`
    UPDATE store.invoice
    SET ${updateFields.map((column, index) => `${column} = $${index + 2}`).join(', ')}
    WHERE store.invoice.invoice_id = $1
    RETURNING invoice_id, ${updateFields.join(', ')};
  `, [
    invoice_id,
    ...updateValues
  ])

  return updatedInvoice
}

module.exports = app
