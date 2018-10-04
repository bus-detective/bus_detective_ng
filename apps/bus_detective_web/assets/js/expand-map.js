/* global HTMLElement */
import { dispatch } from 'wc-fluxish';

class ExpandMap extends HTMLElement {
  get expanded () {
    return this.getAttribute('expanded') === 'true';
  }

  static get observedAttributes () {
    return ['expanded'];
  }

  attributeChangedCallback () {
    let toggleButtonIcon = this.querySelector('.bd-icon');
    if (this.expanded) {
      toggleButtonIcon.classList.remove('bd-icon--expand');
      toggleButtonIcon.classList.add('bd-icon--contract');
    } else {
      toggleButtonIcon.classList.remove('bd-icon--contract');
      toggleButtonIcon.classList.add('bd-icon--expand');
    }
  }

  connectedCallback () {
    this.innerHTML = `
      <button class="map__toggle-expanded button qa-toggle-expanded" id="toggleButton">
        <i class="bd-icon bd-icon--expand"></i>
      </button>
    `;

    let toggleButton = this.querySelector('#toggleButton');

    toggleButton.addEventListener('click', (event) => {
      if (this.expanded) {
        dispatch('expandMap', {mapExpanded: false});
      } else {
        dispatch('expandMap', {mapExpanded: true});
      }
    });
  }
}

export default ExpandMap;
