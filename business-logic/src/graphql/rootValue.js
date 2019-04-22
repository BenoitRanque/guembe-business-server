const request = require('request-promise')
const bcrypt = require('bcryptjs')
const jwt = require('jsonwebtoken')
const khipu = require('../utils/khipu')

// note to self
// add mutations to manually check if payment is completed, and run the update if it is


const rootValue = {
  async store_checkout ({ purchase_id }, ctx) {
    // verify auth
    const session = getClientSession(ctx)
    if (!session) {
      throw new Error(`Access Denied`)
    }
    const client_id = session['x-hasura-client-id']

    // verify purchase ownership before creating payment
    const query = /* SQL */`

      INSERT INTO store.payment (purchase_id)
      SELECT $1
      WHERE EXISTS (
        SELECT 1 FROM store.purchase
        WHERE store.purchase.purchase_id = $1
        AND store.purchase.client_id = $2
      ) RETURNING payment_id;
    `

    // validated purchase. Give nice friendly error message on failure.
    // Note at this point changes to purchase are still possible if exploiting. Not safe


    // Create payment locally. Trigger will take care of verifying payment, and to determine atual purchase total price

    try {
      // use this information to create payment remotely.
      // If this fails for any reason, make sure to roll back payment creation
      const response = await ctx.db.query(query, [ purchase_id, client_id ])

      console.log(response)

      // update payment locally with external data
    } catch (error) {
      // this should never happen. If we reach here, something went very wrong and we should crash the server
      console.error(error)
      throw error
    }
  },
  async test (args, ctx) {
    try {
      // validate sale input (here we could use custom logic)

      const result = await khipu.postPayments({

        amount: '100',
        // amount: Number(100).toFixed(2),
        subject: 'TestPayment1'
      })
      //     { payment_id: '3gpzl6hfvbff',
      // payment_url: 'https://khipu.com/payment/info/3gpzl6hfvbff',
      // app_url: 'khipu:///pos/3gpzl6hfvbff',
      // ready_for_terminal: false,
      // pay_me_url: 'https://khipu.com/payment/paymeStart/3gpzl6hfvbff' }

      // const result = await khipu.getBanks()

      // const result = await khipu.getPaymentsId('3gpzl6hfvbff')

      console.log(result)

      return JSON.stringify(result)
    } catch (error) {
      // console.error(error)
      return JSON.stringify(error)
    }
  },
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
    'x-hasura-default-role': 'client',
    'x-hasura-allowed-roles': ['client'],
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

function getClientSession (ctx) {
  const Authorization = ctx.get('Authorization')
  if (Authorization) {
    const token = Authorization.replace('Bearer ', '')
    const session = jwt.verify(token, process.env.AUTH_JWT_SECRET)
    return session
  }
  return null
}

module.exports = rootValue
