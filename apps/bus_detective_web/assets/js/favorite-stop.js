/* global HTMLElement */
import { dispatch } from 'wc-fluxish';

class FavoriteStop extends HTMLElement {
  get favoriteStop () {
    return this.getAttribute('favorite-stop') ? JSON.parse(this.getAttribute('favorite-stop')) : {};
  }

  connectedCallback () {
    this.innerHTML = `
    <div draggable="true" class="stop-item" data-test="stop_item" data-id="${this.favoriteStop.id}">
      <div class="flex__container">
        <div class="flex__cell flex__cell--large">
          <a href="/stops/${this.favoriteStop.id}" class="unstyled">
            <bd-favorite stop-id="${this.favoriteStop.id}"></bd-favorite>
            <h1 class="list-item__title">${this.favoriteStop.name}<small class="light">${this.favoriteStop.direction}</small></h1>
            <div class="list-item__details">
              ${this.favoriteStop.routes.map((route) => `
                <bd-route bg-color="${route.color}" color="${route.text_color}" name="${route.short_name}"></bd-route>
              `).join('')}
            </div>
          </a>
        </div>
      </div>
    </div>
    `;
    this.addEventListener('dragstart', (event) => {
      event.dataTransfer.setData('text/plain', this.favoriteStop.id);
    });
    this.addEventListener('dragover', (event) => {
      event.preventDefault();
    });
    this.addEventListener('drop', (event) => {
      const height = this.getBoundingClientRect().height;
      const draggingStop = event.dataTransfer.getData('text/plain');
      dispatch('moveFavorite', {
        from: draggingStop,
        to: this.favoriteStop.id,
        before: event.offsetY < (height / 2)
      });
    });
  }
}

export default FavoriteStop;
