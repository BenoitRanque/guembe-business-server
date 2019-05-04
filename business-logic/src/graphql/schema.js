const { buildSchema } = require('graphql')

// Construct a schema, using GraphQL schema language
const schema = buildSchema(/* GraphQL */`
  scalar uuid

  type UserCrededentials {
    token: String!
    account: UserAccount!
  }

  type UserAccount {
    user_id: uuid!
    username: String!
    roles: [String!]!
  }

  type ClientCredentials {
    token: String!
    account: ClientAccount!
  }

  type ClientAccount {
    client_id: uuid!
    name: String
    email: String
  }

  enum OAuthProviderEnum {
    google
    facebook
  }

  scalar JSON

  type StoreCheckoutPayload {
    payment_id: uuid!
    khipu_payment_url: String!
    khipu_simplified_transfer_url: String!
    khipu_transfer_url: String!
    khipu_webpay_url: String!
    khipu_app_url: String!
    khipu_ready_for_terminal: Boolean!
  }

  input StoreCheckoutPaymentInput {
    payer_email: String!
    payer_name: String!
    return_url: String!
    cancel_url: String!
  }

  type StorePaymentStatus {
    name: String!
    description: String!
  }

  type Query {
    test: JSON
    store_authentication (provider: OAuthProviderEnum! code: String! redirect_uri: String!): ClientCredentials!
    staff_authentication (username: String! password: String!): UserCrededentials!
  }

  type Mutation {
    store_checkout (purchase_id: uuid! payment: StoreCheckoutPaymentInput!): StoreCheckoutPayload!
    verify_payment_status(payment_id: uuid!): StorePaymentStatus!
  }
`)

module.exports = schema
