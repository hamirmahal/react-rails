import * as React from 'react';
import * as ReactDOMClient from 'react-dom/client';
import App from './App';

const container = document.getElementById('root');
if (container) {
  const root = ReactDOMClient.createRoot(container);
  document.addEventListener('DOMContentLoaded', () => {
    root.render(
      <React.StrictMode>
        <App />
      </React.StrictMode>
    );
  });
} else {
  console.error("Expected to see an element with id 'root', but didn't");
}
