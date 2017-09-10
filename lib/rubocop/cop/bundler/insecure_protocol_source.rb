# frozen_string_literal: true

module RuboCop
  module Cop
    module Bundler
      # The source `:gemcutter`, `:rubygems` and `:rubyforge` are deprecated
      # because HTTP requests are insecure. Please change your source to
      # 'https://rubygems.org' if possible, or 'http://rubygems.org' if not.
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
        MSG = 'The source `:%s` is deprecated because HTTP requests are ' \
              "insecure. Please change your source to 'https://rubygems.org' " \
              "if possible, or 'http://rubygems.org' if not.".freeze

        def_node_matcher :insecure_protocol_source?, <<-PATTERN
          (send nil :source
            (sym {:gemcutter :rubygems :rubyforge}))
        PATTERN

        def on_send(node)
          insecure_protocol_source?(node) do
            source = source_node(node)

            message = format(MSG, source.children.last)

            add_offense(node, source_range(source.loc.expression), message)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(
              source_node(node).loc.expression, "'https://rubygems.org'"
            )
          end
        end

        private

        def source_node(node)
          node.children.last
        end

        def source_range(node)
          range_between(node.begin_pos, node.end_pos)
        end
      end
    end
  end
end
