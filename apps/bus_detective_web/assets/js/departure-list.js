/* global HTMLElement */

class DepartureList extends HTMLElement {

  get departures () {
    return this.getAttribute('departures') ? JSON.parse(this.getAttribute('departures')) : [];
  }

  static get observedAttributes () {
    return ['departures'];
  }

  attributeChangedCallback () {
    this.render();
  }

  connectedCallback () {
    this.render();
  }

  render () {
    this.innerHTML = this.departures.map((departure) => `
      <bd-departure departure='${JSON.stringify(departure)}'></bd-departure>
    `).join('');
  }

  isPast () {
    return new Date(this.departureTime) < new Date();
  }
}

export default DepartureList;
