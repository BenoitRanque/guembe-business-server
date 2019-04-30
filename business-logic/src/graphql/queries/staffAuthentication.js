const bcrypt = require('bcryptjs')
const jwt = require('jsonwebtoken')

module.exports = async function staffAuthentication ({ username, password }, { db }) {
  const query = `
    SELECT user_id, username, password
    FROM staff.user
    WHERE username = $1
  `
  const { rows: [ user ] } = await db.query(query, [ username ])

  if (user) {
    const valid = await bcrypt.compare(password, user.password)
    if (valid) {
      const { user_id } = user
      const query = `
        SELECT role_name
        FROM staff.user_role
        LEFT JOIN staff.role ON (staff.user_role.role_id = staff.role.role_id)
        WHERE user_id = $1
      `
      const { rows: roleRows } = await db.query(query, [user_id])

      const roles = roleRows.length
        ? roleRows.map(({ role_name }) => role_name)
        : ['anonymous'] // default to anonymous role
      const credentials = {
        username,
        user_id,
        roles
      }
      const claims = {
        'x-hasura-default-role': roles[0], // default to first role
        'x-hasura-allowed-roles': roles,
        'x-hasura-user-id': user_id,
        'x-hasura-username': username
      }
      return {
        account: credentials,
        token: jwt.sign({ 'x-hasura': claims }, process.env.AUTH_JWT_SECRET)
      }
    }
  }
  throw new Error('No se pudo Iniciar Session')
}