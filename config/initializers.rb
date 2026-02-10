# frozen_string_literal: true

# Welcome to Bridgetown!
#
# This configuration file is for settings which affect your whole site.
#
# For more documentation on using this initializers file, visit:
# https://www.bridgetownrb.com/docs/configuration/initializers/
#
# A list of all available configuration options can be found here:
# https://www.bridgetownrb.com/docs/configuration/options
#
# For technical reasons, this file is *NOT* reloaded automatically when you use
# `bin/bridgetown start`. If you change this file, please restart the server process.
#
# For reloadable site metadata like title, SEO description, social media
# handles, etc., take a look at `src/_data/site_metadata.yml`

Bridgetown.configure do |_config|
  # The base hostname & protocol for your site, e.g. https://example.com
  url 'https://rubocop.org'

  # Available options are `erb` (default), `serbea`, or `liquid`
  template_engine 'erb'

  # Optionally host your site off a path, e.g. /blog. If you set this option,
  # ensure you use the `relative_url` helper for all links and assets in your HTML.
  # If you're using esbuild for frontend assets, edit `esbuild.config.js` to
  # update `publicPath`.
  #
  base_path ENV.fetch('BASE_PATH', '/')

  # Bridgetown svg inline utility
  init :'bridgetown-svg-inliner'
end
