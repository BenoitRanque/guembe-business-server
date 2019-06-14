const db = require('../utils/db')
const fs = require('fs')
const sharp = require('sharp')
const uuid = require('uuid/v4')

function removeImageSizes (image_id, sizes) {
  sizes.map(({ size_id }) => {
    if (fs.existsSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image/${image_id}.${size_id}.jpg`)) {
      fs.unlinkSync(`${process.env.FILE_UPLOAD_DIRECTORY}/image/${image_id}.${size_id}.jpg`)
    }
  })
}

async function getImageSizes (format_id) {
  const { rows: sizes } = await db.query(`
    SELECT
      website.format.format_id,
      website.format_size.size_id,
      website.format_size.width,
      website.format_size.height
    FROM website.format
    LEFT JOIN website.format_size ON website.format.format_id = website.format_size.format_id
    WHERE website.format.format_id = $1
    ORDER BY width DESC
  `, [ format_id ])

  return sizes
}

async function getPlaceholder(imageBuffer, { width: orignalWidth, height: originalHeight }) {
  const placeholderWidth = 24
  const placeholderHeight = Math.round(placeholderWidth * originalHeight / orignalWidth)

  const placeholderBuffer = await sharp(imageBuffer)
    .resize(placeholderWidth, placeholderHeight)
    .blur(2)
    .toBuffer()

  return `data:image/jpg;base64,${placeholderBuffer.toString('base64')}`
}
// 1020 2027
async function createImageSizes(imageBuffer, sizes) {
  const image_id = uuid()

  try {
    await Promise.all(sizes.map(({ size_id, width, height}) => {
      sharp(imageBuffer)
        .resize(width, height)
        .jpeg({ quality: 100, progressive: true })
        .toFile(`${process.env.FILE_UPLOAD_DIRECTORY}/image/${image_id}.${size_id}.jpg`)
    }))

    return image_id
  } catch (error) {
    removeImageSizes(image_id, sizes)
    throw error
  }
}

module.exports = {
  getImageSizes,
  getPlaceholder,
  createImageSizes,
  removeImageSizes
}