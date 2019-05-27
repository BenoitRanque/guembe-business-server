const express = require('express')
const proxy = require('http-proxy-middleware')
const cookieMiddleware = require('../../utils/middlewares/cookie')

const app = express()

app.use(cookieMiddleware, proxy({
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