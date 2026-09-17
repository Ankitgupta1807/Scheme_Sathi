import App from './App.jsx';
import { Login, Register } from './pages/Auth.jsx';
export default function Router(){const p=location.pathname; if(p==='/login') return <Login/>; if(p==='/register') return <Register/>; return <App/>;}
