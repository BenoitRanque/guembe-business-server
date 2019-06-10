const qs = require('querystring')
const axios = require('axios')


class OAuth2 {
  constructor ({
    name,
    clientId,
    clientSecret,
    authenticationEndpoint,
    verificationEndpoint,
    verificationMethod = 'GET',
    resourceEndpoint,
    scope,
    fields,
    parseFields = fields => fields,
  }) {
    this.name = name
    this.clientId = clientId
    this.clientSecret = clientSecret
    this.authenticationEndpoint = authenticationEndpoint
    this.verificationEndpoint = verificationEndpoint
    this.verificationMethod = verificationMethod
    this.resourceEndpoint = resourceEndpoint
    this.scope = scope
    this.fields = fields
    this.parseFields = parseFields
  }

  getRedirectUri () {
    return `https://${process.env.PUBLIC_HOSTNAME}/api/v1/auth/oauth/${this.name}/callback`
  }

  getAuthenticationURL (state) {
    const query = qs.stringify({
      client_id: this.clientId,
      response_type: 'code',
      redirect_uri: this.getRedirectUri(),
      scope: this.scope,
      state
    })

    return `${this.authenticationEndpoint}?${query}`
  }

  async getAccessToken(code) {
    const { data: { access_token } } = await axios({
      method: this.verificationMethod,
      url: this.verificationEndpoint,
      params: {
        code,
        grant_type: 'authorization_code',
        client_id: this.clientId,
        client_secret: this.clientSecret,
        redirect_uri: this.getRedirectUri()
      }
    })

    return access_token
  }

  async getUserOAuthAccount (access_token) {
    const { data: fields  } = await axios({
      method: 'GET',
      url: this.resourceEndpoint,
      params: {
        access_token,
        fields: this.fields
      }
    })

    return this.parseFields(fields)
  }
}

const google = new OAuth2({
  name: 'google',
  clientId: process.env.OAUTH_PROVIDER_GOOGLE_CLIENT_ID,
  clientSecret: process.env.OAUTH_PROVIDER_GOOGLE_CLIENT_SECRET,
  authenticationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
  verificationEndpoint: 'https://www.googleapis.com/oauth2/v4/token',
  verificationMethod: 'POST',
  resourceEndpoint: 'https://www.googleapis.com/oauth2/v1/userinfo',
  scope: 'profile email',
  fields: 'id,name,email,given_name,family_name',
  parseFields (fields) {
    const { id, name, email, given_name, family_name } = fields
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
      authentication_provider_account_id: id,
      name: name ? name : '',
      email: email ? email : '',
      first_name: first_name ? first_name : '',
      middle_name: middle_name ? middle_name : '',
      last_name: family_name ? family_name : ''
    }
  }
})

const facebook = new OAuth2({
  name: 'facebook',
  clientId: process.env.OAUTH_PROVIDER_FACEBOOK_CLIENT_ID,
  clientSecret: process.env.OAUTH_PROVIDER_FACEBOOK_CLIENT_SECRET,
  authenticationEndpoint: 'https://www.facebook.com/v3.3/dialog/oauth',
  verificationEndpoint: 'https://graph.facebook.com/v3.3/oauth/access_token',
  verificationMethod: 'GET',
  resourceEndpoint: 'https://graph.facebook.com/me',
  scope: 'email',
  fields: 'id,name,email,first_name,last_name,middle_name',
  parseFields (fields) {
    const { id, name, email, first_name, middle_name, last_name } = fields

    return {
      authentication_provider_name: 'facebook',
      authentication_provider_account_id: id,
      name: name ? name : '',
      email: email ? email : '',
      first_name: first_name ? first_name : '',
      middle_name: middle_name ? middle_name : '',
      last_name: last_name ? last_name : ''
    }
  }
})

module.exports = {
  facebook,
  google
}