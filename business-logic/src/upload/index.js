const express = require('express')
const path = require('path')
const fs = require('fs')
const corser = require('corser')
const multer = require('multer')
const uuid = require('uuid/v4')
const { requireRoleMiddleware, getUserId } = require('../utils/session')

const upload = multer({
  fileFilter (req, file, callback) {
    // To reject this file pass `false`, like so:
    // callback(null, false)

    // To accept the file pass `true`, like so:
    // callback(null, true)

    // You can always pass an error if something goes wrong:
    // callback(new Error('I don\'t have a clue!'))

    if (file.mimetype.match(/^image\//)) {
      callback(null, true)
    } else {
      callback(null, false)
    }
  },
  storage: multer.diskStorage({
    destination: `${process.env.FILE_UPLOAD_DIRECTORY}/listing/image`,
    filename (req, file, callback) {
      callback(null, uuid())
    }
  })
})

const app = express()

app.use(corser.create({
  requestHeaders: corser.simpleRequestHeaders.concat(['Authorization'])
}))

app.post('/listing/image/:listing_id', requireRoleMiddleware(['administrator']), upload.single('image'), async (req, res) => {
  const userId = getUserId(req)

  const { filename, originalname, path, mimetype, size, encoding } = req.file

  const query = `
    INSERT INTO store.listing_image
      (image_id, name, path, type, size, encoding, listing_id, created_by_user_id, updated_by_user_id)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
  `
  const parameters = [
    filename,
    originalname,
    path,
    mimetype,
    size,
    encoding,
    req.params.listing_id,
    userId,
    userId
  ]

  try {
    await req.db.query(query, parameters)

    res.status(200).end()
  } catch (error) {
    console.error(error)

    fs.unlinkSync(req.file.path)

    res.status(500).end()
  }
})

app.get('/listing/image', async (req, res) => {
  const { image_id, listing_id } = req.query

  if (!image_id && !listing_id) {
    return res.status(400).send(`Malformed query: please supply either the image_id or the listing_id parameter`)
  }

  const query = `
    SELECT
      store.listing_image.type,
      store.listing_image.size,
      store.listing_image.path
    FROM store.listing_image
    WHERE ${image_id ? 'store.listing_image.image_id' : 'store.listing_image.listing_id'} = $1
  `
  const parameters = [
    image_id ? image_id : listing_id
  ]

  try {
    const { rows: [ image ] } = await req.db.query(query, parameters)

    if (!image) {
      return res.status(404).send('File Not Found')
    }

    res.sendFile(image.path, {
      headers: {
        'Content-Type': image.type,
        'Content-Length': image.size
      }
    })
  } catch (error) {
    console.error(error)

    res.status(500).end()
  }
})

module.exports = app
