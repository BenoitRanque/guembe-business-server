const express = require('express')
const helmet = require('helmet')
const CORSPolicy = require('middlewares/CORSPolicy')

const port = process.env.PORT

const app = express()

app.use(helmet())
app.use(CORSPolicy)

app.use('/auth', require('./api/auth'))
app.use('/store', require('./api/store'))
app.use('/hooks', require('./api/hooks'))
app.use('/website', require('./api/website'))

app.listen({ port }, () => {
  console.log(`Listening on port ${port}`);
})
