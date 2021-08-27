# frozen_string_literal: true

module RuboCop
  module Cop
    module Bundler
      # Passing symbol arguments to `source` (e.g. `source :rubygems`) is
      # deprecated because they default to using HTTP requests. Instead, specify
      # `'https://rubygems.org'` if possible, or `'http://rubygems.org'` if not.
      #
      # When autocorrecting, this cop will replace symbol arguments with
      # `'https://rubygems.org'`.
      #
      # This cop will not replace existing sources that use `http://`. This may
      # be necessary where HTTPS is not available. For example, where using an
      # internal gem server via an intranet, or where HTTPS is prohibited.
      # However, you should strongly prefer `https://` where possible, as it is
      # more secure.
      #
      # @example
      #   # bad
      #   source :gemcutter
      #   source :rubygems
      #   source :rubyforge
      #
      #   # good
      #   source 'https://rubygems.org' # strongly recommended
      #   source 'http://rubygems.org' # use only if HTTPS is unavailable
      #
      class InsecureProtocolSource < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'The source `:%<source>s` is deprecated because HTTP requests ' \
              'are insecure. ' \
              "Please change your source to 'https://rubygems.org' " \
              "if possible, or 'http://rubygems.org' if not."

        RESTRICT_ON_SEND = %i[source].freeze

        # @!method insecure_protocol_source?(node)
        def_node_matcher :insecure_protocol_source?, <<~PATTERN
          (send nil? :source
            $(sym ${:gemcutter :rubygems :rubyforge}))
        PATTERN

        def on_send(node)
          insecure_protocol_source?(node) do |source_node, source|
            message = format(MSG, source: source)

            add_offense(
              source_node,
              message: message
            ) do |corrector|
              corrector.replace(
                source_node, "'https://rubygems.org'"
              )
            end
          end
        end
      end
    end
  end
end
