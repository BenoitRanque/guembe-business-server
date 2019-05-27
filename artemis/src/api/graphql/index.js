const express = require('express')
const proxy = require('http-proxy-middleware')
const cookieParser = require('cookie-parser')
const verifyCSRFToken = require('../../utils/middlewares/verifyCSRFToken')

const app = express()

app.use(cookieParser())
app.use(verifyCSRFToken)

app.use(function (req, res, next) {
  console.log('request to graphql')
  next()
})

app.use(proxy({
  target: 'http://graphql-engine:6060/v1/graphql',
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