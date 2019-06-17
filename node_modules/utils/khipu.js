const axios = require('axios')
const crypto = require('crypto')

class Khipu {
  constructor (receiverId, secret) {
    this.receiverId = receiverId
    this.secret = secret
  }

  getAuthorizationHeader (method, url, parameters) {
    let query = [
      method.toUpperCase(),
      encodeURIComponent(url)
    ]
    // parameters must be sorted alphabetically for hash calculation
    Object.keys(parameters).sort().forEach(key => {
      if (parameters[key]) {
        query.push(`${encodeURIComponent(key)}=${encodeURIComponent(parameters[key])}`)
      }
    })

    const hash = crypto
      .createHmac('sha256', this.secret)
      .update(query.join('&'))
      .digest('hex')

    return `${this.receiverId}:${hash}`
  }

  getHeaders (method, url, parameters) {
    return {
      'content-type': 'application/x-www-form-urlencoded',
      authorization: this.getAuthorizationHeader(method, url, parameters)
    }
  }

  async getBanks () {
    const method = 'get'
    const url = `https://khipu.com/api/2.0/banks`
    const parameters = {}
    const { data } = await axios({
      method,
      url,
      headers: this.getHeaders(method, url, parameters)
    })

    return data
  }
  async getPayments ({
    notification_token // (requerido): Token de notifiación recibido usando la API de notificaiones 1.3 o superior.
  }) {
    const method = 'get'
    const url = `https://khipu.com/api/2.0/payments`
    const parameters = {
      notification_token
    }
    const { data } = await axios({
      method,
      url,
      headers: this.getHeaders(method, url, parameters),
      params: parameters
    })

    return data
  }
  async postPayments ({
    subject, // (requerido): Motivo
    currency = 'BOB', // (requerido): El código de moneda en formato ISO-4217
    amount, // (requerido): El monto del cobro. Sin separador de miles y usando '.' como separador de decimales. Hasta 4 lugares decimales, dependiendo de la moneda
    transaction_id, // (opcional): Identificador propio de la transacción. Ej: número de factura u orden de compra
    custom, // (opcional): Parámetro para enviar información personalizada de la transacción. Ej: documento XML con el detalle del carro de compra
    body, // (opcional): Descripción del cobro
    bank_id, // (opcional): Identificador del banco para usar en el pago
    return_url, // (opcional): La dirección URL a donde enviar al cliente mientras el pago está siendo verificado
    cancel_url, // (opcional): La dirección URL a donde enviar al cliente si decide no hacer hacer la transacción
    picture_url, // (opcional): Una dirección URL de una foto de tu producto o servicio
    notify_url, // (opcional): La dirección del web-service que utilizará khipu para notificar cuando el pago esté conciliado
    contract_url, // (opcional): La dirección URL del archivo PDF con el contrato a firmar mediante este pago. El cobrador debe estar habilitado para este servicio y el campo 'fixed_payer_personal_identifier' es obligatorio
    notify_api_version, // (opcional): Versión de la API de notifiaciones para recibir avisos por web-service
    expires_date, // (opcional): Fecha de expiración del cobro. Pasada esta fecha el cobro es inválido. Formato ISO-8601. Ej: 2017-03-01T13:00:00Z
    send_email, // (opcional): Si es 'true', se enviará una solicitud de cobro al correo especificado en 'payer_email'
    payer_name, // (opcional): Nombre del pagador. Es obligatorio cuando send_email es 'true'
    payer_email, // (opcional): Correo del pagador. Es obligatorio cuando send_email es 'true'
    send_reminders, // (opcional): Si es 'true', se enviarán recordatorios de cobro.
    responsible_user_email, // (opcional): Correo electrónico del responsable de este cobro, debe corresponder a un usuario khipu con permisos para cobrar usando esta cuenta de cobro
    fixed_payer_personal_identifier, // (opcional): Identificador personal. Si se especifica, solo podrá ser pagado usando ese identificador
    integrator_fee, // (opcional): Comisión para el integrador. Sólo es válido si la cuenta de cobro tiene una cuenta de integrador asociada
    collect_account_uuid, // (opcional): Para cuentas de cobro con más cuenta propia. Permite elegir la cuenta donde debe ocurrir la transferencia.
    confirm_timeout_date // (opcional): Fecha de rendición del cobro. Es también la fecha final para poder reembolsar el cobro. Formato ISO-8601. Ej: 2017-03-01T13:00:00Z
  }) {
    const method = 'post'
    const url = `https://khipu.com/api/2.0/payments`
    const parameters = {
      subject,
      currency,
      amount,
      transaction_id,
      custom,
      body,
      bank_id,
      return_url,
      cancel_url,
      picture_url,
      notify_url,
      contract_url,
      notify_api_version,
      expires_date,
      send_email,
      payer_name,
      payer_email,
      send_reminders,
      responsible_user_email,
      fixed_payer_personal_identifier,
      integrator_fee,
      collect_account_uuid,
      confirm_timeout_date
    }
    const { data } = await axios({
      method,
      url,
      headers: this.getHeaders(method, url, parameters),
      params: parameters
    })

    return data
  }
  async getPaymentsId (id) {
    const method = 'get'
    const url = `https://khipu.com/api/2.0/payments/${id}`
    const parameters = {}
    const { data } = await axios({
      method,
      url,
      headers: this.getHeaders(method, url, parameters),
      params: parameters
    })

    return data
  }
  async deletePaymentsId (id) {
    const method = 'delete'
    const url = `https://khipu.com/api/2.0/payments/${id}`
    const parameters = {}
    const { data } = await axios({
      method,
      url,
      headers: this.getHeaders(method, url, parameters),
      params: parameters
    })

    return data
  }
  async postPaymentsIdConfirm (id) {
    const method = 'post'
    const url = `https://khipu.com/api/2.0/payments/${id}/confirm`
    const parameters = {}
    const { data } = await axios({
      method,
      url,
      headers: this.getHeaders(method, url, parameters),
      params: parameters
    })

    return data
  }
  async postPaymentsIdRefunds (id, amount) {
    const method = 'post'
    const url = `https://khipu.com/api/2.0/payments/${id}/refunds`
    const parameters = { amount }
    const { data } = await axios({
      method,
      url,
      headers: this.getHeaders(method, url, parameters),
      params: parameters
    })

    return data
  }
  async postReceivers ({
    admin_first_name, // (requerido): Nombre de pila del administrador de la cuenta de cobro a crear.
    admin_last_name, // (requerido): Apellido del administrador de la cuenta de cobro a crear.
    admin_email, // (requerido): Correo electrónico del administrador de la cuenta de cobro a crear.
    country_code, // (requerido): Código alfanumérico de dos caractéres ISO 3166-1 del país de la cuenta de cobro a crear.
    business_identifier, // (requerido): Identificador tributario del cobrador asociado a la cuenta de cobro a crear.
    business_category, // (requerido): Categoría tributaria o rubro tributario del cobrador asociado a la cuenta de cobro a crear.
    business_name, // (requerido): Nombre tributario del cobrador asociado a la cuenta de cobro a crear.
    business_phone, // (requerido): Teléfono del cobrador asociado a la cuenta de cobro a crear.
    business_address_line_1, // (requerido): Dirección del cobrador de la cuenta de cobro a crear.
    business_address_line_2, // (requerido): Segunda línea de la dirección del cobrador de la cuenta de cobro a crear.
    business_address_line_3, // (requerido): Tercera línea de la dirección del cobrador de la cuenta de cobro a crear.
    contact_full_name, // (requerido): Nombre del contacto del cobrador.
    contact_job_title, // (requerido): Cargo del contacto del cobrador.
    contact_email, // (requerido): Correo electrónico del contacto del cobrador.
    contact_phone, // (requerido): Teléfono del contacto del cobrador.
    bank_account_bank_id, // (opcional): Identificador del banco.
    bank_account_identifier, // (opcional): Identificador personal del dueño de la cuenta de banco.
    bank_account_name, // (opcional): Nombre de la cuenta de banco.
    bank_account_number, // (opcional): Número de la cuenta en el banco.
    notify_url, // (opcional): URL por omisión para el webservice donde se notificará el pago.
    rendition_url // (opcional): URL para el webservice donde se notificará la rendición.
  }) {
    const method = 'post'
    const url = `https://khipu.com/api/2.0/receivers`
    const parameters = {
      admin_first_name,
      admin_last_name,
      admin_email,
      country_code,
      business_identifier,
      business_category,
      business_name,
      business_phone,
      business_address_line_1,
      business_address_line_2,
      business_address_line_3,
      contact_full_name,
      contact_job_title,
      contact_email,
      contact_phone,
      bank_account_bank_id,
      bank_account_identifier,
      bank_account_name,
      bank_account_number,
      notify_url,
      rendition_url
    }
    const { data } = await axios({
      method,
      url,
      headers: this.getHeaders(method, url, parameters),
      params: parameters
    })

    return data
  }
}

module.exports = new Khipu(process.env.KHIPU_CLIENT_ID, process.env.KHIPU_CLIENT_SECRET)
