const corser = require('corser')

// Cross Origin Resource Sharing policy
// Set headers required for cross origin requests


module.exports = corser.create({
  origins: ['https://chuturubi.com', 'http://localhost:8080', 'http://localhost:8081', 'http://localhost:8082'],
  requestHeaders: corser.simpleRequestHeaders.concat(['Authorization']),
  responseHeaders: corser.simpleResponseHeaders.concat(['']),
  supportsCredentials: true
})


// const cors = require('cors')
// const express = require('express')
// const { ForbiddenError } = require('../errors')

// const app = express()

// const options = {
//   methods: ['GET','HEAD','PUT','PATCH','POST','DELETE'],
//   allowedHeaders: ['Authorization'],
//   exposedHeaders: [],
//   credentials: true,
//   preflightContinue: false,
//   optionsSuccessStatus: 204,
//   origin (origin, callback) {
//     if (['https://chuturubi.com', 'http://localhost:8081'].includes(origin)) {
//       callback(null, true)
//     } else {
//       callback(new ForbiddenError())
//     }
//   }
// }

// // app.options('*', cors(options))

// app.use(cors(options))

// module.exports = app
