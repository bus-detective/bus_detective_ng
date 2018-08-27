
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
  }
};

const expandMap = (state, { mapExpanded }) => {
  return Object.assign(state, { mapExpanded });
};

const updateTripShapes = (state, tripShapes) => {
  return Object.assign(state, { tripShapes });
};

const updateVehiclePositions = (state, vehiclePositions) => {
  return Object.assign(state, { vehiclePositions });
};

export const reducers = { expandMap, updateTripShapes, updateVehiclePositions };
