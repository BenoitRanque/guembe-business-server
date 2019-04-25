const express = require('express')
const { sessionMiddleware } = require('./utils/session')
const db = require('./utils/db')

express.request.db = db
const app = express()
const port = 3000

app.use(sessionMiddleware)
app.use('/graphql', require('./graphql'))

app.listen({ port }, () => {
  console.log(`Listening on port ${port}`);
})

// const izi = require('./utils/izi')

// izi.facturas({
//   emisor: '122103025',
//   comprador: '123456789',
//   razonSocial: 'TEST SALE',
//   sucursal: 1,
//   actividadEconomica: 71409,
//   listaItems: [
//     {
//       articulo: 'Item de Prueba',
//       cantidad: 1,
//       precioUnitario: 100
//     }
//   ]
// })