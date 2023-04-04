import React, { useEffect, useState } from 'react';
import { Route, BrowserRouter as Router, Routes } from 'react-router-dom';

import Filer from '../types';
import './App.css';
import FilerPage from './FilerPage';
import Homepage from './Homepage';

function App() {
  const [filers, setFilers] = useState<Array<Filer>>();

  useEffect(() => {
    fetch(`/api/v1/filers`)
      .then((response) => response.json())
      .then((data) => {
        console.log(data);
        setFilers(data);
      });
  }, []);

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
