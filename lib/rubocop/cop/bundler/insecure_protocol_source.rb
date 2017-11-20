# frozen_string_literal: true

module RuboCop
  module Cop
    module Bundler
      # The symbol argument `:gemcutter`, `:rubygems` and `:rubyforge`
      # are deprecated. So please change your source to URL string that
      # 'https://rubygems.org' if possible, or 'http://rubygems.org' if not.
      #
      # This autocorrect will replace these symbols with 'https://rubygems.org'.
      # Because it is secure, HTTPS request is strongly recommended. And in
      # most use cases HTTPS will be fine.
      #
      # However, it don't replace all `sources` of `http://` with `https://`.
      # For example, when specifying an internal gem server using HTTP on the
      # intranet, a use case where HTTPS can not be specified was considered.
      # Consider using HTTP only if you can not use HTTPS.
      #
      # @example
      #   # bad
      #   source :gemcutter
      #   source :rubygems
      #   source :rubyforge
      #
      #   # good
      #   source 'https://rubygems.org' # strongly recommended
      #   source 'http://rubygems.org'
      class InsecureProtocolSource < Cop
        MSG = 'The source `:%<source>s` is deprecated because HTTP requests ' \
              'are insecure. ' \
              "Please change your source to 'https://rubygems.org' " \
              "if possible, or 'http://rubygems.org' if not.".freeze

        def_node_matcher :insecure_protocol_source?, <<-PATTERN
          (send nil? :source
            (sym ${:gemcutter :rubygems :rubyforge}))
        PATTERN

        def on_send(node)
          insecure_protocol_source?(node) do |source|
            message = format(MSG, source: source)

            add_offense(
              node,
              location: source_range(node.first_argument.loc.expression),
              message: message
            )
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(
              node.first_argument.loc.expression, "'https://rubygems.org'"
            )
          end
        end

        private

        def source_range(node)
          range_between(node.begin_pos, node.end_pos)
        end
      end
    end
  end
end
