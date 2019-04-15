const { buildSchema } = require('graphql')

// Construct a schema, using GraphQL schema language
const schema = buildSchema(/* GraphQL */`
  scalar UUID

  type UserCrededentials {
    token: String!
    account: UserAccount!
  }

  type UserAccount {
    user_id: UUID!
    username: String!
    roles: [String!]!
  }

  type ClientCredentials {
    token: String!
    account: ClientAccount!
  }

  type ClientAccount {
    client_id: UUID!
    name: String
    email: String
  }

  enum OAuthProviderEnum {
    google
    facebook
    github
  }

  type Query {
    client_authentication (provider: OAuthProviderEnum! code: String! redirect_uri: String!): ClientCredentials!
    user_authentication (username: String! password: String!): UserCrededentials!
  }
`)

module.exports = schema
