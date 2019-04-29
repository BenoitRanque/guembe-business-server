module.exports = async function (payment_id, update, db) {
  // check if all update properties are valid fields
  if (Object.keys(update).some(column => ![
    'payment_id',
    'payment_url',
    'simplified_transfer_url',
    'transfer_url',
    'webpay_url',
    'app_url',
    'ready_for_terminal',
    'notification_token',
    'receiver_id',
    'conciliation_date',
    'subject',
    'amount',
    'currency',
    'status',
    'status_detail',
    'body',
    'picture_url',
    'receipt_url',
    'return_url',
    'cancel_url',
    'notify_url',
    'notify_api_version',
    'expires_date',
    'attachment_urls',
    'bank',
    'bank_id',
    'payer_name',
    'payer_email',
    'personal_identifier',
    'bank_account_number',
    'out_of_date_conciliation',
    'transaction_id',
    'custom',
    'responsible_user_email',
    'send_reminders',
    'send_email',
    'payment_method'
  ].includes(column))) {
    throw new Error(`Unexpected column name for payment update: \n ${JSON.stringify(update)} \n Possibly due to a khipu api update?`)
  }
  let status = null

  switch (update.status_detail) {
    case 'pending':
      status = 'PENDING'
      break
    case 'normal':
      status = 'COMPLETED'
      break
    case 'marked-paid-by-receiver':
      status = 'COMPLETED'
      break
    case 'rejected-by-payer':
      status = 'REJECTED'
      break
    case 'marked-as-abuse':
      status = 'REJECTED'
      break
    case 'reversed':
      status = 'REVERSED'
      break
    default:
      throw new Error(`Unknown khipu_status_detail ${update.status_detail}`)
  }

  // if expired for more than 10 minutes, set expired
  if (update.expires_date && new Date(update.expires_date).getTime() < (new Date().getTime()) + (10 * 60 * 1000)) {
    status = 'EXPIRED'
  }

  let updateFields = ''
  let updateValues = []
  let returnFields = ''

  Object.keys(update).forEach((column, index) => {
    if (update[column] !== null) {
      updateFields += `, khipu_${column} = $${index + 3}`
      updateValues.push(update[column])
      returnFields += `, khipu_${column}`
    }
  })

  const { rows: [ updatedPayment ] } = await db.query(`
    UPDATE store.payment
    SET status = $2${updateFields}
    WHERE store.payment.payment_id = $1
    RETURNING payment_id, purchase_id, amount, status${returnFields};
  `, [
    payment_id,
    status,
    ...updateValues
  ])

  return updatedPayment
}
