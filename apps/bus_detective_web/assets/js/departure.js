import moment from 'moment';
import 'moment-timezone';

/* global HTMLElement */

class Departure extends HTMLElement {
  get departureTime () {
    return this.getAttribute('data-departure-time');
  }

  get departure () {
    return this.getAttribute('departure') ? JSON.parse(this.getAttribute('departure')) : {};
  }

  get displayedTime () {
    return moment(this.departure.time).format('h:mm');
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
    <div class="${this.departure.removed ? 'removed' : ''} ${this.departure.added ? 'added' : ''}">
      <div class="event__time">
        <p class="event__schedule_time">${this.displayedTime}</p>
        <p class="event__relative-time"><bd-timestamp timestamp="${this.departure.time}"></bd-timestamp></p>
      </div>
      <div class="event__event-details">
        <div class="event__marker">
        <bd-route bg-color="${this.departure.route_color}" color="${this.departure.route_text_color}" name="${this.departure.route_name}"></bd-route></div>
        <div>
          <p class="event__title">${this.departure.headsign}</p>
        </div>
      </div>
    </div>

    `;
  }

  isPast () {
    return new Date(this.departure.time) < new Date();
  }
}

export default Departure;
