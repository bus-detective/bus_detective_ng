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

customElements.define('bd-departure', Departure);
customElements.define('bd-favorite', Favorite);
customElements.define('bd-favorites-list', FavoritesList);
customElements.define('bd-expand-map', ExpandMap);
customElements.define('bd-nearby-search', NearbySearch);
customElements.define('bd-stop-map', StopMap);
customElements.define('bd-timestamp', Timestamp);
customElements.define('bd-route', Route);
