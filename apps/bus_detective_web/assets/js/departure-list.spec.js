/* global customElements, HTMLElement */
import DepartureList from './departure-list.js';
import { expect } from 'chai';
import { createSandbox } from './spec_helper.js';

describe('DepartureList', () => {
  const sandbox = createSandbox();
  const departures = [{
    route_name: 'Bob',
    time: '2 oclock',
    route_color: 'blue',
    route_text_color: 'taupe',
    headsign: 'Head Sign'
  }, {
    route_name: 'Bob',
    time: '2 oclock',
    route_color: 'blue',
    route_text_color: 'taupe',
    headsign: 'Head Sign 2'
  }];

  before(() => {
    customElements.define('bd-departure-list', DepartureList);
  });

  it('can be added to the page', () => {
    sandbox.innerHTML = `
      <bd-departure-list departures='${JSON.stringify(departures)}'></bd-departure-list>
    `;
    const bdDepartureListElement = document.querySelector('bd-departure-list');
    expect(bdDepartureListElement).to.be.an.instanceOf(HTMLElement);
    expect(bdDepartureListElement.querySelectorAll('bd-departure').length).to.equal(2);
  });

  it('re-renders when attribute value changes', () => {
    sandbox.innerHTML = `
      <bd-departure-list departures='${JSON.stringify(departures)}'></bd-departure-list>
    `;
    const bdDepartureListElement = document.querySelector('bd-departure-list');
    departures.push({
      route_name: 'Bob',
      time: '2 oclock',
      route_color: 'blue',
      route_text_color: 'taupe',
      headsign: 'Head Sign 3'
    });
    bdDepartureListElement.setAttribute('departures', JSON.stringify(departures));
    expect(bdDepartureListElement.querySelectorAll('bd-departure').length).to.equal(3);
  });
});
