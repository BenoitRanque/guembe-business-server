// upload service
// handle image upload
// also handle image delete

const express = require('express')

const app = express()

app.post('/upload/:format')
app.post('/remove/')

/*
things i need

auth webhook
  fast
  independent
  used by hasura before all queries

hasura event handler
  really should not be own category

domain logic
  custom logic

respond to khipu notifications

graphql schema for custom operations

internal event handler
external event handler

internal auth

graphql schema

*/



module.exports = app