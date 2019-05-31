const uuid = require('uuid/v4')

module.exports = function setCSRFToken (req, res, next) {
  console.log('setting cookie')
  res.cookie('XSRF-TOKEN', uuid(), {
    httpOnly: false,
    secure: false,
    maxAge: 5 * 60 * 1000
  })
  next()
}
