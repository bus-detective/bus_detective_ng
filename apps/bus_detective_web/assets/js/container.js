
export const subscribers = {
  'bd-stop-map': ({ mapExpanded, vehiclePositions, tripShapes }, element) => {
    element && element.setAttribute('expanded', mapExpanded);
    element && tripShapes &&
      element.setAttribute('trip-shapes', JSON.stringify(tripShapes));
    element && vehiclePositions &&
      element.setAttribute('vehicle-positions', JSON.stringify(vehiclePositions));
  },
  'bd-expand-map': ({ mapExpanded }, element) => {
    element && element.setAttribute('expanded', mapExpanded);
  },
  'bd-departure-list': ({ departures }, element) => {
    element && element.setAttribute('departures', JSON.stringify(departures));
  }
};

export const expandMap = (state, { mapExpanded }) => {
  return Object.assign(state, { mapExpanded });
};

export const updateTripShapes = (state, tripShapes) => {
  return Object.assign(state, { tripShapes });
};

export const updateVehiclePositions = (state, vehiclePositions) => {
  return Object.assign(state, { vehiclePositions });
};

export const updateDepartures = (state, departures) => {
  if (state.departures) {
    const keepingDepartures = state.departures.filter(departure => !departure.removed);
    const removedDepartures = keepingDepartures.filter(departure => !departures.map(d => d.id).includes(departure.id));
    removedDepartures.forEach(removedDeparture => {
      removedDeparture.removed = true;
    });
    const newDepartures = departures.filter(departure => !state.departures.map(d => d.id).includes(departure.id));
    newDepartures.forEach((newDeparture) => {
      newDeparture.added = true;
    });
    return Object.assign(state, { departures: removedDepartures.concat(departures) });
  }
  return Object.assign(state, { departures });
};

export const reducers = { expandMap, updateTripShapes, updateVehiclePositions, updateDepartures };
