const express = require('express')
const path = require('path')
const fs = require('fs')
const multer = require('multer')

const parseSession = require('middlewares/parseSession')
const requireSessionRole  = require('middlewares/requireSessionRole')
const cookieParser = require('cookie-parser')
const getImageSizes = require('services/image/getImageSizes')
const createImageSizes = require('services/image/createImageSizes')
const getPlaceholder = require('services/image/getPlaceholder')

const { BadRequestError } = require('utils/errors')

const pg = require('utils/pg')

// create image directory if not exists
if (!fs.existsSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image`)) {
  fs.mkdirSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image`, { recursive: true })
}

const upload = multer({
  limits: {
    fieldSize: 20 * 1024 * 1024 // 20 mb
  },
  fileFilter (req, file, callback) {
    // To reject this file pass `false`, like so:
    // callback(null, false)

    // To accept the file pass `true`, like so:
    // callback(null, true)

    // You can always pass an error if something goes wrong:
    // callback(new Error('I don\'t have a clue!'))

    if (/image\/(jpe?g|png)/.test(file.mimetype)) {
      callback(null, true)
    } else {
      callback(null, false)
    }
  },
  storage: multer.memoryStorage()
  // storage: multer.diskStorage({
  //   destination: `${process.env.FILE_UPLOAD_DIRECTORY}/listing/image`,
  //   filename (req, file, callback) {
  //     callback(null, uuid())
  //   }
  // })
})

const app = express()

app.post('/image', cookieParser(), parseSession, requireSessionRole(['administrator']), upload.single('image'), async (req, res, next) => {
  console.log('uploading image...')

  if (!req.file) {
    return next(new BadRequestError('No file named image was present'))
  }

  const format_id = req.query.format

  if (!format_id) {
    return next(new BadRequestError('No format query parameter was present'))
  }

  const userId = req.session.user_id
  const name = req.file.originalname

  try {
    const sizes = await getImageSizes(format_id)

    if (!sizes.length) {
      return next(new BadRequestError(`Could not find image format ${format_id}`))
    }

    const image_id = await createImageSizes(req.file.buffer, sizes)

    const placeholder = await getPlaceholder(req.file.buffer, sizes[0])

    await pg.query(`
      INSERT INTO website.image
        (image_id, format_id, name, placeholder, created_by_user_id, updated_by_user_id)
      VALUES ($1, $2, $3, $4, $5, $6)
    `, [ image_id, format_id, name, placeholder, userId, userId ])

    res.status(200).end(image_id)
  } catch (error) {
    console.error(error)

    res.status(500).end()
  }
})

module.exports = app
