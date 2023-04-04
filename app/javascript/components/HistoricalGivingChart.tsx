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
import React, { useEffect, useState } from 'react';
import { Line } from 'react-chartjs-2';
import Filer from '../types';
import fetchAllDataFrom from './fetchAllDataFrom';

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

interface DateAndAmounts {
  taxPeriod: string;
  cashAmount: number;
}

interface Props {
  filer: Filer;
}

const HistoricalGivingChart: React.FC<Props> = ({ filer }) => {
  const [datesAndAmts, setDatesAndAmts] = useState<Array<DateAndAmounts>>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      const { ein } = filer;
      const formData = await fetchAllDataFrom(`/api/v1/forms?filer_ein=${ein}`);
      const taxPeriodsAndCash: Array<DateAndAmounts> = [];
      for (const datum of formData) {
        const { id, tax_period }: { id: number; tax_period: string } = datum;
        /**
         * This amount is in whole dollars, with some cents included at the end.
         * @example 5216678 => $5,216,678.00
         */
        let cashAmount = 0;
        const recipientData = await fetchAllDataFrom(
          `/api/v1/recipients?form_id=${id}`
        );
        for (const recipient of recipientData) {
          const { cash_grant } = recipient;
          cashAmount += parseInt(cash_grant, 10);
        }
        taxPeriodsAndCash.push({
          taxPeriod: tax_period,
          cashAmount
        });
      }
      // Just keep the year portion of the tax period,
      // since it's the only part that changes.
      taxPeriodsAndCash.forEach((obj) => {
        obj.taxPeriod = obj.taxPeriod.split('-')[0];
      });
      taxPeriodsAndCash.sort((a, b) => {
        return a.taxPeriod.localeCompare(b.taxPeriod);
      });
      console.log('taxPeriodsAndCash is', taxPeriodsAndCash);
      setDatesAndAmts(taxPeriodsAndCash);
      setLoading(false);
    };

    fetchData();
  }, []);

  const options = {
    responsive: true,
    plugins: {
      legend: {
        position: 'top' as const
      }
    }
  };
  return datesAndAmts[0]?.cashAmount ? (
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
  ) : loading ? (
    <p>Loading...</p>
  ) : (
    <p>No historical giving information available</p>
  );
};

export default HistoricalGivingChart;
