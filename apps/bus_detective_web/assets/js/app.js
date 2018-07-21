import '../css/app.scss'

import StopMap from './stop-map.js'
import Route from './route.js';
import Timestamp from './timestamp.js';

customElements.define('bd-stop-map', StopMap);
customElements.define('bd-timestamp', Timestamp);
customElements.define('bd-route', Route);
