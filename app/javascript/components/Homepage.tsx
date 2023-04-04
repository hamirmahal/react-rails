import React, { useEffect, useState } from 'react';

import Filer from '../types';
import './App.css';
import FilerCard from './FilerCard';

function Homepage() {
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
    <>
      <header
        style={{
          marginBottom: '5%'
        }}
      >
        Filers
      </header>
      <main>
        {filers ? (
          <div
            style={{
              display: 'block',
              justifyContent: 'center',
              alignItems: 'center'
            }}
          >
            {filers.map((filer) => (
              <FilerCard key={filer.ein} filer={filer} />
            ))}
          </div>
        ) : (
          <p>There was an error fetching filers.</p>
        )}
      </main>
    </>
  );
}

export default Homepage;
