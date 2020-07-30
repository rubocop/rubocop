# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cops looks for out of range referencing for Regexp, as while capturing groups out of
      # out of range reference always returns nil.

      # @example
      #   /(foo)bar/ =~ 'foobar'\

      #   # bad - always returns nil
      #   puts $2 # => nil

      #   # good
      #   puts $1 # => foo
      #
      class OutOfRangeRegexpRef < Base
        MSG = 'Do not use out of range reference for the Regexp.'

        def on_regexp(node)
          @valid_ref = cop_config['Count']
          return if contain_non_literal?(node)

          begin
            tree = Regexp::Parser.parse(node.content)
          # Returns if a regular expression that cannot be processed by regexp_parser gem.
          # https://github.com/rubocop-hq/rubocop/issues/8083
          rescue Regexp::Scanner::ScannerError
            return
          end

          @valid_ref = regexp_captures(tree)
        end

        def on_nth_ref(node)
          backref, = *node
          return if @valid_ref.nil?

          add_offense(node) if backref > @valid_ref
        end

        private

        def contain_non_literal?(node)
          node.children.size != 2 || !node.children.first.str_type?
        end

        def regexp_captures(tree)
          named_capture = numbered_capture = 0
          tree.each_expression do |e|
            named_capture += 1 if e.instance_of?(Regexp::Expression::Group::Named)
            numbered_capture += 1 if e.instance_of?(Regexp::Expression::Group::Capture)
          end
          named_capture.positive? ? named_capture : numbered_capture
        end
      end
    end
  end
end
