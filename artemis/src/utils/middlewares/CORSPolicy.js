const corser = require('corser')

// Cross Origin Resource Sharing policy
// Set headers required for cross origin requests

module.exports = corser.create({
  requestHeaders: corser.simpleRequestHeaders.concat(['Authorization', 'X-XSRF-TOKEN']),
  responseHeaders: corser.simpleResponseHeaders.concat(['']),
  supportsCredentials: true
})
