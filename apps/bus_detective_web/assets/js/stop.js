/* global HTMLElement */
class Stop extends HTMLElement {
  get direction () {
    return this.getAttribute('direction');
  }

  get name () {
    return this.getAttribute('name');
  }

  get url () {
    return this.getAttribute('url');
  }

  connectedCallback () {
    const template = document.createElement('template');

    template.innerHTML = `
      <link rel="stylesheet" href="/css/app.css">
      <div class="stop-item">
        <div class="flex__container">
          <div class="flex__cell flex__cell--large">
            <a href="${this.url}" class="unstyled">
              <h1 class="list-item__title">${this.name}<small class="light">${this.direction}</small></h1>
              <div class="list-item__details"><slot name="routes"></slot></div>
            </a>
          </div>
        </div>
      </div>
    `;

    this.attachShadow({ mode: 'open' });
    this.shadowRoot.appendChild(template.content.cloneNode(true));
  }
}

export default Stop;
