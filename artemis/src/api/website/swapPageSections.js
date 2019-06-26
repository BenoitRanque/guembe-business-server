const express = require('express')
const pg = require('utils/pg')
const { BadRequestError } = require('utils/errors')

const app = express()

app.post('/', express.json(), async function (req, res, next) {
  console.log(req.body)
  try {
    const {
      page_id = null,
      index_a = null,
      index_b = null
    } = req.body

    if ([page_id, index_a, index_b].includes(null)) throw new BadRequestError(`Missing parameters. Got ${JSON.stringify(req.body)}`)

    await pg.query(`
      UPDATE website.section
      SET index = swap.new_index
      FROM (VALUES ($1::int, $2::int), ($2::int, $1::int)) AS swap(old_index, new_index)
      WHERE website.section.index = swap.old_index
      AND website.section.page_id = $3;
    `, [
      index_a,
      index_b,
      page_id
    ])

    res.status(200).json({})
  } catch (error) {
    next(error)
  }
})

module.exports = app
