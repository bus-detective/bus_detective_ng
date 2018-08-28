import Route from './route.js';
import { expect } from 'chai';
describe('Route', () => {
  let sandbox
  before(() => {
    customElements.define("bd-route", Route);
    sandbox = document.createElement("div", {id: 'sandbox'});
    document.body.appendChild(sandbox);
  });

  it('can be added to the page', () => {
    sandbox.innerHTML = `
      <bd-route name="Routey McRouteFace"></bd-route>
    `;
    const bdRouteElement = document.querySelector("bd-route");
    expect(bdRouteElement).to.exist;
    expect(bdRouteElement.innerHTML).to.contain('Routey McRouteFace');
  });
});
