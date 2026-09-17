# Scheme Sathi — React/Vite migration

## Run
1. Install Node.js 18+ (20+ recommended).
2. `npm install`
3. `npm run dev`
4. Open the Vite URL.

## Routes
- `/` — original Scheme Sathi portal mounted under React
- `/login` — React Login
- `/register` — React Register

## Why this migration is compatibility-first
The supplied portal is a large DOM-driven SPA with many inline event handlers and imperative functions. To preserve the same UI and behavior instead of accidentally breaking features, React mounts the supplied portal markup once and loads its existing JavaScript after the DOM exists. The CSS is reused unchanged. This is a safe first migration step; individual modules can then be converted to native React components one by one.

## IndexedDB
The original document vault continues to use the browser's IndexedDB implementation through the supplied JS. The migration does not move documents to a server.

## Production security note
The supplied prototype login/register stores plaintext passwords in localStorage. Do not use that for a real public deployment; use a backend with password hashing, secure sessions/tokens, HTTPS and server-side validation.
"# Scheme_Sathi" 
