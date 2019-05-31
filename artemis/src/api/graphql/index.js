const express = require('express')
const proxy = require('http-proxy-middleware')
const cookieParser = require('cookie-parser')
const verifyCSRFToken = require('../../utils/middlewares/verifyCSRFToken')

const app = express()

app.use(cookieParser())
app.use(verifyCSRFToken)

// app.use('/business-logic', require('./business-logic'))

app.use(proxy({
  target: 'http://graphql-engine:8080/v1/graphql',
  // onProxyRes (proxyRes, req, res) {
  //   Object.keys(proxyRes.headers).forEach(function (key) {
  //     res.append(key, proxyRes.headers[key])
  //   })
  // },
  // onProxyReq (proxyReq, req, res) {
  //   Object.keys(req.headers).forEach(function (key) {
  //     proxyReq.setHeader(key, req.headers[key])
  //   })
  // },
  ignorePath: true,
  changeOrigin: true,
  cookieDomainRewrite: true,
  cookiePathRewrite: true
}))

module.exports = app