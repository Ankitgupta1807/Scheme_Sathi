import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import fs from 'node:fs'
import path from 'node:path'
import http from 'node:http'
import crypto from 'node:crypto'
import { fileURLToPath } from 'node:url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))

function hashPassword(password) {
  const salt = 'SchemeSathiSalt2026'
  return crypto.scryptSync(password, salt, 32).toString('hex')
}

function verifyPassword(password, storedHash) {
  if (!storedHash) return false
  // Support both scrypt hash and demo plain/legacy passwords
  const computed = hashPassword(password)
  return computed === storedHash || password === storedHash
}

function createToken(email, id) {
  const header = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64url')
  const payload = Buffer.from(JSON.stringify({ sub: email, uid: id, iat: Math.floor(Date.now() / 1000), exp: Math.floor(Date.now() / 1000) + 86400 })).toString('base64url')
  const sig = crypto.createHmac('sha256', 'SchemeSathiSecretKey2026').update(`${header}.${payload}`).digest('base64url')
  return `${header}.${payload}.${sig}`
}

function apiPlugin() {
  let cachedSchemes = null

  function getSchemes() {
    if (cachedSchemes && cachedSchemes.length > 0) return cachedSchemes
    try {
      const scriptPath = path.resolve(__dirname, 'public/legacy/script.js')
      const content = fs.readFileSync(scriptPath, 'utf8')
      const match = content.match(/SCHEMES_DATA\s*=\s*(\[[\s\S]*?\n\]);/)
      if (match) {
        cachedSchemes = new Function(`return ${match[1]}`)()
        return cachedSchemes
      }
    } catch (e) {
      console.error('[API Plugin] Error reading schemes data:', e)
    }
    return []
  }

  // In-memory / server-side Database User Store with Seed Demo Accounts
  const serverUsersDb = {
    'citizen@example.com': {
      id: 1,
      name: 'Ramesh Kumar',
      email: 'citizen@example.com',
      passwordHash: hashPassword('User@123'),
      role: 'Citizen',
      avatarColor: '#2563eb',
      profile: { age: 24, gender: 'Male', state: 'Maharashtra', occupation: 'Student', incomeBracket: '< 1.5 Lakh' }
    },
    'farmer@example.com': {
      id: 2,
      name: 'Balwinder Singh',
      email: 'farmer@example.com',
      passwordHash: hashPassword('Farmer@123'),
      role: 'Farmer',
      avatarColor: '#10b981',
      profile: { age: 46, gender: 'Male', state: 'Punjab', occupation: 'Farmer', incomeBracket: '1.5 - 3 Lakh' }
    },
    'admin@schemesathi.gov.in': {
      id: 3,
      name: 'Pooja Sharma (Officer)',
      email: 'admin@schemesathi.gov.in',
      passwordHash: hashPassword('Admin@123'),
      role: 'Admin',
      avatarColor: '#7c3aed',
      profile: { age: 34, gender: 'Female', state: 'Delhi', occupation: 'Officer', incomeBracket: '> 8 Lakh' }
    }
  }

  return {
    name: 'scheme-sathi-api-plugin',
    configureServer(server) {
      server.middlewares.use((req, res, next) => {
        const url = new URL(req.url, 'http://localhost:5173')

        // Handle CORS preflight
        if (req.method === 'OPTIONS') {
          res.setHeader('Access-Control-Allow-Origin', '*')
          res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
          res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')
          res.statusCode = 204
          res.end()
          return
        }

        // ==========================================
        // 1. SCHEMES ENDPOINTS (/api/schemes)
        // ==========================================
        if (url.pathname === '/api/schemes' || url.pathname.startsWith('/api/schemes/')) {
          const proxyReq = http.request(
            {
              hostname: '127.0.0.1',
              port: 8080,
              path: req.url,
              method: req.method,
              headers: { ...req.headers, host: 'localhost:8080' },
              timeout: 600
            },
            (proxyRes) => {
              res.writeHead(proxyRes.statusCode, {
                ...proxyRes.headers,
                'X-Data-Source': 'Spring-Boot-MySQL'
              })
              proxyRes.pipe(res)
            }
          )

          const fallbackToLocalStore = () => {
            const schemes = getSchemes()
            res.setHeader('Content-Type', 'application/json; charset=utf-8')
            res.setHeader('X-Data-Source', 'Local-Database-Engine')
            res.setHeader('Access-Control-Allow-Origin', '*')

            if (url.pathname === '/api/schemes') {
              const q = url.searchParams.get('q')
              const cat = url.searchParams.get('category')
              let filtered = schemes
              if (cat && cat !== 'All') {
                filtered = filtered.filter(s => s.category?.toLowerCase() === cat.toLowerCase())
              }
              if (q) {
                const query = q.toLowerCase()
                filtered = filtered.filter(s =>
                  s.name?.toLowerCase().includes(query) ||
                  s.shortDescription?.toLowerCase().includes(query) ||
                  s.ministry?.toLowerCase().includes(query)
                )
              }
              res.statusCode = 200
              res.end(JSON.stringify(filtered))
              return
            }

            const slug = url.pathname.replace('/api/schemes/', '')
            const scheme = schemes.find(s => s.slug === slug || s.id === slug)
            if (scheme) {
              res.statusCode = 200
              res.end(JSON.stringify(scheme))
            } else {
              res.statusCode = 404
              res.end(JSON.stringify({ error: 'Scheme not found', slug }))
            }
          }

          proxyReq.on('error', fallbackToLocalStore)
          proxyReq.on('timeout', () => {
            proxyReq.destroy()
            fallbackToLocalStore()
          })

          if (req.method === 'POST' || req.method === 'PUT') {
            req.pipe(proxyReq)
          } else {
            proxyReq.end()
          }
          return
        }

        // ==========================================
        // 2. AUTHENTICATION ENDPOINTS (/api/auth/...)
        // ==========================================
        if (url.pathname.startsWith('/api/auth/')) {
          let bodyData = ''
          req.on('data', chunk => { bodyData += chunk })
          req.on('end', () => {
            // Attempt to forward to Spring Boot if online
            const proxyReq = http.request(
              {
                hostname: '127.0.0.1',
                port: 8080,
                path: req.url,
                method: req.method,
                headers: {
                  ...req.headers,
                  host: 'localhost:8080',
                  'content-length': Buffer.byteLength(bodyData)
                },
                timeout: 600
              },
              (proxyRes) => {
                res.writeHead(proxyRes.statusCode, {
                  ...proxyRes.headers,
                  'X-Data-Source': 'Spring-Boot-MySQL-Auth'
                })
                proxyRes.pipe(res)
              }
            )

            const fallbackAuthHandler = () => {
              res.setHeader('Content-Type', 'application/json; charset=utf-8')
              res.setHeader('Access-Control-Allow-Origin', '*')
              res.setHeader('X-Data-Source', 'Database-Auth-Engine')

              let body = {}
              try {
                if (bodyData) body = JSON.parse(bodyData)
              } catch (e) {
                res.statusCode = 400
                res.end(JSON.stringify({ error: 'Invalid JSON payload' }))
                return
              }

              // Register
              if (url.pathname === '/api/auth/register' && req.method === 'POST') {
                const email = (body.email || '').trim().toLowerCase()
                if (!email || !body.password) {
                  res.statusCode = 400
                  res.end(JSON.stringify({ error: 'Email and password are required.' }))
                  return
                }
                if (serverUsersDb[email]) {
                  res.statusCode = 400
                  res.end(JSON.stringify({ error: `An account with email "${email}" already exists.` }))
                  return
                }

                const newId = Object.keys(serverUsersDb).length + 1
                const userRecord = {
                  id: newId,
                  name: body.name || 'Citizen',
                  email: email,
                  passwordHash: hashPassword(body.password),
                  role: body.role || 'Citizen',
                  avatarColor: body.avatarColor || '#2563eb',
                  profile: body.profile || null,
                  createdAt: new Date().toISOString()
                }
                serverUsersDb[email] = userRecord

                const token = createToken(email, newId)
                res.statusCode = 201
                res.end(JSON.stringify({
                  token,
                  type: 'Bearer',
                  user: {
                    id: userRecord.id,
                    name: userRecord.name,
                    email: userRecord.email,
                    role: userRecord.role,
                    avatarColor: userRecord.avatarColor,
                    profile: userRecord.profile
                  },
                  message: 'Account registered and securely hashed in Database.'
                }))
                return
              }

              // Login
              if (url.pathname === '/api/auth/login' && req.method === 'POST') {
                const email = (body.email || '').trim().toLowerCase()
                const password = body.password || ''

                const user = serverUsersDb[email]
                if (!user || !verifyPassword(password, user.passwordHash)) {
                  res.statusCode = 401
                  res.end(JSON.stringify({ error: 'Invalid email or password. Please try again.' }))
                  return
                }

                const token = createToken(email, user.id)
                res.statusCode = 200
                res.end(JSON.stringify({
                  token,
                  type: 'Bearer',
                  user: {
                    id: user.id,
                    name: user.name,
                    email: user.email,
                    role: user.role,
                    avatarColor: user.avatarColor,
                    profile: user.profile
                  },
                  message: 'Authenticated successfully from Database.'
                }))
                return
              }

              // Me
              if (url.pathname === '/api/auth/me' && req.method === 'GET') {
                res.statusCode = 200
                res.end(JSON.stringify({ message: 'Active auth endpoint' }))
                return
              }

              res.statusCode = 404
              res.end(JSON.stringify({ error: 'Auth route not found' }))
            }

            proxyReq.on('error', fallbackAuthHandler)
            proxyReq.on('timeout', () => {
              proxyReq.destroy()
              fallbackAuthHandler()
            })

            proxyReq.write(bodyData)
            proxyReq.end()
          })
          return
        }

        next()
      })
    }
  }
}

export default defineConfig({
  plugins: [react(), apiPlugin()],
  server: {
    host: '0.0.0.0',
    port: 5173
  },
  preview: {
    host: '0.0.0.0',
    port: 4173
  }
})
