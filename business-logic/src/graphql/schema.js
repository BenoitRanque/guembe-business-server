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

  scalar JSON

  type StoreCheckoutPayload {
    payment_url: String!
    pay_me_url: String!
    app_url: String!
  }

  input StoreCheckoutInput {
    purchase_id: UUID!
  }

  type Query {
    test: JSON
    client_authentication (provider: OAuthProviderEnum! code: String! redirect_uri: String!): ClientCredentials!
    user_authentication (username: String! password: String!): UserCrededentials!
  }

  type Mutation {
    store_checkout (input: StoreCheckoutInput!): StoreCheckoutPayload!
  }
`)

module.exports = schema
