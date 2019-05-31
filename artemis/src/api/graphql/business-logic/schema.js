const { buildSchema } = require('graphql')

// Construct a schema, using GraphQL schema language
const schema = buildSchema(/* GraphQL */`
  scalar uuid

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
    test: String
  }

  type Mutation {
    store_checkout (purchase_id: uuid! payment: StoreCheckoutPaymentInput!): StoreCheckoutPayload!
    verify_payment_status(payment_id: uuid!): StorePaymentStatus!
  }
`)

module.exports = schema
