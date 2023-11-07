# README

![PowPals-Beta](https://github.com/ozzman84/powpals-beta/actions/workflows/ci.yml/badge.svg)
# Project Name

Brief project description or tagline.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Overview
Every year me and my friends would rent a ski house in the mountain and there were a lot of tasks and house keeping that we managed through an excel spread sheet. The sheet would continue to grow and ended up needing a lot of logic build into it. As I realized we had a good system going, I thought I could build it into an app and thats where we are today.

## Features
Current the feature build outs are being managed through GitHub projects and stories are being written for each new feature. 

At it's core, the app is being built to help manage our seasonal ski house. 
Features include:
Marking when a roommate will, will not be staying as well as tracking for those who are undecided.
Add events for a user and for the house
Make payments with splitwise, venmo, or anyone else
Invite guests to stay at the house
Reserve which room you will be staying in

Also, I would like to build features for all users even if they are not renting a ski house
Users can select which Mountain they will ski on
Users can select which ski pass they have
Users can add friends and see where they're skiing
Users can see which ski passes their friends have
Plan ski trips together
Make ski friends

## Installation
Step-by-step guide to setting up the Rails application locally. Include the following subsections:

### Prerequisites
 * Ruby 3.2.2
 * Rails 7.0.6
 * PostgreSQL

* System Dependencies
Authentication was setup with Devise
Google Oauth2
TailwindUI
Stimulus
DotENV
Fly.io Production

Linting
Rubocop

Project Management
* GitHub Projects

### Installation Steps
1. Clone the repository:
```
  git@github.com:ozzman84/powpals-beta.git
```

2. Run the bundler:
```
  bundle install
```

3. Create and seed the database:
```
  rails db:{create,migrate,seed}
```

SECRETS are kept in a .env file and once the application is setup I can send the secret information to you.

Testing is with RSpec
```
  bundle exec rspec
```

RuboCop Linting
```
  bundle exec rubocop --parallel -A
```

ERB Linting
This gem provides a command-line interface which can be run like so:

Run erblint [options] if the gem is installed standalone.
Run bundle exec erblint [options] if the gem is installed as a Gemfile dependency for your app.
For example, erblint --lint-all --enable-all-linters will run all available linters on all ERB files in the current directory or its descendants (**/*.html{+*,}.erb).

The web address for the app currently is https://powpals.fly.dev

Once environment is setup and a branch is submitted, we can setup SSH for fly.io where the app is deploy. To deploy brand to fly.io. Setup pull request and once the changes are approved, we can merge to main and deploy.

* Deployment instructions using cli
```
  flyctl deploy
```
