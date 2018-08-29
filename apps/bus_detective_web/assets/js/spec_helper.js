
export function createSandbox() {
  let sandbox = document.createElement("div", {id: 'sandbox'});
  before(() => {
    document.body.appendChild(sandbox);
  });
  afterEach(() => {

  })
  return sandbox;
}
