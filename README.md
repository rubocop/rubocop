# RuboCop Landing Page

The landing page for [rubocop.org](https://rubocop.org), built with [Bridgetown](https://www.bridgetownrb.com/) and [Tailwind CSS](https://tailwindcss.com/).

## Prerequisites

- [Ruby](https://www.ruby-lang.org/en/downloads/) >= 3.2
- [Node.js](https://nodejs.org) >= 20
- [Bundler](https://bundler.io/)

## Setup

```sh
bundle install && npm install
```

Tailwind CSS was configured using [tailwindcss-automation](https://github.com/bridgetownrb/tailwindcss-automation).

## Development

```sh
bin/bridgetown start
```

Then visit [localhost:4000](http://localhost:4000).

> **Note:** When adding new Tailwind utility classes in ERB templates, you may need to restart the server for the CSS to regenerate.

## Linting

```sh
bin/rubocop
```

## Deployment

The site is deployed to GitHub Pages via a [GitHub Actions workflow](.github/workflows/gh-pages.yml). On every push to the `gh-pages` branch, the workflow builds the site with `bin/bridgetown deploy` and deploys the `output/` directory.

The workflow automatically sets `BASE_PATH` based on the repository. Forks get `/rubocop` so the site works at `<username>.github.io/rubocop/`, while the main repo uses `/` for the `rubocop.org` custom domain.

## Plugins

- [bridgetown-svg-inliner](https://github.com/andrewmcodes/bridgetown-svg-inliner): inlines SVG files directly into HTML for styling with CSS

## Data Sources

- **GitHub Releases**: fetched from the GitHub API at build time (`plugins/builders/github_releases.rb`)
- **Site stats** (downloads, stars, cops): configured in `src/_data/site_metadata.yml`
- **Sponsors & Backers**: loaded from Open Collective avatar APIs
