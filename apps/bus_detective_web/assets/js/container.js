
export const subscribers = {
  'bd-stop-map': ({ mapExpanded }, element) => {
    element && element.setAttribute('expanded', mapExpanded);
  },
  'bd-expand-map': ({ mapExpanded }, element) => {
    element && element.setAttribute('expanded', mapExpanded);
  },
  'bd-stop-map': ({ vehiclePositions }, element) => {
    element && vehiclePositions &&
      element.setAttribute('vehicle-positions', JSON.stringify(vehiclePositions));
  }
};

const expandMap = (state, { mapExpanded }) => {
  return Object.assign(state, { mapExpanded });
};

const updateVehiclePositions = (state, vehiclePositions) => {
  return Object.assign(state, { vehiclePositions });
}

export const reducers = { expandMap, updateVehiclePositions };
