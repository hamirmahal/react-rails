import { Oval, useLoading } from '@agney/react-loading';
import React from 'react';
import { useParams } from 'react-router-dom';
import { DateAndAmount, Filer } from '../types';
import FilingMap from './FilingMap';
import HistoricalGivingChart from './HistoricalGivingChart';
import fetchAllDataFrom from './fetchAllDataFrom';

const FilerPage = () => {
  const { ein } = useParams();
  const [filer, setFiler] = React.useState<Filer>();
  const [loading, setLoading] = React.useState(true);
  const [datesAndAmts, setDatesAndAmts] = React.useState<DateAndAmount[]>([]);
  const { indicatorEl } = useLoading({
    loading,
    indicator: <Oval width="50" />
  });
  const [stateToNumRecipients, setStateToNumRecipients] = React.useState(
    new Map<string, number>()
  );

  React.useEffect(() => {
    const fetchFilerData = async () => {
      const data = await fetchAllDataFrom(`/api/v1/filers?ein=${ein}`);
      console.log(data);
      setFiler(data[0]);
    };

    const getDataForMapAndHistoricalGivingChart = async () => {
      const startTime = performance.now();
      const formData = await fetchAllDataFrom(`/api/v1/forms?filer_ein=${ein}`);
      const stateToNumRecipients = new Map<string, number>();
      const taxPeriodsAndCash: Array<DateAndAmount> = [];

      for (const form of formData) {
        const { id, tax_period }: { id: number; tax_period: string } = form;
        const recipientData = await fetchAllDataFrom(
          `/api/v1/recipients?form_id=${id}`
        );

        // This is to populate the data for the U.S. map.
        for (const recipient of recipientData) {
          const { state } = recipient;
          const count = stateToNumRecipients.get(state) ?? 0;
          stateToNumRecipients.set(state, count + 1);
        }

        // This next section is to populate the data for the historical giving chart.
        /**
         * This amount is in whole dollars, with some cents included at the end.
         * @example 5216678 => $5,216,678.00
         */
        let cashAmount = 0;
        for (const recipient of recipientData) {
          const { cash_grant } = recipient;
          cashAmount += parseInt(cash_grant, 10);
        }
        taxPeriodsAndCash.push({
          taxPeriod: tax_period,
          cashAmount
        });
      }

      taxPeriodsAndCash.sort((a, b) => a.taxPeriod.localeCompare(b.taxPeriod));
      taxPeriodsAndCash.forEach((obj) => {
        // Just keep the year portion of the tax period,
        // since it's the only part that changes.
        obj.taxPeriod = obj.taxPeriod.split('-')[0];
      });

      console.log('stateToNumRecipients is', stateToNumRecipients);
      console.log('taxPeriodsAndCash is', taxPeriodsAndCash);
      setStateToNumRecipients(stateToNumRecipients);
      setDatesAndAmts(taxPeriodsAndCash);
      setLoading(false);
      const endTime = performance.now();
      const elapsedTime = endTime - startTime;
      console.log(
        `It took ${elapsedTime / 1000} seconds to initialize the data.`
      );
    };

    fetchFilerData();
    getDataForMapAndHistoricalGivingChart();
  }, []);

  if (filer) {
    return (
      <main>
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
          {loading ? (
            indicatorEl
          ) : (
            <>
              <HistoricalGivingChart
                datesAndAmts={datesAndAmts}
                filer={filer}
              />
              <FilingMap stateToNumRecipients={stateToNumRecipients} />
            </>
          )}
        </div>
      </main>
    );
  }

  return (
    <main>
      {loading ? (
        indicatorEl
      ) : (
        <p>There was an error fetching the filer with EIN {ein}.</p>
      )}
    </main>
  );
};

export default FilerPage;
