/* global HTMLElement */
class Route extends HTMLElement {
  get bgcolor () {
    return this.getAttribute('bg-color');
  }

  get name () {
    return this.getAttribute('name');
  }

  connectedCallback () {
    this.innerHTML = `
    <span class="tag" style="background-color: #${this.bgcolor};">
      ${this.name}
    </span>
    `;
  }
}

export default Route;
