/* global HTMLElement */
class Route extends HTMLElement {
  get color () {
    return this.getAttribute('color');
  }

  get bgcolor () {
    return this.getAttribute('bg-color');
  }

  get name () {
    return this.getAttribute('name');
  }

  connectedCallback () {
    this.innerHTML = `
    <span class="tag" style="background-color: #${this.bgcolor}; color: #${this.color};">
      ${this.name}
    </span>
    `;
  }
}

export default Route;
