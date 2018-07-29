/* global customElements */
import '../css/app.scss';

import NearbySearch from './nearby-search.js';
import StopMap from './stop-map.js';
import Stop from './stop.js';
import Route from './route.js';
import Timestamp from './timestamp.js';

customElements.define('bd-nearby-search', NearbySearch);
customElements.define('bd-stop-map', StopMap);
customElements.define('bd-stop', Stop);
customElements.define('bd-timestamp', Timestamp);
customElements.define('bd-route', Route);
