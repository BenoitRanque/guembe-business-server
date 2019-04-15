const request = require('request-promise')
const bcrypt = require('bcryptjs')
const jwt = require('jsonwebtoken')

const rootValue = {
  async client_authentication ({ provider, redirect_uri, code }, { db }) {
    console.log('validating oAuth')
    console.log(provider)
    let clientAuth = null
    let clientAccount = null

    try {
      switch (provider) {
        case 'facebook':
          clientAuth = await getOAuthFacebook(redirect_uri, code)
          break
        case 'google':
          clientAuth = await getOAuthGoogle(redirect_uri, code)
          break
        default:
          throw new Error(`Unknow OpenAuth Provider ${provider}`)
      }

      clientAccount = await loadClientAccount(clientAuth, db)
      if (clientAccount === null) {
        clientAccount = await createClientAccount(clientAuth, db)
      }

      return {
        account: clientAccount,
        token: getClientToken(clientAccount)
      }
    } catch (error) {
      console.error(error)
      throw error
    }
  },

  async user_authentication ({ username, password }, { db }) {
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
}

function getClientToken ({ client_id }) {
  const claims = {
    'x-hasura-default-role': [ 'client' ],
    'x-hasura-allowed-roles': 'client',
    'x-hasura-client-id': client_id
  }
  return jwt.sign({ 'x-hasura': claims }, process.env.AUTH_JWT_SECRET)
}

async function loadClientAccount (clientAuth, db) {
  const query = `
    SELECT client_id, name, email, first_name, middle_name, last_name, authentication_provider_name
    FROM store.client
    WHERE authentication_provider_name = $1
    AND authentication_account_id = $2
  `
  const { rows: [ client ] } = await db.query(query, [
    clientAuth.authentication_provider_name,
    clientAuth.authentication_account_id
  ])

  return client ? client : null
}
async function createClientAccount (clientAuth, db) {
  const query = `
    INSERT INTO store.client
      (name, email, first_name, middle_name, last_name, authentication_provider_name, authentication_account_id)
    VALUES
      ($1, $2, $3, $4, $5, $6, $7)
    RETURNING
      client_id, name, email, first_name, middle_name, last_name, authentication_provider_name
  `

  // order here must be same as above. Be careful
  const { rows: [ client ] } = await db.query(query, [
    clientAuth.name,
    clientAuth.email,
    clientAuth.first_name,
    clientAuth.middle_name,
    clientAuth.last_name,
    clientAuth.authentication_provider_name,
    clientAuth.authentication_account_id
  ])

  return client
}

async function getOAuthFacebook (redirect_uri, code) {
  const { access_token } = await request({
    method: 'get',
    uri: 'https://graph.facebook.com/v3.2/oauth/access_token',
    json: true,
    qs: {
      client_id: process.env.OAUTH_PROVIDER_FACEBOOK_CLIENT_ID,
      client_secret: process.env.OAUTH_PROVIDER_FACEBOOK_CLIENT_SECRET,
      redirect_uri,
      code
    }
  })

  const response = await request({
    method: 'get',
    uri: 'https://graph.facebook.com/me?fields=id&access_token',
    json: true,
    qs: {
      access_token,
      fields: 'id,name,email,first_name,last_name,middle_name'
      // fields: 'id,name,email,first_name,last_name,middle_name,name_format,picture,short_name'
    }
  })

  const { id, name, email, first_name, middle_name, last_name } = response

  return {
    authentication_provider_name: 'facebook',
    authentication_account_id: id,
    name: name ? name : '',
    email: email ? email : '',
    first_name: first_name ? first_name : '',
    middle_name: middle_name ? middle_name : '',
    last_name: last_name ? last_name : ''
  }
}

async function getOAuthGoogle (redirect_uri, code) {
  const { access_token } = await request({
    method: 'post',
    json: true,
    uri: 'https://www.googleapis.com/oauth2/v4/token',
    qs: {
      grant_type: 'authorization_code',
      client_id: process.env.OAUTH_PROVIDER_GOOGLE_CLIENT_ID,
      client_secret: process.env.OAUTH_PROVIDER_GOOGLE_CLIENT_SECRET,
      redirect_uri,
      code
    }
  })

  const response = await request({
    method: 'get',
    uri: 'https://www.googleapis.com/oauth2/v1/userinfo?access_token',
    json: true,
    qs: {
      access_token,
      fields: 'id,name,email,given_name,family_name'
      // fields: 'id,email,verified_email,name,given_name,family_name,link,picture,locale'
    }
  })

  const { id, name, email, given_name, family_name } = response
  let first_name = '', middle_name = ''
  if (given_name && given_name.length) {
    let namesArr = given_name.split(' ')
    if (namesArr.length) {
      first_name = namesArr[0]
      if (namesArr.length >= 2) {
        middle_name = namesArr.slice(1).join(' ')
      }
    }
  }

  return {
    authentication_provider_name: 'google',
    authentication_account_id: id,
    name: name ? name : '',
    email: email ? email : '',
    first_name: first_name ? first_name : '',
    middle_name: middle_name ? middle_name : '',
    last_name: family_name ? family_name : ''
  }
}

module.exports = rootValue
