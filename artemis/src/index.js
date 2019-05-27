const express = require('express')
// const { sessionMiddleware } = require('./utils/session')
// const db = require('./utils/db')

// express.request.db = db
const app = express()
const port = 9090

// app.use(sessionMiddleware)
app.use('/api/v1', require('./api'))

app.listen({ port }, () => {
  console.log(`Listening on port ${port}`);
})
