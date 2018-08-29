import Route from './route.js';
import { expect } from 'chai';
import { createSandbox } from './spec_helper.js';

describe('Route', () => {
  const sandbox = createSandbox();

  before(() => {
    customElements.define("bd-route", Route);
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
