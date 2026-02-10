# frozen_string_literal: true

# This file is used by Rack-based servers during the Bridgetown boot process.

require 'bridgetown-core/rack/boot'

Bridgetown::Rack.boot

run RodaApp.freeze.app # see server/roda_app.rb
