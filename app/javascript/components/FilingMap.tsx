import { geoCentroid } from 'd3-geo';
import React from 'react';
import {
  Annotation,
  ComposableMap,
  Geographies,
  Geography,
  Marker
} from 'react-simple-maps';

import allStates from '../data/allStates.json';
import Filer from '../types';
import fetchAllDataFrom from './fetchAllDataFrom';

const geoUrl = 'https://cdn.jsdelivr.net/npm/us-atlas@3/states-10m.json';

const offsets = {
  VT: [50, -8],
  NH: [34, 2],
  MA: [30, -1],
  RI: [28, 2],
  CT: [35, 10],
  NJ: [34, 1],
  DE: [33, 0],
  MD: [47, 10],
  DC: [49, 21]
};

interface Props {
  filer: Filer;
}

const FilingMap: React.FC<Props> = ({ filer }) => {
  const [loading, setLoading] = React.useState(true);
  const [stateToNumRecipients, setStateToNumRecipients] =
    React.useState<Map<string, number>>();

  React.useEffect(() => {
    const fetchData = async () => {
      const { ein } = filer;
      const formData = await fetchAllDataFrom(`/api/v1/forms?filer_ein=${ein}`);
      const stateToNumRecipients = new Map<string, number>();
      for (const form of formData) {
        const { id } = form;
        const recipientData = await fetchAllDataFrom(
          `/api/v1/recipients?form_id=${id}`
        );
        for (const recipient of recipientData) {
          const { state } = recipient;
          const count = stateToNumRecipients.get(state) ?? 0;
          stateToNumRecipients.set(state, count + 1);
        }
      }
      console.log('stateToNumRecipients is', stateToNumRecipients);
      setStateToNumRecipients(stateToNumRecipients);
      setLoading(false);
    };

    fetchData();
  }, []);

  return stateToNumRecipients?.size ? (
    <>
      <h3
        style={{
          // The `ComposableMap` component's top padding already
          // results in a significant vertical gap between itself and
          // the element before it.
          marginBottom: -40
        }}
      >
        Recipients by state
      </h3>
      <ComposableMap
        projection="geoAlbersUsa"
        projectionConfig={{
          scale: 1000
        }}
      >
        <Geographies geography={geoUrl}>
          {({ geographies }) => (
            <>
              {geographies.map((geo) => (
                <Geography
                  key={geo.rsmKey}
                  stroke="#FFF"
                  geography={geo}
                  fill="#DDD"
                />
              ))}
              {geographies.map((geo) => {
                const centroid = geoCentroid(geo);
                const cur = allStates.find((s) => s.val === geo.id);
                return (
                  <g key={geo.rsmKey + '-name'}>
                    {cur &&
                      centroid[0] > -160 &&
                      centroid[0] < -67 &&
                      (Object.keys(offsets).indexOf(cur.id) === -1 ? (
                        <Marker coordinates={centroid}>
                          <text y="2" fontSize={10} textAnchor="middle">
                            {cur.id}{' '}
                            {loading
                              ? ''
                              : stateToNumRecipients?.get(cur.id) ?? 0}
                          </text>
                        </Marker>
                      ) : (
                        <Annotation
                          subject={centroid}
                          dx={offsets[cur.id][0]}
                          dy={offsets[cur.id][1]}
                        >
                          <text x={4} fontSize={14} alignmentBaseline="middle">
                            {cur.id}{' '}
                            {loading
                              ? ''
                              : stateToNumRecipients?.get(cur.id) ?? 0}
                          </text>
                        </Annotation>
                      ))}
                  </g>
                );
              })}
            </>
          )}
        </Geographies>
      </ComposableMap>
    </>
  ) : (
    <></>
  );
};

export default FilingMap;
