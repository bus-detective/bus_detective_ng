/* global HTMLElement */
import favoriteService from './favorite-service.js';

class Favorite extends HTMLElement {
  get stopId () {
    return this.getAttribute('stop-id');
  }

  get isFavorite () {
    return favoriteService.hasStop(this.stopId);
  }

  get button () {
    return this.querySelector('button');
  }

  get image () {
    return this.querySelector('i');
  }

  toggleFavorite (event) {
    event.preventDefault();
    if (this.isFavorite) {
      favoriteService.remove(this.stopId);
    } else {
      favoriteService.add(this.stopId);
    }
    this.updateClasses();
    return false;
  }

  updateClasses () {
    if (this.isFavorite) {
      this.button.classList.remove('toggle-favorite');
      this.button.classList.add('toggle-favorite--favorite');
      this.image.innerHTML = 'favorite_border';
      this.image.innerHTML = 'favorite';
    } else {
      this.button.classList.remove('toggle-favorite--favorite');
      this.button.classList.add('toggle-favorite');
      this.image.innerHTML = 'favorite';
      this.image.innerHTML = 'favorite_border';
    }
  }

  connectedCallback () {
    let button = document.createElement('button');
    button.className = 'stop-item__toggle-favorite';
    button.addEventListener('click', (event) => { this.toggleFavorite(event); });
    let image = document.createElement('i');
    image.className = 'material-icons';
    image.innerHTML = 'favorite_border';

    button.appendChild(image);
    this.appendChild(button);
    this.updateClasses();
  }
}

export default Favorite;
