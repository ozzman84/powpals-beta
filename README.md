# README

![PowPals-Beta](https://github.com/ozzman84/powpals-beta/actions/workflows/ci.yml/badge.svg)

ERB Linting
This gem provides a command-line interface which can be run like so:

Run erblint [options] if the gem is installed standalone.
Run bundle exec erblint [options] if the gem is installed as a Gemfile dependency for your app.
For example, erblint --lint-all --enable-all-linters will run all available linters on all ERB files in the current directory or its descendants (**/*.html{+*,}.erb).

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

  ```
    bundle exec rubocop --parallel -A
  ```
