# frozen_string_literal: true

module RuboCop
  module Cop
    # Identifier of all cops containing a department and cop name.
    #
    # All cops are identified by their badge. For example, the badge
    # for `RuboCop::Cop::Style::Tab` is `Style/Tab`. Badges can be
    # parsed as either `Department/CopName` or just `CopName` to allow
    # for badge references in source files that omit the department
    # for RuboCop to infer.
    class Badge
      # Error raised when a badge parse fails.
      class InvalidBadge < Error
        MSG = 'Invalid badge %<badge>p. ' \
              'Expected `Department/CopName` or `CopName`.'.freeze

        def initialize(token)
          super(format(MSG, badge: token))
        end
      end

      attr_reader :department, :cop_name

      def self.for(class_name)
        new(*class_name.split('::').last(2))
      end

      def self.parse(identifier)
        parts = identifier.split('/', 2)

        raise InvalidBadge, identifier if parts.size > 2

        if parts.one?
          new(nil, *parts)
        else
          new(*parts)
        end
      end

      def initialize(department, cop_name)
        @department = department.to_sym if department
        @cop_name   = cop_name
      end

      def ==(other)
        hash == other.hash
      end
      alias eql? ==

      def hash
        [department, cop_name].hash
      end

      def match?(other)
        cop_name == other.cop_name &&
          (!qualified? || department == other.department)
      end

      def to_s
        qualified? ? "#{department}/#{cop_name}" : cop_name
      end

      def qualified?
        !department.nil?
      end

      def with_department(department)
        self.class.new(department, cop_name)
      end
    end
  end
end
