/* global HTMLElement */

class Departure extends HTMLElement {
  get departureTime () {
    return this.getAttribute('data-departure-time');
  }

  get departure() {
    return this.getAttribute('departure') ? JSON.parse(this.getAttribute('departure')) : {}
  }

  connectedCallback () {
    const update = () => {
      if (this.isPast()) {
        this.classList.add('event--past');
        this.classList.remove('event--future');
      } else {
        this.classList.add('event--future');
        this.classList.remove('event--past');
      }
      setTimeout(update, 1000);
    };
    update();
    this.innerHTML = `
    <div class="timeline__event event event--future" data-departure-time="${this.departure.time}">
      <div class="event__time">${this.departure.time}</div>
      <div class="event__event-details">
        <div class="event__marker"></div>
        <div>
          <bd-route bg-color="${this.departure.route.color}" color="${this.departure.route.text_color}" name="${this.departure.route.short_name}"></bd-route>
          <span class="event__relative-time">
            ${ this.departure.realtime ? 'scheduled' : ''}
            <bd-timestamp timestamp="${this.departure.time}"></bd-timestamp>
          </span>
          <p class="event__title">${this.departure.trip.headsign}</p>
        </div>
      </div>
    </div>

    `;
  }

  isPast () {
    return new Date(this.departureTime) < new Date();
  }
}

export default Departure;
