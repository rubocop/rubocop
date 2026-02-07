# Bridgetown Website README

Welcome to your new Bridgetown website! You can update this README file to provide additional context and setup information for yourself or other contributors.

## Table of Contents

- [Bridgetown Website README](#bridgetown-website-readme)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Install](#install)
  - [Development](#development)
    - [Commands](#commands)
  - [Deployment](#deployment)
  - [Contributing](#contributing)

## Prerequisites

- [GCC](https://gcc.gnu.org/install/)
- [Make](https://www.gnu.org/software/make/)
- [Ruby](https://www.ruby-lang.org/en/downloads/)
  - `>= 3.2`
- [Bridgetown Gem](https://rubygems.org/gems/bridgetown)
  - `gem install bridgetown -N`
- [Node](https://nodejs.org)
  - `>= 20`

## Install

```sh
cd bridgetown-site-folder
bundle install && npm install
```
> Learn more: [Bridgetown Getting Started Documentation](https://www.bridgetownrb.com/docs/).

## Development

To start your site in development mode, run `bin/bridgetown start` and navigate to [localhost:4000](https://localhost:4000/)!

Use a [theme](https://github.com/topics/bridgetown-theme) or add some [plugins](https://www.bridgetownrb.com/plugins/) to get started quickly.

### Commands

```sh
# running locally
bin/bridgetown start

# build & deploy to production
bin/bridgetown deploy

# load the site up within a Ruby console (IRB)
bin/bridgetown console
```

> Learn more: [Bridgetown CLI Documentation](https://www.bridgetownrb.com/docs/command-line-usage)

## Linting

```sh
bin/rubocop
```

## Deployment

The site is deployed to GitHub Pages via a [GitHub Actions workflow](.github/workflows/gh-pages.yml). On every push to the `gh-pages` branch, the workflow builds the site with `bin/bridgetown deploy` and deploys the `output/` directory.

The workflow automatically sets `BASE_PATH` based on the repository. Forks get `/rubocop` so the site works at `<username>.github.io/rubocop/`, while the main repo uses `/` for the `rubocop.org` custom domain.

> Read the [Bridgetown Deployment Documentation](https://www.bridgetownrb.com/docs/deployment) for more information.

## Contributing

If repo is on GitHub:

1. Fork it
2. Clone the fork using `git clone` to your local development machine.
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
