/* global CustomEvent */

export const dispatch = (event, payload) => {
  document.dispatchEvent(new CustomEvent(event, {
    bubbles: true,
    detail: payload
  }));
};

export const connect = (reducers, subscribers) => {
  let state = window.localStorage.bdState ? JSON.parse(window.localStorage.bdState) : {};

  Object.keys(reducers).forEach((key) => {
    document.addEventListener(key, ({ detail }) => {
      const newState = reducers[key](state, detail, dispatch);
      document.dispatchEvent(new CustomEvent('stateChange', {detail: newState}));
    });
  });

  Object.keys(subscribers).forEach((key) => {
    document.addEventListener('stateChange', ({detail: state}) => {
      const element = document.querySelector(key);
      subscribers[key](state, element);
    });
  });

  document.addEventListener('stateChange', ({detail: state}) => {
    window.localStorage.bdState = JSON.stringify(state);
  });

  document.dispatchEvent(new CustomEvent('stateChange', {detail: state}));
};
