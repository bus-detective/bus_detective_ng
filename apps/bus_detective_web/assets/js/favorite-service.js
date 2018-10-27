/* global window */

class FavoriteService {
  get storeKey () {
    return 'favorites';
  }

  get store () {
    return window.localStorage;
  }

  add (stopId) {
    var newStops = this.all().concat(stopId);
    this.replaceStops(newStops);
  }

  remove (stopId) {
    var newStops = this.all().filter((id) => id !== stopId);
    this.replaceStops(newStops);
  }

  hasStop (stopId) {
    return !!this.all().find((id) => id === stopId);
  }

  all () {
    var stops = this.store[this.storeKey];
    return stops ? JSON.parse(stops) : [];
  }

  replaceStops (stops) {
    this.store[this.storeKey] = JSON.stringify(stops);
  }
}

export default new FavoriteService();
