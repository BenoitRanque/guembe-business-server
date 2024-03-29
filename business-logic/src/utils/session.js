const jwt = require('jsonwebtoken')

function sessionMiddleware (req, res, next) {
  // get session from header
  const Authorization = req.get('Authorization')
  if (Authorization && Authorization.match(/^Bearer /)) {
    const token = Authorization.replace('Bearer ', '')
    const session = jwt.verify(token, process.env.AUTH_JWT_SECRET)
    req.session = session
  }
  next()
}

function requireSession (req) {
  // throw error if no session is found
  if (req.session === null) throw new Error ('Authentication Required!')
}

function getRoles(req) {
  requireSession(req)

  return req.session['x-hasura']['x-hasura-allowed-roles']
}

function getUserId(req) {
  requireSession(req)

  return req.session['x-hasura']['x-hasura-user-id']
}

function getUsername(req) {
  requireSession(req)

  return req.session['x-hasura']['x-hasura-username']
}

function requireRole (roles, req) {
  // throw error if current session does not have at least of of the roles specified
  requireSession(req)
  const sessionRoles = getRoles(req)

  if ((Array.isArray(roles) && roles.some(role => sessionRoles.includes(role))) || sessionRoles.includes(roles)) {
    return true
  }
  throw new Error ('Authorization Required!')
}

function requireSessionMiddleware (req, res, next) {
  if (req.session) {
    return next()
  }
  res.status(401).end()
}

function requireRoleMiddleware (roles) {
  return (req, res, next) => {
    requireSession(req)
    const sessionRoles = getRoles(req)

    if (Array.isArray(roles) ? roles.some(role => sessionRoles.includes(role)) : sessionRoles.includes(roles)) {
      return next()
    }
    res.status(403).end()
  }
}

function requireClientRole(session) {
  if (!session || !session['x-hasura'] || !session['x-hasura']['x-hasura-allowed-roles'].includes('client')) {
    throw new Error(`Access Denied: client role is required`)
  }
  return true
}

module.exports = {
  sessionMiddleware,
  requireClientRole,
  getUserId,
  getRoles,
  // getUsername,
  // requireSession,
  // requireRole,
  // requireSessionMiddleware,
  requireRoleMiddleware
}
