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