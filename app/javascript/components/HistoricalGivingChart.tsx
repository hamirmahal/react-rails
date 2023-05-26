import {
  CategoryScale,
  Chart as ChartJS,
  Filler,
  Legend,
  LineElement,
  LinearScale,
  PointElement,
  Title,
  Tooltip
} from 'chart.js';
import React from 'react';
import { Line } from 'react-chartjs-2';
import { DateAndAmount, Filer } from '../types';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Filler,
  Legend
);

interface Props {
  datesAndAmts: Array<DateAndAmount>;
  filer: Filer;
}

const HistoricalGivingChart: React.FC<Props> = ({ datesAndAmts, filer }) => {
  const options = {
    responsive: true,
    plugins: {
      legend: {
        position: 'top' as const
      }
    }
  };

  return datesAndAmts.length === 1 ? (
    <>
      {/* Chart with 1 datapoint looks awkward;
        just display the results in text format, instead. */}
      <h3>Historical giving for {filer.name}</h3>
      <p>
        {datesAndAmts[0].taxPeriod.split('-')[0]}:{' '}
        {datesAndAmts[0].cashAmount.toLocaleString('en-US', {
          style: 'currency',
          currency: 'USD',
          minimumFractionDigits: 2
        })}
      </p>
    </>
  ) : (
    <Line
      options={options}
      data={{
        labels: datesAndAmts.map((datesAndAmts) => datesAndAmts.taxPeriod),
        datasets: [
          {
            data: datesAndAmts.map((datesAndAmts) => datesAndAmts.cashAmount),
            borderColor: 'rgb(53, 162, 235)',
            backgroundColor: 'rgba(53, 162, 235, 0.5)',
            label: 'Historical Giving'
          }
        ]
      }}
    />
  );
};

export default HistoricalGivingChart;
