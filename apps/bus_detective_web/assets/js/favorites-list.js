/* global HTMLElement */
import favoriteService from './favorite-service.js';
import socket from './socket.js';

class FavoritesList extends HTMLElement {
  get favorites () {
    return favoriteService.all();
  }

  constructor () {
    super();
    let channel = socket.channel('favorites:stops', {});

    channel.on('favorites_list', message => {
      this.setFavorites(message.stops);
    });

    channel.join()
      .receive('ok', resp => { })
      .receive('error', resp => { console.log('Unable to join', resp); });

    channel.push('load_stops', {stop_ids: this.favorites});
  }

  setFavorites (favorites) {
    var contents = document.createElement('div');
    favorites.forEach((favorite) => {
      let container = document.createElement('div');
      container.innerHTML = favorite;
      contents.appendChild(container);
    });
    this.innerHTML = contents.innerHTML;
  }
}

export default FavoritesList;
