const express = require('express')
const helmet = require('helmet')
const CORSPolicy = require('middlewares/CORSPolicy')

const port = process.env.PORT

const app = express()

app.use(helmet())
app.use(CORSPolicy)

app.use('/upload', require('./api/upload'))

app.listen({ port }, () => {
  console.log(`Listening on port ${port}`);
})
