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

  move (from, to, before) {
    const newStops = this.all().filter((id) => id !== from);
    const targetIndex = newStops.indexOf(to) + (before ? 0 : 1);
    newStops.splice(targetIndex, 0, from);
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
