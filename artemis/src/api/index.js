const express = require('express')
const CORSPolicy = require('../utils/middlewares/CORSPolicy')
const setCSRFToken = require('../utils/middlewares/setCSRFToken')
const db = require('../utils/db')
const cookieParser = require('cookie-parser')

express.request.db = db

const app = express()

app.use(CORSPolicy)
// app.use(setCSRFToken)

// app.use(cookieParser(), function (req, res, next) {
//   console.log(req.cookies)
//   next()
// })
// // empty response. Header set by middleware above
// app.get('/csrftoken', function (req, res, next) {
//   res.status(204).end()
// })


app.use('/auth', require('./auth'))
app.use('/store', require('./store'))

app.use('/graphql', require('./graphql'))
app.use('/image', require('./image'))
app.use('/hooks', require('./hooks'))

module.exports = app

// services are publicly available api
// any request here will be marked with a cookie
// said cookie may or may not contain a session

/*

webpage tables

image

image size/format

card
banner
background
slide

xl
lg
md
sm
xs
thumbnail
placeholder

element
format
image
title
subtitle
body


one table per element type...

schema names
  acounting
    invoice
    payment
  sales
    sale
    sale_item
  website
    image
      name
      format
      placeholder
    page
      name UNIQUE
      parent REFERENCES name nullable
      UNIQUE(name, parent) // ensure parent page only has one child page named this
      title
      subtitle
      banner (image)
      background (image)
    page_card
      page
      index
      image
      link_to (page)
    page_slide
      page
      index
      image
      link_to (page)
  webstore
    product
  hotel
    reservation
    room
  client
    account
    personal information
    nationality (required)
  auth
    credentials
    token
    account (client, user)
    authentication_provider
    role




Image
image sizes

*/