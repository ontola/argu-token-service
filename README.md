# Token Service

**Backend responsible for handling invite tokens for the open source app [Argu](https://gitlab.com/ontola/argu).**

## Installation & running locally

Clone this repo as part of the parent repo, see [Argu](https://gitlab.com/ontola/argu) for more information about the setup.

Use this setup if you don't want to run the Token service in a Docker container:
- Install the Ruby version defined in the Gemfile (preferably using a version manager like RVM, rbenv or asdf)
- Install bundler
    - ```gem install bundler```
- If you're on a mac:
    - ```
  brew install postgresql
    ```
- If you're on linux:
    - ```
  sudo apt-get -qq install -y build-essential libgsf-1-dev libpq-dev libxml2 postgresql-contrib zlib1g-dev
    ```
- Install gems
    - ```bundle install```
- Stop the Token Docker container if it's running
- Start the server locally in either development mode
    - `RAILS_ENV=development bundle exec rails s -b 0.0.0.0 -p 3003`
- or in staging mode if you want more performance and less debugging
    - `RAILS_ENV=staging bundle exec rails s -b 0.0.0.0 -p 3003`

## Contributing

Want to contribute to this project?

See [CONTRIBUTING.md](https://gitlab.com/ontola/argu/-/blob/master/CONTRIBUTING.md).
