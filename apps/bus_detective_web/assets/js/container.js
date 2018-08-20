
export const subscribers = {
  'bd-stop-map': ({ mapExpanded }, element) => {
    element.setAttribute('expanded', mapExpanded);
  },
  'bd-expand-map': ({ mapExpanded }, element) => {
    element.setAttribute('expanded', mapExpanded);
  }
};

const expandMap = (state, { mapExpanded }) => {
  return Object.assign(state, { mapExpanded });
};

export const reducers = { expandMap };
