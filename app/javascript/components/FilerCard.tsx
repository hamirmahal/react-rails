import React from 'react';
import { Link } from 'react-router-dom';
import Filer from '../types';

interface Props {
  filer: Filer;
}

const FilerCard: React.FC<Props> = ({ filer }) => {
  return (
    <div
      style={{
        border: '1px solid #ccc',
        borderRadius: 5,
        padding: 30,
        margin: 10,
        display: 'block',
        alignItems: 'center'
      }}
    >
      <h3 style={{ marginBottom: 0 }}>{filer.name}</h3>
      <p style={{ marginTop: 0 }}>{filer.ein}</p>
      <p>{filer.address_line_1}</p>
      <p>
        {filer.city}, {filer.state} {filer.zip}
      </p>
      <Link to={`/filers/${filer.ein}`}>View Details</Link>
    </div>
  );
};

export default FilerCard;
