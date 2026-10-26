import { useEffect, useRef } from 'react';
import { mountLegacySchemeSathi } from './legacyBridge';

// Compatibility-first React migration:
// The supplied DOM/CSS/JS is mounted once so the existing UI and all of its
// DOM-based behaviors remain pixel/feature compatible while React owns the app shell.
export default function App() {
  const root = useRef(null);
  useEffect(() => {
    if (!root.current) return;
    mountLegacySchemeSathi(root.current);
  }, []);
  return <div ref={root} id="scheme-sathi-react-root" />;
}
