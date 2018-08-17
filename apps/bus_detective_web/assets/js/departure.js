/* global HTMLElement */

class Departure extends HTMLElement {
  get departureTime () {
    return this.getAttribute('data-departure-time');
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
  }

  isPast () {
    return new Date(this.departureTime) < new Date();
  }
}

export default Departure;
