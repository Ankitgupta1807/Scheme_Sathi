import { useEffect, useRef } from 'react';
import { mountLegacySchemeSathi } from './legacyBridge';

export default function App() {
  const root = useRef(null);
  useEffect(() => {
    if (!root.current) return;
    mountLegacySchemeSathi(root.current);
  }, []);
  return <div ref={root} id="scheme-sathi-react-root" />;
}
