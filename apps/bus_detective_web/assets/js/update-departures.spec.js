import { updateDepartures } from './container.js';
import { expect } from 'chai';

describe('updateDepartures', () => {
  let departures;

  beforeEach(() => {
    departures = [{
      id: 1,
      route_name: 'Bob',
      time: '2 oclock',
      route_color: 'blue',
      route_text_color: 'taupe',
      headsign: 'Head Sign'
    }, {
      id: 2,
      route_name: 'Bob',
      time: '2 oclock',
      route_color: 'blue',
      route_text_color: 'taupe',
      headsign: 'Head Sign 2'
    }];
  });

  it('adds departures to state if there arent any', () => {
    const { departures: updatedDepartures } = updateDepartures({}, departures);
    expect(updatedDepartures).to.equal(departures);
  });

  it('adds removed to departures that went away', () => {
    const { departures: updatedDepartures } = updateDepartures({ departures }, [ departures[0] ]);
    expect(updatedDepartures.length).to.equal(2);
    expect(updatedDepartures[0].removed).to.equal(true);
  });

  it('removes departures that were removing and went away', () => {
    const removedDeparture = Object.assign(departures[1], { removed: true });
    const { departures: updatedDepartures } = updateDepartures({ departures: [ departures[0], removedDeparture ] }, [departures[0]]);
    expect(updatedDepartures.length).to.equal(1);
  });

  it('marks new departures', () => {
    const newDeparture = Object.assign({}, departures[1], { id: 3, headsign: 'Headsign 3' });
    const { departures: updatedDepartures } = updateDepartures({ departures }, [ ...departures, newDeparture ]);
    expect(updatedDepartures.length).to.equal(3);
    expect(updatedDepartures[2].added).to.equal(true);
  });
});
