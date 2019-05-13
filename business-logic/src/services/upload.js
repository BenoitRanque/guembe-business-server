const express = require('express')
const path = require('path')
const fs = require('fs')
const corser = require('corser')
const multer = require('multer')
const uuid = require('uuid/v4')

const PATH = '/usr/app/uploads'

const upload = multer({
  dest: PATH,
  fileFilter (req, file, callback) {
    // To reject this file pass `false`, like so:
    // callback(null, false)

    // To accept the file pass `true`, like so:
    // callback(null, true)

    // You can always pass an error if something goes wrong:
    // callback(new Error('I don\'t have a clue!'))

    console.log('uploading file:', file)

    callback(null, true)
  },
  storage: multer.diskStorage({
    destination: PATH,
    filename (req, file, callback) {
      callback(null, uuid())
    }
  })
})

const app = express()

app.use(corser.create({
  requestHeaders: corser.simpleRequestHeaders.concat(['Authorization'])
}))

app.post('/', upload.single('file'), (req, res) => {

  console.log('file uploaded', req.file, req.body)

  res.status(200).end()
})

module.exports = app
