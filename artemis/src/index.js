const express = require('express')
const helmet = require('helmet')

const port = 8080

const app = express()

app.use(helmet())

app.use('/api/v1', require('./api'))

app.listen({ port }, () => {
  console.log(`Listening on port ${port}`);
})
