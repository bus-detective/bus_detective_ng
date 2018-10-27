/* global HTMLElement */

class FavoritesList extends HTMLElement {
  get favorites () {
    return this.getAttribute('favorites') ? JSON.parse(this.getAttribute('favorites')) : [];
  }

  static get observedAttributes () {
    return ['favorites'];
  }

  attributeChangedCallback () {
    this.render();
  }

  connectedCallback () {
    this.render();
  }

  render () {
    this.innerHTML = this.favorites.map((favorite) => `
      <bd-favorite-stop favorite-stop='${JSON.stringify(favorite)}'></bd-favorite-stop>
    `).join('');
  }
}

export default FavoritesList;
