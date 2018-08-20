/* global HTMLElement */
import { dispatch } from './reduxish';

class ExpandMap extends HTMLElement {
  connectedCallback () {
    this.innerHTML = `
      <button class="map__toggle-expanded button qa-toggle-expanded" id="toggleButton">
        <i class="bd-icon bd-icon--expand"></i>
      </button>
    `;

    let toggleButton = this.querySelector('#toggleButton');
    let toggleButtonIcon = toggleButton.querySelector('.bd-icon');

    toggleButton.addEventListener('click', function (event) {
      if (toggleButtonIcon.classList.contains('bd-icon--expand')) {
        toggleButtonIcon.classList.remove('bd-icon--expand');
        toggleButtonIcon.classList.add('bd-icon--contract');
        dispatch("expandMap", {mapExpanded: true});
      } else {
        toggleButtonIcon.classList.remove('bd-icon--contract');
        toggleButtonIcon.classList.add('bd-icon--expand');
        dispatch("expandMap", {mapExpanded: false});
      }
    });
  }
}

export default ExpandMap;
