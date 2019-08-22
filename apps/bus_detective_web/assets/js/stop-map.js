/* global HTMLElement */
import Leaflet from 'leaflet';

Leaflet.Control.Attribution.prototype.options.prefix = ' Leaflet';
Leaflet.Icon.Default.imagePath = '/images/';

class StopMap extends HTMLElement {
  constructor () {
    super();
    this.busMarkers = {};
    this.shapeLayer = null;
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

  get tripShapes () {
    return this.getAttribute('trip-shapes')
      ? JSON.parse(this.getAttribute('trip-shapes')) : [];
  }

  get vehiclePositions () {
    return this.getAttribute('vehicle-positions')
      ? JSON.parse(this.getAttribute('vehicle-positions')) : [];
  }

  get busIconUrl () {
    return this.getAttribute('bus-icon-url');
  }

  static get observedAttributes () {
    return ['expanded', 'vehicle-positions', 'trip-shapes'];
  }

  attributeChangedCallback () {
    this.displayVehicles();
    this.displayTripShapes();
    if (this.expanded) {
      this.querySelector('#stopMap').classList.add('map--expanded');
    } else {
      this.querySelector('#stopMap').classList.remove('map--expanded');
    }
    this.map.invalidateSize();
  }

  displayTripShapes () {
    this.shapeLayer.clearLayers();

    let shapes = this.tripShapes.map((tripShape) => {
      let shapeLine = Leaflet.polyline(tripShape.coordinates, { color: `#${tripShape.route_color}`, weight: 6 });
      shapeLine.bindTooltip(
        `
          <div class="map-bus-label" style="background-color: #${tripShape.route_color}; color: #${tripShape.route_text_color};">
            ${tripShape.route_name}
          </div>
        `, {sticky: true}
      );
      return shapeLine;
    });

    this.shapeLayer.addLayer(Leaflet.layerGroup(shapes));
  }

  displayVehicles () {
    const busIcon = Leaflet.icon({ iconUrl: this.busIconUrl });

    const updatedBusIds = this.vehiclePositions.map((vehiclePosition) => vehiclePosition.vehicle_label);
    for (var busId in this.busMarkers) {
      if (!updatedBusIds.includes(busId)) {
        this.busMarkers[busId].removeFrom(this.map);
      }
    };

    this.vehiclePositions.forEach((vehiclePosition) => {
      if (vehiclePosition.vehicle_label in this.busMarkers) {
        let newLatLng = new Leaflet.LatLng(vehiclePosition.latitude, vehiclePosition.longitude);
        this.busMarkers[vehiclePosition.vehicle_label].setLatLng(newLatLng).update();
      } else {
        let busMarker = this.busMarkers[vehiclePosition.vehicle_label] = Leaflet.marker([vehiclePosition.latitude, vehiclePosition.longitude], {icon: busIcon});
        busMarker.bindTooltip(
          `
          <div class="map-bus-label" style="background-color: #${vehiclePosition.route_color}; color: #${vehiclePosition.route_text_color};">
            ${vehiclePosition.route_name}
          </div>
        `,
          {permanent: true, direction: 'top'});
        busMarker.addTo(this.map);
      }
    });
  }

  connectedCallback () {
    this.innerHTML = `
      <div id="stopMap" class="map"></div>
    `;

    const TILE_URL = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    this.map = Leaflet.map(this.querySelector('#stopMap'), {
      scrollWheelZoom: false,
      zoomControl: true
    });

    var center = [this.latitude, this.longitude];
    this.map.setView(center, 17);
    this.map.addLayer(Leaflet.tileLayer(TILE_URL, {detectRetina: true}));
    Leaflet.layerGroup().addTo(this.map);
    Leaflet.marker(center).addTo(this.map);
    this.shapeLayer = Leaflet.layerGroup().addTo(this.map);
    this.displayVehicles();
    this.displayTripShapes();
  }
}

export default StopMap;
