
export const subscribers = {
  'bd-stop-map': ({ mapExpanded, vehiclePositions }, element) => {
    element && element.setAttribute('expanded', mapExpanded);
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

const updateVehiclePositions = (state, vehiclePositions) => {
  return Object.assign(state, { vehiclePositions });
}

export const reducers = { expandMap, updateVehiclePositions };
