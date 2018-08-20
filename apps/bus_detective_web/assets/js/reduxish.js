export const dispatch = (event, payload) => {
  document.dispatchEvent(new CustomEvent(event, {
    bubbles: true,
    detail: payload
  }));
}

export const connect = (reducers, subscribers, initialState = {}) => {
  let state = initialState;

  Object.keys(reducers).forEach((key) => {
    document.addEventListener(key, ({ detail }) => {
      console.log(`reducer: ${key}`)
      const newState = reducers[key](state, detail, dispatch);
      console.log("new state", newState);
      document.dispatchEvent(new CustomEvent("stateChange", {detail: newState}));
    });
  });

  Object.keys(subscribers).forEach((key) => {
    document.addEventListener("stateChange", ({detail: state}) => {
      const element = document.querySelector(key);
      subscribers[key](state, element);
    });
  });

}
