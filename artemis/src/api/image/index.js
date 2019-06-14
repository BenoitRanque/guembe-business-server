const express = require('express')
const path = require('path')
const fs = require('fs')
const multer = require('multer')

const parseSession = require('../../utils/middlewares/parseSession')
const requireSessionRole  = require('../../utils/middlewares/requireSessionRole')
const cookieParser = require('cookie-parser')
const { getImageSizes, createImageSizes, removeImageSizes, getPlaceholder } = require('../../services/image')

const { BadRequestError } = require('../../utils/errors')

// create image directory if not exists
if (!fs.existsSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image`)) {
  fs.mkdirSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image`, { recursive: true })
}

const upload = multer({
  limits: {
    fieldSize: 5 * 1024 * 1024 // 5 mb
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

app.post('/upload', cookieParser(), parseSession, requireSessionRole(['administrator']), upload.single('image'), async (req, res, next) => {
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

  // const meta = await sharp(req.file.buffer).metadata()
    // format: 'png',
    // size: 2156721,
    // width: 1920,
    // height: 1080,
    // space: 'srgb',
    // channels: 4,
    // depth: 'uchar',
    // density: 72,
    // isProgressive: false,
    // hasProfile: false,
    // hasAlpha: true

  try {
    const sizes = await getImageSizes(format_id)

    if (!sizes.length) {
      return next(new BadRequestError(`Could not find image format ${format_id}`))
    }

    const image_id = await createImageSizes(req.file.buffer, sizes)

    const placeholder = await getPlaceholder(req.file.buffer, sizes[0])

    await req.db.query(`
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

// app.get('/listing/:image_id', async (req, res) => {
//   const { image_id } = req.params
//   const { size = 'xl' } = req.query

//   try {
//     res.sendFile(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.${size}.jpg`, {
//       headers: {
//         'Content-Type': 'image/png',
//       }
//     })
//   } catch (error) {
//     console.error(error)

//     res.status(500).end()
//   }
// })

module.exports = app
