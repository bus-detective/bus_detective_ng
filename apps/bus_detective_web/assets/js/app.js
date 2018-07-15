import '../css/app.scss'
import moment from 'moment'
import Leaflet from 'leaflet'

moment.relativeTimeThreshold('M', 12)
moment.relativeTimeThreshold('d', 30)
moment.relativeTimeThreshold('h', 24)
moment.relativeTimeThreshold('m', 60)
moment.relativeTimeThreshold('s', 60)

var timestamps = document.querySelectorAll('[data-timestamp]')

var updateTimestamps = () => {
  for (var i = 0; i < timestamps.length; i++) {
    let element = timestamps[i]
    let timestamp = element.dataset['timestamp']
    if (timestamp) {
      element.innerText = moment(timestamp).fromNow()
    }
  }
  setTimeout(updateTimestamps, 5000)
}

updateTimestamps()

for (var i = 0; i < timestamps.length; i++) {
  let element = timestamps[i]
  let timestamp = element.dataset['timestamp']
  if (timestamp) {
    element.innerText = moment(timestamp).fromNow()
  }
}

if (document.getElementById('stopMap')) {
  const TILE_URL = 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png'

  var mapElement = document.getElementById('stopMap')
  var map = Leaflet.map(mapElement, {
    scrollWheelZoom: false,
    zoomControl: false
  })

  var center = [mapElement.dataset['latitude'], mapElement.dataset['longitude']]
  map.setView(center, 16)
  map.addLayer(Leaflet.tileLayer(TILE_URL, {detectRetina: true}))
  Leaflet.layerGroup().addTo(map)
  Leaflet.marker(center).addTo(map)
}
