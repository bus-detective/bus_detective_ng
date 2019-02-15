/* global customElements */
import '../css/app.scss';

import Departure from './departure.js';
import Favorite from './favorite.js';
import FavoritesList from './favorites-list.js';
import FavoriteStop from './favorite-stop.js';
import ExpandMap from './expand-map.js';
import NearbySearch from './nearby-search.js';
import StopMap from './stop-map.js';
import Route from './route.js';
import Timestamp from './timestamp.js';
import DepartureList from './departure-list.js';
import { createStore, dispatch } from 'wc-state-reducers';
import { subscribers, reducers } from './container';
import { debounce } from './debounce.js';

import socket from './socket.js';
import favoriteService from './favorite-service';

customElements.define('bd-departure', Departure);
customElements.define('bd-departure-list', DepartureList);
customElements.define('bd-favorite', Favorite);
customElements.define('bd-favorite-stop', FavoriteStop);
customElements.define('bd-favorites-list', FavoritesList);
customElements.define('bd-expand-map', ExpandMap);
customElements.define('bd-nearby-search', NearbySearch);
customElements.define('bd-stop-map', StopMap);
customElements.define('bd-timestamp', Timestamp);
customElements.define('bd-route', Route);

window.store = createStore(document, reducers, subscribers);

if (window.stopId) {
  let channel = socket.channel('stops', {stop_id: window.stopId});
  var reloadTimeout;
  let reloadDepartures = debounce(function () {
    window.clearTimeout(reloadTimeout);
    console.log(`Server didn't refresh departures in 60 seconds -- requesting departures.`);
    channel.push('reload_departures', {});
    reloadTimeout = window.setTimeout(reloadDepartures, 60000);
  }, 1000);

  channel.on('departures', message => {
    window.clearTimeout(reloadTimeout);
    console.log('Received Departures', message);
    dispatch(document, 'updateDepartures', message.departures);
    reloadTimeout = window.setTimeout(reloadDepartures, 60000);
  });

  channel.on('trip_shapes', message => {
    dispatch(document, 'updateTripShapes', message.shapes);
    console.log('Received Trip Shapes', message);
  });

  channel.on('vehicle_positions', message => {
    dispatch(document, 'updateVehiclePositions', message.vehicle_positions);
    console.log('Received Vehicle Positions', message);
  });

  channel.join()
    .receive(
      'ok',
      resp => {
        console.log('Joined successfully', resp);
        window.clearTimeout(reloadTimeout);
        reloadTimeout = window.setTimeout(reloadDepartures, 60000);
      }
    )
    .receive('error', resp => { console.log('Unable to join', resp); });
} else {
  let channel = socket.channel('favorites:stops', {});

  channel.on('favorites_list', message => {
    console.log('Received Favorites', message);
    dispatch(document, 'updateFavorites', message.stops);
  });

  channel.join()
    .receive('ok', resp => { })
    .receive('error', resp => { console.log('Unable to join', resp); });

  channel.push('load_stops', {stop_ids: favoriteService.all()});
};

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js');
};
