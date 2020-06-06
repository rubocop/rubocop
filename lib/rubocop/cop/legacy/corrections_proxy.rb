# frozen_string_literal: true

module RuboCop
  module Cop
    module Legacy
      # Legacy support for Corrector#corrections
      # See https://docs.rubocop.org/rubocop/cop_api_v1_changelog.html
      class CorrectionsProxy
        def initialize(corrector)
          @corrector = corrector
        end

        def <<(callable)
          suppress_clobbering do
            @corrector.transaction do
              callable.call(@corrector)
            end
          end
        end

        def empty?
          @corrector.empty?
        end

        def concat(corrections)
          if corrections.is_a?(CorrectionsProxy)
            suppress_clobbering do
              corrector.merge!(corrections.corrector)
            end
          else
            corrections.each { |correction| self << correction }
          end
        end

        protected

        attr_reader :corrector

        private

        def suppress_clobbering
          yield
        rescue ::Parser::ClobberingError
          # ignore Clobbering errors
        end
      end
    end
  end
end
