# Scheme Sathi

## Overview
A full-stack web application that provides a searchable portal of Indian government schemes, eligibility matching, document management, and personalized citizen recommendations.

- **Frontend**: React + Vite (supports compatibility mounting of the legacy portal while providing React routes for authentication and modular pages).
- **Backend**: Spring Boot (Java 17) with REST APIs, JWT authentication, and MySQL persistence.
- **Database**: `schema.sql` creates all tables and seed data for categories, schemes, and eligibility rules.

---

## Project Structure
```
SchemeSathi/
├─ backend/                     # Spring Boot backend (Java 17, Maven)
│   ├─ src/main/java/com/schemesathi/
│   │   ├─ config/               # Security configuration & CORS
│   │   ├─ controller/           # REST controllers (Auth, Schemes, etc.)
│   │   ├─ dto/                  # Data transfer objects
│   │   ├─ model/                # JPA entities (User, Category, Scheme, ...)
│   │   ├─ repository/           # Spring Data JPA repositories
│   │   ├─ security/             # JWT token provider & security filters
│   │   └─ service/              # Business logic (AuthService, SchemeService)
│   ├─ src/main/resources/      # application.yml configuration
│   └─ pom.xml
├─ src/                         # React source (Vite)
│   ├─ App.jsx                  # Main application shell
│   ├─ router.jsx               # React Router configuration
│   ├─ pages/                   # Auth (Login/Register), Dashboard, etc.
│   ├─ legacyBridge.js          # Compatibility bridge for legacy portal scripts
│   └─ legacyMarkup.html        # Portal markup
├─ public/                      # Static assets & legacy runtime assets
├─ schema.sql                   # MySQL schema & seed data
├─ vite.config.js               # Vite config with proxy & fallback mock API
├─ package.json                 # Frontend dependencies & scripts
└─ README.md                    # Project documentation
```

---

## Prerequisites
- **Node.js** 18+ (20+ recommended)
- **Java** 17 (JDK) & **Maven** 3.8+ (for backend)
- **MySQL** 8.0+ (optional, Vite provides built-in API fallback when backend is offline)

---

## Getting Started

### 1. Frontend Quickstart
```bash
# Install dependencies
npm install

# Start Vite dev server
npm run dev
```
Open [http://localhost:5173](http://localhost:5173) in your browser.

#### Routes
- `/` — Scheme Sathi portal and eligibility matching engine
- `/login` — User Login (JWT-authenticated with localStorage fallback)
- `/register` — Citizen Registration

### 2. Backend Setup (Optional / Full-Stack)
```bash
# Setup MySQL Database
mysql -u <username> -p < schema.sql
```

Configure `backend/src/main/resources/application.yml` with your database credentials:
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/scheme_sathi?useSSL=false&serverTimezone=UTC
    username: <your_db_user>
    password: <your_db_password>
jwt:
  secret: SchemeSathiSuperSecretKeyForJwtSigningMustBe256BitsLong!
  expirationMs: 86400000   # 24 hours
```

Run the backend:
```bash
cd backend
mvn clean install
mvn spring-boot:run
```
The backend server runs on `http://localhost:8080`.

---

## API Overview

| Endpoint | Method | Purpose | Auth Required |
| :--- | :--- | :--- | :--- |
| `/api/auth/register` | POST | Create user account (BCrypt hashed) | No |
| `/api/auth/login` | POST | Authenticate & return JWT token | No |
| `/api/auth/me` | GET | Current user profile | Yes |
| `/api/schemes` | GET | List all schemes with optional search/category filters | Yes |
| `/api/schemes/{id}` | GET | Scheme detail & eligibility criteria | Yes |

---

## Build & Production
```bash
# Frontend production build
npm run build

# Backend package JAR
cd backend
mvn clean package
```
