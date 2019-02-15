import favoriteService from './favorite-service';

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
    element && departures && element.setAttribute('departures', JSON.stringify(departures));
  },
  'bd-favorites-list': ({ favorites }, element) => {
    element && favorites && element.setAttribute('favorites', JSON.stringify(favorites));
  }
};

export const expandMap = (state, { mapExpanded }) => {
  return Object.assign({}, state, { mapExpanded });
};

export const updateTripShapes = (state, tripShapes) => {
  return Object.assign({}, state, { tripShapes });
};

export const updateVehiclePositions = (state, vehiclePositions) => {
  return Object.assign({}, state, { vehiclePositions });
};

export const updateFavorites = (state, favorites) => {
  // sort by user preferred order
  const favoriteIds = favoriteService.all();
  const sortedFavorites = favoriteIds.map((id) => favorites.find((stop) => stop.id === id));
  return Object.assign({}, state, { favorites: sortedFavorites });
};

export const moveFavorite = (state, { from, to, before }) => {
  const fromFavorite = state.favorites.find((stop) => stop.id === from);
  const newFavorites = state.favorites.filter((stop) => stop.id !== from);
  const indexOfTo = newFavorites.findIndex((stop) => stop.id === to);
  newFavorites.splice(indexOfTo + (before ? 0 : 1), 0, fromFavorite);
  favoriteService.replaceStops(newFavorites.map((stop) => stop.id));
  return Object.assign({}, state, { favorites: newFavorites });
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
    return Object.assign({}, state, { departures: removedDepartures.concat(departures) });
  }
  return Object.assign({}, state, { departures });
};

export const reducers = { expandMap, updateTripShapes, updateVehiclePositions, updateDepartures, updateFavorites, moveFavorite };
