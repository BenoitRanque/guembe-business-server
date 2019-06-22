const express = require('express')
const db = require('utils/db')
const { BadRequestError } = require('utils/errors')

const app = express()

app.post('/', express.json(), async function (req, res, next) {
  try {
    const {
      section_id = null,
      index_a = null,
      index_b = null
    } = req.body

    if ([section_id, index_a, index_b].includes(null)) throw new BadRequestError(`Missing parameters. Got ${JSON.stringify(req.body)}`)

    await db.query(`
      UPDATE website.element
      SET index = swap.new_index
      FROM (VALUES ($1::int, $2::int), ($2::int, $1::int)) AS swap(old_index, new_index)
      WHERE website.element.index = swap.old_index
      AND website.element.section_id = $3;
    `, [
      index_a,
      index_b,
      section_id
    ])

    res.status(200).json({})
  } catch (error) {
    next(error)
  }
})

module.exports = app