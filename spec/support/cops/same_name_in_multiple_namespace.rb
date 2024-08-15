# frozen_string_literal: true

module RuboCop
  module Cop
    module Test
      class SameNameInMultipleNamespace < RuboCop::Cop::Base; end

      module Foo
        class SameNameInMultipleNamespace < RuboCop::Cop::Base; end
      end

      module Bar
        class SameNameInMultipleNamespace < RuboCop::Cop::Base; end
      end
    end
  end
end
