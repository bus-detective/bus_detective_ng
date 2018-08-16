/* global HTMLElement */
import moment from 'moment';

class Departure extends HTMLElement {
  get departureTime () {
    return this.getAttribute('departure-time');
  }

  get formattedDepartureTime () {
    var time = moment(this.departureTime);
    return time.format('h:mm') + time.format('a')[0];
  }

  get headsign () {
    return this.getAttribute('headsign');
  }

  get realtime () {
    return this.getAttribute('realtime') === 'true';
  }

  constructor () {
    super();
    const template = document.createElement('template');

    template.innerHTML = `
      <link rel="stylesheet" href="/css/app.css">
      <div class="timeline__event event event--future" id="departure-item">
        <div class="event__time">${this.formattedDepartureTime}</div>
        <div class="event__event-details">
          <div class="event__marker"></div>
          <div>
            <slot name="route"></slot>

            <span class="event__relative-time">
              ${this.realtime ? '' : 'scheduled'} <bd-timestamp timestamp="${this.departureTime}"></bd-timestamp>
            </span>
            <p class="event__title">${this.headsign}</p>
          </div>
        </div>
      </div>
    `;

    this.attachShadow({ mode: 'open' });
    this.shadowRoot.appendChild(template.content.cloneNode(true));
  }

  connectedCallback () {
    const update = () => {
      let rootDiv = this.shadowRoot.querySelector('#departure-item');
      if (this.isPast()) {
        rootDiv.classList.add('event--past');
        rootDiv.classList.remove('event--future');
      } else {
        rootDiv.classList.add('event--future');
        rootDiv.classList.remove('event--past');
      }
      setTimeout(update, 5000);
    };
    update();
  }

  isPast () {
    return new Date(this.departureTime) < new Date();
  }
}

export default Departure;
