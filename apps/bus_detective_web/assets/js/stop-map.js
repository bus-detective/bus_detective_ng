/* global HTMLElement */
import Leaflet from 'leaflet';

Leaflet.Control.Attribution.prototype.options.prefix = ' Leaflet';
Leaflet.Icon.Default.imagePath = '/images/';

class StopMap extends HTMLElement {

  constructor() {
    super();
    this.busMarkers = [];
  }

  get latitude () {
    return this.getAttribute('latitude');
  }

  get longitude () {
    return this.getAttribute('longitude');
  }

  get expanded () {
    return this.getAttribute('expanded') === 'true';
  }

  get vehiclePositions () {
    return this.getAttribute('vehicle-positions') ?
      JSON.parse(this.getAttribute('vehicle-positions')) : [];
  }

  get busIconUrl () {
    return this.getAttribute('bus-icon-url');
  }

  static get observedAttributes () {
    return ['expanded', 'vehicle-positions'];
  }

  attributeChangedCallback () {
    this.displayVehicles();
    if (this.expanded) {
      this.querySelector('#stopMap').classList.add('map--expanded');
    } else {
      this.querySelector('#stopMap').classList.remove('map--expanded');
    }
    this.map.invalidateSize();
  }

  displayVehicles() {
    const busIcon = L.icon({ iconUrl: this.busIconUrl });
    this.busMarkers.forEach((marker) => marker.removeFrom(this.map));
    this.busMarkers = this.vehiclePositions.map((vehiclePosition) => {
       const busMarker = L.marker([vehiclePosition.latitude, vehiclePosition.longitude], {icon: busIcon});
       busMarker.addTo(this.map);
       return busMarker;
    });
  }

  connectedCallback () {
    this.innerHTML = `
      <div id="stopMap" class="map"></div>
    `;

    const TILE_URL = 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';
    this.map = Leaflet.map(this.querySelector('#stopMap'), {
      scrollWheelZoom: false,
      zoomControl: false
    });

    var center = [this.latitude, this.longitude];
    this.map.setView(center, 16);
    this.map.addLayer(Leaflet.tileLayer(TILE_URL, {detectRetina: true}));
    Leaflet.layerGroup().addTo(this.map);
    Leaflet.marker(center).addTo(this.map);
    this.displayVehicles();
  }
}

export default StopMap;
