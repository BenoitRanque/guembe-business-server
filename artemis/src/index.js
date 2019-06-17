const express = require('express')
const helmet = require('helmet')

const port = process.env.PORT

const app = express()

app.use(helmet())

app.use(require('./api'))

app.listen({ port }, () => {
  console.log(`Listening on port ${port}`);
})
