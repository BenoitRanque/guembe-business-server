module.exports = async function (payment_id, update, db) {
  // check if all update properties are valid fields
  const allowedUpdateColumns = [
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
  ]
  // TODO: do not updated status if not required
  let status = null

  if (update.status_detail) {
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
  }

  // if expired for more than 10 minutes, set expired
  // if (update.expires_date && new Date(update.expires_date).getTime() < (new Date().getTime()) + (10 * 60 * 1000)) {
  //   status = 'EXPIRED'
  // }

  let updateFields = []
  let updateValues = []

  if (status !== null) {
    updateFields.push(`status`)
    updateValues.push(status)
  }

  Object.keys(update).forEach(column => {
    if (allowedUpdateColumns.includes(column) && update[column] !== null) {
      updateFields.push(`khipu_${column}`)
      updateValues.push(update[column])
    }
  })

  if (updateFields.length === 0) {
    throw new Error(`Atempted to update local payment with no update columns specified`)
  }

  const { rows: [ updatedPayment ] } = await db.query(`
    UPDATE store.payment
    SET ${updateFields.map((column, index) => `${column} = $${index + 2}`).join(', ')}
    WHERE store.payment.payment_id = $1
    RETURNING payment_id, purchase_id, amount, ${updateFields.join(', ')};
  `, [
    payment_id,
    ...updateValues
  ])

  return updatedPayment
}
