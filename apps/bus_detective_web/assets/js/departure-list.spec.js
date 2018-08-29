import DepartureList from './departure-list.js';
import { expect } from 'chai';
import { createSandbox } from './spec_helper.js';

describe('DepartureList', () => {
  const sandbox = createSandbox();

  before(() => {
    customElements.define("bd-departure-list", DepartureList);
  });

  it('can be added to the page', () => {
    const departures = [{
      route: {
        color: 'blue',
        text_color: 'taupe'
      },
      trip: {
        headsign: "Head Sign"
      }
    }, {
      route: {
        color: 'red',
        text_color: 'taupe'
      },
      trip: {
        headsign: "Head Sign 2"
      }
    }];
    sandbox.innerHTML = `
      <bd-departure-list departure-list='${JSON.stringify(departures)}'></bd-departure-list>
    `;
    const bdDepartureListElement = document.querySelector("bd-departure-list");
    expect(bdDepartureListElement).to.exist;
    expect(bdDepartuerListElement.querySelectorAll("bd-departure").length).to.equal(2);
  });
});
