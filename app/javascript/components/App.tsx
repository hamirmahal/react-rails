import React from 'react';
import { Route, BrowserRouter as Router, Routes } from 'react-router-dom';

import './App.css';
import FilerPage from './FilerPage';
import Homepage from './Homepage';

function App() {
  return (
    <div className="App">
      <Router>
        <Routes>
          <Route path="/" Component={Homepage} />
          <Route path="/filers/:ein" Component={FilerPage} />
        </Routes>
      </Router>
    </div>
  );
}

export default App;
