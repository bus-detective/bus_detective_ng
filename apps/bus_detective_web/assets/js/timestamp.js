/* global HTMLElement */
import moment from 'moment';

moment.relativeTimeThreshold('M', 12);
moment.relativeTimeThreshold('d', 30);
moment.relativeTimeThreshold('h', 24);
moment.relativeTimeThreshold('m', 60);
moment.relativeTimeThreshold('s', 60);

class Timestamp extends HTMLElement {
  get timestamp () {
    return this.getAttribute('timestamp');
  }

  get displayedTimestamp () {
    const now = moment();
    const timestamp = moment(this.timestamp);
    const relativeTime = timestamp.diff(now);
    const relativeTimeDuration = moment.duration(relativeTime);

    return relativeTimeDuration.minutes() + "m";
  }

  connectedCallback () {
    const update = () => {
      this.innerHTML = this.displayedTimestamp;
      setTimeout(update, 1000);
    };
    update();
  }
}

export default Timestamp;
