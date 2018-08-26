/* global customElements */
import '../css/app.scss';

import Departure from './departure.js';
import Favorite from './favorite.js';
import FavoritesList from './favorites-list.js';
import ExpandMap from './expand-map.js';
import NearbySearch from './nearby-search.js';
import StopMap from './stop-map.js';
import Route from './route.js';
import Timestamp from './timestamp.js';
import { connect, dispatch } from './reduxish.js';
import { subscribers, reducers } from './container';

import socket from './socket.js';

customElements.define('bd-departure', Departure);
customElements.define('bd-favorite', Favorite);
customElements.define('bd-favorites-list', FavoritesList);
customElements.define('bd-expand-map', ExpandMap);
customElements.define('bd-nearby-search', NearbySearch);
customElements.define('bd-stop-map', StopMap);
customElements.define('bd-timestamp', Timestamp);
customElements.define('bd-route', Route);

connect(reducers, subscribers);

if (window.stopId) {
  let channel = socket.channel(`stops:${window.stopId}`);

  channel.on('departures', message => {
    console.log('Received Departures', message);
    let departuresList = document.querySelector('[data-selector="departures-list"]');
    if (message.departures.length > 0) {
      departuresList.innerHTML = message.departures.join('');
    } else {
      departuresList.innerHTML = '<p class="text-center">No departures found</p>';
    }
  });

  channel.on('vehicle_positions', message => {
    dispatch('updateVehiclePositions', message.vehicle_positions);
    console.log('Received Vehicle Positions', message);
  });

  channel.join()
    .receive('ok', resp => { console.log('Joined successfully', resp); })
    .receive('error', resp => { console.log('Unable to join', resp); });
}
