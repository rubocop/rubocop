# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality shared by Uncommunicative cops
    module UncommunicativeName
      CASE_MSG = 'Only use lowercase characters for %<name_type>s.'.freeze
      NUM_MSG = 'Do not end %<name_type>s with a number.'.freeze
      LENGTH_MSG = '%<name_type>s must be longer than %<min>s ' \
                   'characters.'.freeze

      def check(node, args)
        args.each do |arg|
          name = arg.children.first.to_s
          next if allowed_names.include?(name)
          range = arg_range(arg, name.size)
          issue_offenses(node, range, name)
        end
      end

      private

      def issue_offenses(node, range, name)
        case_offense(node, range) if uppercase?(name)
        length_offense(node, range) unless long_enough?(name)
        return if allow_nums
        num_offense(node, range) if ends_with_num?(name)
      end

      def case_offense(node, range)
        add_offense(node, location: range,
                          message: format(CASE_MSG, name_type: name_type(node)))
      end

      def uppercase?(name)
        name =~ /[[:upper:]]/
      end

      def name_type(node)
        @name_type ||= begin
          case node.type
          when :block then 'block parameter'
          when :def, :defs then 'method argument'
          end
        end
      end

      def num_offense(node, range)
        add_offense(node, location: range,
                          message: format(NUM_MSG, name_type: name_type(node)))
      end

      def ends_with_num?(name)
        name[-1] =~ /\d/
      end

      def length_offense(node, range)
        add_offense(node, location: range,
                          message: format(LENGTH_MSG,
                                          name_type: name_type(node).capitalize,
                                          min: min_length))
      end

      def long_enough?(name)
        name.size >= min_length
      end

      def arg_range(arg, length)
        begin_pos = arg.source_range.begin_pos
        Parser::Source::Range.new(processed_source.buffer,
                                  begin_pos,
                                  begin_pos + length)
      end

      def allowed_names
        cop_config['AllowedNames']
      end

      def allow_nums
        cop_config['AllowNamesEndingInNumbers']
      end

      def min_length
        cop_config['MinNameLength']
      end
    end
  end
end
