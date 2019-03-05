/* global HTMLElement */
import { dispatch } from 'wc-state-reducers';

class ExpandMap extends HTMLElement {
  get expanded () {
    return this.getAttribute('expanded') === 'true';
  }

  static get observedAttributes () {
    return ['expanded'];
  }

  attributeChangedCallback () {
    let toggleButtonIcon = this.querySelector('.material-icons');
    if (this.expanded) {
      toggleButtonIcon.innerHTML = 'fullscreen';
      toggleButtonIcon.innerHTML = 'fullscreen_exit';
    } else {
      toggleButtonIcon.innerHTML = 'fullscreen_exit';
      toggleButtonIcon.innerHTML = 'fullscreen';
    }
  }

  connectedCallback () {
    this.innerHTML = `
      <button class="map__toggle-expanded button qa-toggle-expanded" id="toggleButton">
        <i class="material-icons">fullscreen</i>
      </button>
    `;

    let toggleButton = this.querySelector('#toggleButton');

    toggleButton.addEventListener('click', (event) => {
      if (this.expanded) {
        dispatch(document, 'expandMap', {mapExpanded: false});
      } else {
        dispatch(document, 'expandMap', {mapExpanded: true});
      }
    });
  }
}

export default ExpandMap;
