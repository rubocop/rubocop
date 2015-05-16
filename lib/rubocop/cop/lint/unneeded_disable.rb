# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop detects instances of rubocop:disable comments that can be
      # removed without causing any offenses to be reported. It's implemented
      # as a cop in that it inherits from the Cop base class and calls
      # add_offense. The unusual part of its implementation is that it doesn't
      # have any on_* methods or an investigate method. This means that it
      # doesn't take part in the investigation phase when the other cops do
      # their work. Instead, it waits until it's called in a later stage of the
      # execution. The reason it can't be implemented as a normal cop is that
      # it depends on the results of all other cops to do its work.
      class UnneededDisable < Cop
        COP_NAME = 'Lint/UnneededDisable'

        def check(file, offenses, cop_disabled_line_ranges, comments)
          unneeded_cops = {}

          cop_disabled_line_ranges[file].each do |cop, line_ranges|
            cop_offenses = offenses.select { |o| o.cop_name == cop }
            line_ranges.each do |line_range|
              comment =
                comments[file].find { |c| c.loc.line == line_range.begin }
              unneeded_cop = find_unneeded(comment, offenses, cop, cop_offenses,
                                           line_range)
              if unneeded_cop
                unneeded_cops[comment.loc.expression] ||= Set.new
                unneeded_cops[comment.loc.expression].add(unneeded_cop)
              end
            end
          end

          unneeded_cops.each do |range, cops|
            add_offense(range, range,
                        "Unnecessary disabling of #{cops.sort.join(', ')}.")
          end
        end

        private

        def find_unneeded(comment, offenses, cop, cop_offenses, line_range)
          if comment.loc.expression.source =~ /rubocop:disable\s+all\b/
            'all cops' if offenses.none? { |o| line_range.include?(o.line) }
          elsif cop_offenses.none? { |o| line_range.include?(o.line) }
            cop
          end
        end
      end
    end
  end
end
