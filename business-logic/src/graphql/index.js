const express = require('express')
const graphqlHTTP = require('express-graphql')

const schema = require('./schema')
const rootValue = require('./rootValue')

const app = express()

app.use(graphqlHTTP(request => ({
  schema,
  rootValue,
  graphiql: true,
  context: request
})))

module.exports = app