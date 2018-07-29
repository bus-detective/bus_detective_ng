/* global HTMLElement */
/* global navigator */

class NearbySearch extends HTMLElement {
  onSubmit (evt) {
    evt.preventDefault();
    navigator.geolocation.getCurrentPosition((position) => {
      let form = evt.target;
      form.querySelector('[name=latitude]').value = position.coords.latitude;
      form.querySelector('[name=longitude]').value = position.coords.longitude;
      form.submit();
    }, (error) => {
      console.log(error);
    });
    return false;
  }

  connectedCallback () {
    this.innerHTML = `
      <form accept-charset="UTF-8" action="/search" class="search__form" method="get" id="nearby_search_form">
        <input name="_utf8" type="hidden" value="✓">
        <input type="hidden" name="latitude" value="" />
        <input type="hidden" name="longitude" value="" />
        <button type="submit" class="nav__button button push-top">
          <i class="bd-icon bd-icon--pin"></i>Nearby
        </button>
      </form>
    `;

    let form = this.querySelector('#nearby_search_form');
    form.addEventListener('submit', this.onSubmit, false);
  }
}

export default NearbySearch;
