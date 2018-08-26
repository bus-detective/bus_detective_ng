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
  let channel = socket.channel('stops', {stop_id: window.stopId});
  var reloadTimeout;
  let reloadDepartures = function () {
    window.clearTimeout(reloadTimeout);
    console.log(`Server didn't refresh departures in 60 seconds -- requesting departures.`);
    channel.push('reload_departures', {});
    reloadTimeout = window.setTimeout(reloadDepartures);
  };

  channel.on('departures', message => {
    window.clearTimeout(reloadTimeout);
    console.log('Received Departures', message);
    let departuresList = document.querySelector('[data-selector="departures-list"]');
    if (message.departures.length > 0) {
      departuresList.innerHTML = message.departures.join('');
    } else {
      departuresList.innerHTML = '<p class="text-center">No departures found</p>';
    }
    reloadTimeout = window.setTimeout(reloadDepartures, 60000);
  });

  channel.on('vehicle_positions', message => {
    dispatch('updateVehiclePositions', message.vehicle_positions);
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
}
