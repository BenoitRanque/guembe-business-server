const request = require('request-promise')
const bcrypt = require('bcryptjs')
const jwt = require('jsonwebtoken')

const rootValue = {
  async client_authentication ({ provider, redirect_uri, code }, { db }) {
    console.log('validating oAuth')
    console.log(provider)

    switch (provider) {
      case 'facebook':
        try {
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

          console.log(response)

        } catch (error) {
          console.error(error)
          throw error
        }
/*
GET https://graph.facebook.com/v3.2/oauth/access_token?
   client_id={app-id}
   &redirect_uri={redirect-uri}
   &client_secret={app-secret}
   &code={code-parameter}
*/

        throw new Error(`OpenAuth Provider ${provider} not yet implemented`)
        break
      case 'google':
        try {

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

          console.log(response)


        } catch (error) {
          console.error(error)
          throw error
        }

        throw new Error(`OpenAuth Provider ${provider} not yet implemented`)
        break
      case 'github':

        throw new Error(`OpenAuth Provider ${provider} not yet implemented`)
        break
      default:
        throw new Error(`Unknow OpenAuth Provider ${provider}`)
    }
  },

  async user_authentication ({ username, password }, { db }) {
    const { rows: [ account ] } = await db.query(`SELECT account_id, username, password FROM auth.account WHERE username = $1`, [ username ])

    if (account) {
      const valid = await bcrypt.compare(password, account.password)
      if (valid) {
        const { account_id } = account
        const { rows: roleRows } = await db.query(`SELECT role_name AS role FROM auth.account_role WHERE account_id = $1`, [account_id])

        const roles = roleRows.length ? roleRows.map(({ role }) => role) : ['anonymous'] // default to anonymous role
        const credentials = {
          username,
          account_id: account_id,
          roles
        }
        const claims = {
          'x-hasura-default-role': roles[0], // default to first role
          'x-hasura-allowed-roles': roles,
          'x-hasura-account-id': account_id,
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

  // auth_credentials: async function ({ username, password }, { db }) {
  //   const { rows: [ account ] } = await db.query(`SELECT account_id, username, password FROM auth.account WHERE username = $1`, [ username ])

  //   if (account) {
  //     const valid = await bcrypt.compare(password, account.password)
  //     if (valid) {
  //       const { account_id } = account
  //       const { rows: roleRows } = await db.query(`SELECT role_name AS role FROM auth.account_role WHERE account_id = $1`, [account_id])

  //       const roles = roleRows.length ? roleRows.map(({ role }) => role) : ['anonymous'] // default to anonymous role
  //       const credentials = {
  //         username,
  //         account_id: account_id,
  //         roles
  //       }
  //       const claims = {
  //         'x-hasura-default-role': roles[0], // default to first role
  //         'x-hasura-allowed-roles': roles,
  //         'x-hasura-account-id': account_id,
  //         'x-hasura-username': username
  //       }
  //       return {
  //         account: credentials,
  //         token: jwt.sign({ 'x-hasura': claims }, process.env.AUTH_JWT_SECRET)
  //       }
  //     }
  //   }
  //   throw new Error('No se pudo Iniciar Session')
  // }
}

module.exports = rootValue
