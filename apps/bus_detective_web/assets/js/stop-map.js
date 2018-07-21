import Leaflet from 'leaflet';

class StopMap extends HTMLElement {

  get latitude() {
    return this.getAttribute("latitude");
  }

  get longitude() {
    return this.getAttribute("longitude");
  }

  connectedCallback() {
    this.innerHTML = `
      <div id="stopMap" class="map"></div>
    `;


    const TILE_URL = 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png'
    var map = Leaflet.map(this.querySelector("#stopMap"), {
      scrollWheelZoom: false,
      zoomControl: false
    })

    var center = [this.latitude, this.longitude]
    map.setView(center, 16)
    map.addLayer(Leaflet.tileLayer(TILE_URL, {detectRetina: true}))
    Leaflet.layerGroup().addTo(map)
    Leaflet.marker(center).addTo(map)

  }
}

export default StopMap;
