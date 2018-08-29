import DepartureList from './departure-list.js';
import { expect } from 'chai';
import { createSandbox } from './spec_helper.js';

describe('DepartureList', () => {
  const sandbox = createSandbox();
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

  before(() => {
    customElements.define("bd-departure-list", DepartureList);
  });

  it('can be added to the page', () => {

    sandbox.innerHTML = `
      <bd-departure-list departures='${JSON.stringify(departures)}'></bd-departure-list>
    `;
    const bdDepartureListElement = document.querySelector("bd-departure-list");
    expect(bdDepartureListElement).to.exist;
    expect(bdDepartureListElement.querySelectorAll("bd-departure").length).to.equal(2);
  });

  it('re-renders when attribute value changes', () => {
    sandbox.innerHTML = `
      <bd-departure-list departures='${JSON.stringify(departures)}'></bd-departure-list>
    `;
    const bdDepartureListElement = document.querySelector("bd-departure-list");
    departures.push({
      route: {
        color: 'purple',
        text_color: 'taupe'
      },
      trip: {
        headsign: "Head Sign 3"
      }
    });
    bdDepartureListElement.setAttribute('departures', JSON.stringify(departures));
    expect(bdDepartureListElement.querySelectorAll("bd-departure").length).to.equal(3);
  });
});
