import moment from 'moment'

moment.relativeTimeThreshold('M', 12)
moment.relativeTimeThreshold('d', 30)
moment.relativeTimeThreshold('h', 24)
moment.relativeTimeThreshold('m', 60)
moment.relativeTimeThreshold('s', 60)

class Timestamp extends HTMLElement {

  get timestamp() {
    return this.getAttribute("timestamp");
  }

  get displayedTimestamp() {
    return moment(this.timestamp).fromNow();
  }
  
  connectedCallback() {
    const update = () => {
      this.innerHTML = this.displayedTimestamp;
      setTimeout(update, 5000);
    };
    update();
  }
}

export default Timestamp;
