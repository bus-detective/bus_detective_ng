import Departure from './departure.js';
import { expect } from 'chai';
import { createSandbox } from './spec_helper.js';

describe('Departure', () => {
  const sandbox = createSandbox();

  before(() => {
    customElements.define("bd-departure", Departure);
  });

  it('can be added to the page', () => {
    const departure = {
      route_name: 'Bob',
      time: '2 oclock',
      route_color: 'blue',
      route_text_color: 'taupe',
      headsign: 'Head Sign'
    };
    sandbox.innerHTML = `
      <bd-departure departure='${JSON.stringify(departure)}'></bd-departure>
    `;
    const bdDepartureElement = document.querySelector("bd-departure");
    expect(bdDepartureElement).to.exist;
    expect(bdDepartureElement.innerHTML).to.contain(departure.headsign);
  });
});
