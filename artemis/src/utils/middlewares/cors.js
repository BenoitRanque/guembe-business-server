const corser = require('corser')

module.exports = corser.create({
  requestHeaders: corser.simpleRequestHeaders.concat(['Authorization']),
  responseHeaders: corser.simpleResponseHeaders.concat(['hello'])
})
