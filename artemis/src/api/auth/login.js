const express = require('express')
const app = express()

app.post('/login', express.json(), function (req, res, next) {
  const { username = null, email = null, password } = req.body

  const query = `
    SELECT user_id, user_type_id, password
    FROM account.user
    WHERE ${username !== null ? 'username' : 'email'} = $1
  `

  const { rows: [ user ] } = await req.db.query(query, [
    username !== null ? username : email
  ])

  if (user) {
    const valid = await bcrypt.compare(password, user.password)
    if (valid) {
      const session = await getUserSession(user, req.db)
      const token = getSessionToken(session)

      setSessionCookie(token, res)

      const [ header, payload ] = token.split('.')

      return res.status(200).send(`${header}.${payload}`)
    }
  }
})

module.exports = app