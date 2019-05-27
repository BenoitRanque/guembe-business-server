const uuid = require('uuid/v4')

module.exports = function setCSRFToken (req, res, next) {
  res.cookie('XSRF-TOKEN', uuid(), {
    httpOnly: false,
    secure: false
  })
  next()
}
