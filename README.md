# Bus Detective

[![Build Status](https://travis-ci.org/bus-detective/bus_detective_ng.svg?branch=master)](https://travis-ci.org/bus-detective/bus_detective_ng)
[![Coverage Status](https://coveralls.io/repos/github/bus-detective/bus_detective_ng/badge.svg?branch=master)](https://coveralls.io/github/bus-detective/bus_detective_ng?branch=master)

### Prerequisites:

* Elixir 1.6.6
* Erlang 21.0.1
* Nodejs 8.11.1
* phantomjs for browser tests
* Postgres with postgis extensions

#### Installing Prerequisites

This guide uses asdf-vm to manage prerequisites when possible. For a great guide on getting started, see Greg Mefford's post [here](https://embedded-elixir.com/post/2017-05-23-using-asdf-vm/)

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.5.1
source ~/.asdf/asdf.sh

asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring

asdf install erlang 21.0.1 # This takes a while sometimes
asdf install elixir 1.6.6
asdf install nodejs 8.11.1

asdf global erlang 21.0.1
asdf global elixir 1.6.6
asdf global nodejs 8.11.1

asdf rehash nodejs
npm install phantomjs-prebuilt

# Install Postgres (on a Mac using Homebrew)
brew install postgresql postgis
```

### Development Setup

#### Customize the GTFS urls (optional)

1. Copy the apps/importer/config/dev.secret.exs.example to apps/importer/config/dev.secret.exs and replace the schedules data with your local transit authority's GTFS schedule feed (a zip file usually called google_transit.zip or something similar)

2. Copy the apps/realtime/config/dev.secret.exs.example to apps/realtime/config/dev.secret.exs and replace the feeds data with your local transit authority's GTFS trip update feed url and vehicle positions url (the locations usually end in .pb denoting a protobuf file)

### Run

* Run `mix deps.get` from the project root
* Run `npm install` from the apps/bus_detective_web/assets folder
* Run `mix do ecto.create, ecto.migrate` from the project root
* Run `mix phx.server` from the project root, and the app will:
  * download the GTFS schedule data and import it
  * poll for the trip updates and vehicle positions data
* Assuming all goes well, the log should get to a point where it says "Projecting stop times"
* Visit `localhost:4000` in a browser and search for a relevant stop. You should get search results very quickly.

### Test

* Run `mix test` from the project root for tests

### Deployment

Deployment to heroku should be fairly straight forward. You will want to add the following environment variables which will be picked up by prod.exs in the import and realtime apps:

* FEED_NAME
* FEED_SCHEDULE_URL
* FEED_TRIP_UPDATES_URL
* FEED_VEHICLE_POSITIONS_URL

## License

This project rocks and uses (MIT-LICENSE).

## Contributing
GitHub's guide for [Contributing to Open Source](https://guides.github.com/activities/contributing-to-open-source/) offers the best advice.
​
#### tl;dr
1. [Fork it](https://help.github.com/articles/fork-a-repo/)!
1. Create your feature branch: `git checkout -b cool-new-feature`
1. Run the Elixir formatter: `mix format`
1. Run the Elixir linter: `mix credo --strict` and resolve any problems (or ask for help if you're stuck)
1. Run the javascript linter: `cd apps/bus_detective_web/assets; ./node_modules/.bin/eslint js/**/*.js` (or ask for help if you're stuck)
1. Run the tests: `mix test` and make sure they pass
1. Commit your changes: `git commit -am 'Added a cool feature'`
1. Push to the branch: `git push origin cool-new-feature`
1. [Create new Pull Request](https://help.github.com/articles/creating-a-pull-request/).
