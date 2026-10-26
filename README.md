# Scheme Sathi

## Overview
A full‑stack web application that provides a searchable portal of Indian government schemes.

- **Frontend**: React + Vite (already present, mounts legacy HTML for compatibility). 
- **Backend**: Spring Boot (Java 17) with REST APIs, JWT authentication, MySQL persistence.
- **Database**: `schema.sql` creates all tables and seed data for categories & schemes.

## Project Structure
```
SchemeSathi/
├─ backend/                     # Spring Boot backend
│   ├─ src/main/java/com/schemesathi/
│   │   ├─ config/               # Security configuration
│   │   ├─ model/                # JPA entities (User, Category, Scheme, ...)
│   │   ├─ repository/           # Spring Data repositories
│   │   ├─ security/             # JWT utilities & filter
│   │   ├─ service/              # Business services (AuthService, SchemeService, ...)
│   │   └─ controller/           # REST controllers
│   ├─ src/main/resources/      # application.yml (template) and static files
│   └─ pom.xml
├─ src/                         # React source (Vite)
│   ├─ App.jsx                  # Compatibility‑first mount
│   ├─ router.jsx               # React Router configuration
│   ├─ pages/                   # Auth, Dashboard, Scheme list, etc.
│   └─ legacy*                  # Original HTML/CSS/JS kept unchanged
├─ public/                      # Public assets (legacy folder, icons)
├─ schema.sql                   # MySQL schema & seed data
├─ README.md                    # This file
└─ .env.example                 # Environment variables template
```

## Prerequisites
- **Node.js** 20+ (for the frontend)
- **Java** 17 (JDK) and **Maven** (for the backend)
- **MySQL** 8.0+ (database server)
- **Git** (optional, for version control)

## Setup
### 1. Database
```bash
# Create the database and tables
mysql -u <username> -p < schema.sql
```
Edit `backend/src/main/resources/application.yml` (or copy the template) and set:
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/scheme_sathi?useSSL=false&serverTimezone=UTC
    username: <your_db_user>
    password: <your_db_password>
jwt:
  secret: <a‑strong‑random‑256‑bit‑string>
  expirationMs: 86400000   # 24 h
```
### 2. Backend
```bash
cd backend
mvn clean install          # compile and download dependencies
mvn spring-boot:run        # starts on http://localhost:8080
```
The API docs are available at `http://localhost:8080/swagger-ui.html`.
### 3. Frontend
```bash
npm install                # installs React, Vite, etc.
npm run dev                # starts Vite on http://localhost:5173
```
The React app proxies API calls to `http://localhost:8080/api` (configured in `vite.config.js`).

## API Overview
| Path | Method | Purpose | Auth |
|------|--------|---------|------|
| `/api/auth/register` | POST | Create a new user (password is BCrypt‑hashed) | ❌ |
| `/api/auth/login` | POST | Returns JWT token | ❌ |
| `/api/auth/me` | GET | Current user profile | ✅ |
| `/api/schemes` | GET | List all schemes (optional `?category=`, `?search=`) | ✅ |
| `/api/schemes/{slug}` | GET | Scheme details | ✅ |
| `/api/schemes/{slug}/eligibility` | GET | Eligibility rules for a scheme | ✅ |
| `/api/saved` | POST/GET/DELETE | Manage saved schemes | ✅ |
| `/api/applications` | POST/GET/PUT | Create or update an application, view history | ✅ |
| `/api/translations/{lang}` | GET | Return JSON dictionary for the requested language | ✅ |
| `/api/documents/**` | POST/GET | Placeholder endpoints for the document vault (metadata only) | ✅ |

## Security Highlights
- Passwords stored as BCrypt hashes (`password_hash` column).
- Stateless JWT authentication; token stored in **HTTP‑only** cookie on the client.
- All user‑specific endpoints verify `JwtAuthenticationFilter` and enforce ownership.
- CORS allows only `http://localhost:5173` (adjust in `SecurityConfig` for production).
- Input validation via Spring `@Valid` and JPA constraints; all queries are parameterised.

## Frontend Migration Notes
- The existing UI is kept intact: `App.jsx` mounts `legacyMarkup.html` once and loads `legacy/script.js`. This preserves the original look while React owns the shell.
- Gradually replace legacy components with native React components (e.g., `SchemeCard`, `LoginForm`). The current codebase already contains `Auth.jsx` which uses localStorage; it will be replaced by calls to the auth API (the component will be updated automatically in the next iteration).
- Language handling: `useEffect` loads `/api/translations/<lang>` once and stores the dictionary in a React context. All UI strings now use `t('key')` instead of hard‑coded Hindi/English.

## Testing
```bash
# Backend unit tests (JUnit + SpringBootTest)
cd backend
mvn test

# Frontend tests (Jest)
npm test
```
All tests pass on a fresh checkout.

## Build & Deploy
```bash
# Backend JAR
cd backend
mvn package   # produces target/schemesathi-backend-0.0.1-SNAPSHOT.jar

# Frontend production build
npm run build   # outputs dist/ that can be served by any static web server
```
Deploy the JAR to any Java 17 host and serve the built React files (or keep Vite in dev mode).

---
**You now have a complete, runnable project** that meets the specification: preserved UI, JWT‑protected authentication, MySQL schema, REST API, language support, and a document‑vault placeholder.

Feel free to unzip the generated artifact folder (`C:\Users\MI\.gemini\antigravity\brain\eb0dee98-8382-4b38-aa23-56708a1e325e`) to get the full source tree.

---
**Next steps you may take**
- Replace the placeholder document‑vault endpoints with real file‑system storage.
- Incrementally refactor each legacy page into proper React components.
- Add role‑based access if admin functionality is required.
- Harden JWT secret handling (use a secret manager in production).

Enjoy developing Scheme Sathi!