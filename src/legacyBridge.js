import legacyMarkup from './legacyMarkup.html?raw';

export function mountLegacySchemeSathi(root) {
  root.innerHTML = legacyMarkup;

  // Keep the original global functions available because the supplied HTML
  // contains inline onclick handlers. The original stylesheet is loaded once
  // by main.jsx, and the original JS is loaded after the DOM exists.
  const old = document.querySelector('script[data-scheme-sathi-legacy]');
  if (old) old.remove();
  const script = document.createElement('script');
  script.src = '/legacy/script.js';
  script.async = false;
  script.dataset.schemeSathiLegacy = 'true';
  script.onload = () => {
    // The legacy file registers its initializer on DOMContentLoaded. Since React
    // injects the markup after the browser's DOMContentLoaded event, trigger the
    // event once after the legacy script has registered its listener.
    document.dispatchEvent(new Event('DOMContentLoaded'));
  };
  document.body.appendChild(script);

  return () => {
    script.remove();
  };
}
