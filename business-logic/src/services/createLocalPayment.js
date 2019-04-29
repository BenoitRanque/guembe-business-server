module.exports = async function createLocalPayment ({ purchase_id }, db) {
  const { rows: [ localPayment ] } = await db.query(`
    INSERT INTO store.payment (purchase_id)
    VALUES ($1)
    RETURNING payment_id, amount;
  `, [ purchase_id ])

  return localPayment
}
