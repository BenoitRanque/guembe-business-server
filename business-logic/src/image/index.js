const express = require('express')
const path = require('path')
const fs = require('fs')
const corser = require('corser')
const multer = require('multer')
const uuid = require('uuid/v4')
const sharp = require('sharp')
const { requireRoleMiddleware, getUserId } = require('../utils/session')

// create image directory if not exists
if (!fs.existsSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing`)) {
  fs.mkdirSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing`, { recursive: true })
}

const upload = multer({
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

app.use(corser.create({
  requestHeaders: corser.simpleRequestHeaders.concat(['Authorization'])
}))

app.post('/listing/upload/:listing_id', requireRoleMiddleware(['administrator']), upload.single('image'), async (req, res) => {

  if (!req.file) {
    console.log('request file absent')
    return res.status(400).end()
  }

  const userId = getUserId(req)
  const image_id = uuid()
  const listing_id = req.params.listing_id
  const name = req.file.originalname

  try {
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
    const xl = await sharp(req.file.buffer).resize(1200, 600).jpeg({ quality: 100, progressive: true }).toFile(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.xl.jpg`)
    const lg = await sharp(req.file.buffer).resize(800, 400).jpeg({ quality: 100, progressive: true }).toFile(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.lg.jpg`)
    const md = await sharp(req.file.buffer).resize(600, 300).jpeg({ quality: 100, progressive: true }).toFile(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.md.jpg`)
    const sm = await sharp(req.file.buffer).resize(400, 200).jpeg({ quality: 100, progressive: true }).toFile(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.sm.jpg`)
    const xs = await sharp(req.file.buffer).resize(300, 150).jpeg({ quality: 100, progressive: true }).toFile(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.xs.jpg`)

    const placeholder = await sharp(req.file.buffer).resize(32, 16).toBuffer()

    const query = `
      INSERT INTO store.listing_image
        (image_id, name, placeholder, listing_id, created_by_user_id, updated_by_user_id)
      VALUES ($1, $2, $3, $4, $5, $6)
    `

    const parameters = [
      image_id,
      name,
      `data:image/jpg;base64,${placeholder.toString('base64')}`,
      listing_id,
      userId,
      userId
    ]

    await req.db.query(query, parameters)

    res.status(200).end()
  } catch (error) {
    console.error(error)

    if (fs.existsSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.xl.jpg`)) {
      fs.unlinkSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.xl.jpg`)
    }
    if (fs.existsSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.lg.jpg`)) {
      fs.unlinkSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.lg.jpg`)
    }
    if (fs.existsSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.md.jpg`)) {
      fs.unlinkSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.md.jpg`)
    }
    if (fs.existsSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.sm.jpg`)) {
      fs.unlinkSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.sm.jpg`)
    }
    if (fs.existsSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.xs.jpg`)) {
      fs.unlinkSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.xs.jpg`)
    }

    res.status(500).end()
  }
})

app.get('/listing/:image_id', async (req, res) => {
  const { image_id } = req.params
  const { size = 'xl' } = req.query

  try {
    res.sendFile(`${process.env.FILE_UPLOAD_DIRECTORY}/image/listing/${image_id}.${size}.jpg`, {
      headers: {
        'Content-Type': 'image/png',
      }
    })
  } catch (error) {
    console.error(error)

    res.status(500).end()
  }
})

module.exports = app
