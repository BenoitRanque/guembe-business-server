const fs = require('fs')
const crypto = require('crypto')
const constants = require('constants')
const request = require('request-promise')

class IZI {
  constructor (clientId, publicKey) {
    this.clientId = clientId
    this.publicKey = publicKey
  }

  getAuthorizationHeader (data) {
    const bufferData = Buffer.from(JSON.stringify(data), 'utf8')

    const key = crypto.randomBytes(32)
    const iv = crypto.randomBytes(16)

    const cypher = crypto.createCipheriv('aes-256-cbc', key, iv)
    const cryptedAES = Buffer.concat([cypher.update(bufferData), cypher.final()])

    const encryptedKey = crypto.publicEncrypt({
      'key': this.publicKey,
      padding: constants.RSA_PKCS1_PADDING
    }, key);

    return `${this.clientId}:${encryptedKey.toString('base64')}:${iv.toString('hex')}${cryptedAES.toString('base64')}`
  }

  getHeaders (data) {
    return {
      'content-type': 'application/json',
      authorization: this.getAuthorizationHeader(data)
    }
  }

  async facturas ({
    emisor, // El NIT emisor (debe estar registrado en el portal web). Campo requerido.
    comprador, // El NIT de quien realiza la compra. Campo requerido.
    razonSocial, // El nombre completo o la razón social del comprador.
    sucursal = 1, // El código de sucursal a utilizar, en caso de que se tenga más de una.
    actividadEconomica, // El código de actividad económica a utilizar, en caso de que se tenga más de una.
    listaItems, // La lista de los artículos con sus precios y cantidades se describen en este campo
    descuentos = 0, // Descuento sobre el valor total de la factura.
    tipoCompra = 1
    /* Tipo de compra, puede ser cualquiera de los siguientes valores: (si duda, envíe 1)
      1. Comercio al por menor
      2. Comercio al por mayor
      3. Agricultura
      4. Minería
      5. Industria
      6. Agroindustria
      7. Servicios
      8. Construcción
      9. Administración
    */
  }) {
    if (!emisor || !String(emisor).match(/^[0-9]+$/)) {
      throw new Error(`Invalid value for parameter emisor: ${emisor}`)
    }
    if (!comprador || !String(comprador).match(/^[0-9]+$/)) {
      throw new Error(`Invalid value for parameter comprador: ${comprador}`)
    }
    if (!razonSocial) {
      throw new Error(`Invalid value for parameter razonSocial: ${razonSocial}`)
    }
    if (!listaItems || !listaItems.length || listaItems.some(item => {
      if (!item) return true
      let { articulo, cantidad, precioUnitario } = item

      if (!articulo) return true
      if (!cantidad || cantidad < 1 || !Number.isInteger(cantidad)) return true
      if (!precioUnitario || precioUnitario <= 0) return true

      return false
    })) {
      throw new Error(`Invalid value for parameter listaItems: ${JSON.stringify(listaItems)}`)
    }

    const data = {
      emisor,
      comprador,
      razonSocial,
      sucursal,
      actividadEconomica,
      listaItems,
      descuentos,
      tipoCompra
    }
    try {
      const response = await request({
        method: 'POST',
        uri: `https://test.izi.noujau.io/v1/facturas`,
        // uri: `https://${ process.env.NODE_ENV === 'development' ? 'test' : 'api' }.izi.noujau.io/v1/facturas`,
        // body: JSON.stringify(data),
        body: data,
        json: true,
        headers: this.getHeaders(data)
      })

      return response
    } catch (error) {
      // console.error(error)
      throw error
    }
  }
}

// the pathe where we expect the key to be
const path = `/run/secrets/IZI_PUBLIC_KEY`

if (!fs.existsSync(path)) {
  // file should always exists. Throw very explicit error if it does not
  throw new Error(`
    Missing IZI_PUBLIC_KEY.
    The container could not find the key at ${path}
    Make sure the file is present, and the docker-compose file is correctly configured.
    The docker-compose file should have the following configuration:

    \`\`\`
    version: '3.7'
    services:
      business-logic:
        secrets:
          - IZI_PUBLIC_KEY
    secrets:
      IZI_PUBLIC_KEY:
        file: ./private/IZI_PUBLIC_KEY.pub
    \`\`\`

    Make sure the IZI_PUBLIC_KEY.pub file is available in the ./private directory on the host machine.


  `)
}
const IZI_PUBLIC_KEY = fs.readFileSync(path, 'utf8')

module.exports = new IZI (process.env.IZI_CLIENT_ID, IZI_PUBLIC_KEY)