import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import Filer from '../types';
import FilingMap from './FilingMap';
import HistoricalGivingChart from './HistoricalGivingChart';
import fetchAllDataFrom from './fetchAllDataFrom';

const FilerPage = () => {
  const { ein } = useParams();
  const [filer, setFiler] = useState<Filer>();

  useEffect(() => {
    const fetchData = async () => {
      const data = await fetchAllDataFrom(`/api/v1/filers?ein=${ein}`);
      console.log(data);
      setFiler(data[0]);
    };

    fetchData();
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
          {/* @TODO: Refactor similar recipient data gathering logic. */}
          <HistoricalGivingChart filer={filer} />
          <FilingMap filer={filer} />
        </div>
      ) : (
        <p>There was an error fetching the filer with EIN {ein}.</p>
      )}
    </main>
  );
};

export default FilerPage;
