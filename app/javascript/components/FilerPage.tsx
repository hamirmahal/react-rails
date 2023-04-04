import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import Filer from '../types';

const FilerPage = () => {
  const { ein } = useParams();
  const [filer, setFiler] = useState<Filer>();

  useEffect(() => {
    fetch(`/api/v1/filers?ein=${ein}`)
      .then((response) => response.json())
      .then((data) => {
        console.log(data);
        setFiler(data[0]);
      });
  }, []);

  return (
    <main>
      {filer ? (
        <div
          style={{
            display: 'block',
            justifyContent: 'center',
            alignItems: 'center'
          }}
        >
          <h2>{filer.name}</h2>
          <p>EIN: {filer.ein}</p>
          <p>
            Address: {filer.address_line_1}, {filer.city}, {filer.state},{' '}
            {filer.zip}
          </p>
        </div>
      ) : (
        <p>There was an error fetching filers.</p>
      )}
    </main>
  );
};

export default FilerPage;
