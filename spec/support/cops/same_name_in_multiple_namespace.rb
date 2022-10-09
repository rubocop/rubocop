# frozen_string_literal: true

module RuboCop
  module Cop
    module Test
      class SameNameInMultipleNamespace < RuboCop::Cop::Base; end
    end

    module Test2
      class SameNameInMultipleNamespace < RuboCop::Cop::Base; end
    end
  end
end
