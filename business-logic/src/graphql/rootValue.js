const store_checkout = require('../services/resolveStoreCheckout')
const store_authentication = require('../services/resolveStoreAuthentication')
const staff_authentication = require('../services/resolveStaffAuthentication')

// note to self
// add mutations to manually check if payment is completed, and run the update if it is

const rootValue = {
  store_checkout,
  store_authentication,
  staff_authentication
}

module.exports = rootValue
