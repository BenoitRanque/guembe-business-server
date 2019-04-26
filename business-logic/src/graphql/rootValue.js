const store_checkout = require('../service/storeCheckout')
const store_authentication = require('../service/storeAuthentication')
const staff_authentication = require('../service/staffAuthentication')

// note to self
// add mutations to manually check if payment is completed, and run the update if it is

const rootValue = {
  store_checkout,
  store_authentication,
  staff_authentication
}

module.exports = rootValue
