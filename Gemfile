####
# Welcome to your project's Gemfile, used by Rubygems & Bundler.
#
# To install a plugin, run:
#
#   bundle add new-plugin-name
#
# and add a relevant init comment to your config/initializers.rb file.
#
# When you run Bridgetown commands, we recommend using a binstub like so:
#
#   bin/bridgetown start (or console, etc.)
#
# This will help ensure the proper Bridgetown version is running.
####

# Gems source:
source "https://rubygems.org"
# Or you can switch the above to an alternate community-led server:
# source "https://gem.coop"

# Git-based sources:
git_source(:github) { "https://github.com/#{_1}.git" }
git_source(:codeberg) { "https://codeberg.org/#{_1}.git" }

# If you need to upgrade/switch Bridgetown versions, change the line below
# and then run `bundle update bridgetown`
gem "bridgetown", "~> 2.1.1"

# Uncomment to add file-based dynamic routing to your project:
# gem "bridgetown-routes", "~> 2.1.1"

# Puma is the Rack-compatible web server used by Bridgetown
# (you can optionally limit this to the "development" group)
gem "puma", "< 8"

# Uncomment to use the Inspectors API to manipulate the output
# of your HTML or XML resources:
# gem "nokogiri", "~> 1.18"

# Or for faster parsing of HTML-only resources via Inspectors, use Nokolexbor:
# gem "nokolexbor", "~> 0.6"

gem "bridgetown-svg-inliner", "~> 3.0"
