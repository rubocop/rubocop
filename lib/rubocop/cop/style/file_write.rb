# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Favor `File.(bin)write` convenience methods.
      #
      # NOTE: There are different method signatures between `File.write` (class method)
      # and `File#write` (instance method). The following case will be allowed because
      # static analysis does not know the contents of the splat argument:
      #
      # [source,ruby]
      # ----
      # File.open(filename, 'w') do |f|
      #   f.write(*objects)
      # end
      # ----
      #
      # @example
      #   # bad - text mode
      #   File.open(filename, 'w').write(content)
      #   File.open(filename, 'w') do |f|
      #     f.write(content)
      #   end
      #
      #   # good
      #   File.write(filename, content)
      #
      #   # bad - binary mode
      #   File.open(filename, 'wb').write(content)
      #   File.open(filename, 'wb') do |f|
      #     f.write(content)
      #   end
      #
      #   # good
      #   File.binwrite(filename, content)
      #
      class FileWrite < Base
        extend AutoCorrector
        include RangeHelp

        MSG = 'Use `File.%<write_method>s`.'

        RESTRICT_ON_SEND = %i[open].to_set.freeze

        TRUNCATING_WRITE_MODES = %w[w wt wb w+ w+t w+b].to_set.freeze

        # @!method file_open?(node)
        def_node_matcher :file_open?, <<~PATTERN
          (send
            (const {nil? cbase} :File)
            :open
            $_
            (str $%TRUNCATING_WRITE_MODES)
            (block-pass (sym :write))?
          )
        PATTERN

        # @!method send_write?(node)
        def_node_matcher :send_write?, <<~PATTERN
          (send _ :write $_)
        PATTERN

        # @!method block_write?(node)
        def_node_matcher :block_write?, <<~PATTERN
          (block _ (args (arg $_)) (send (lvar $_) :write $_))
        PATTERN

        def on_send(node)
          evidence(node) do |filename, mode, content, write_node|
            message = format(MSG, write_method: write_method(mode))

            add_offense(write_node, message: message) do |corrector|
              range = replaced_range(node, write_node)
              heredocs = removed_heredocs(filename, content, write_node)
              next if foreign_heredoc_body?(range, heredocs)

              heredocs = restored_heredocs(heredocs, [filename, content])
              next unless restorable?(range, heredocs, write_node)

              replacement = "#{write_method(mode)}(#{filename.source}, #{content.source})"

              replace_and_restore_heredocs(corrector, range, replacement, heredocs)
            end
          end
        end

        def evidence(node)
          file_open?(node) do |filename, mode|
            file_open_write?(node.parent) do |content|
              yield(filename, mode, content, node.parent)
            end
          end
        end

        private

        def file_open_write?(node)
          content = send_write?(node) || block_write?(node) do |block_arg, lvar, write_arg|
            write_arg if block_arg == lvar
          end
          return false if content&.splat_type?

          yield(content) if content
        end

        def write_method(mode)
          mode.end_with?('b') ? :binwrite : :write
        end

        def replaced_range(node, write_node)
          range_between(node.loc.selector.begin_pos, write_node.source_range.end_pos)
        end

        def removed_heredocs(filename, content, write_node)
          [filename, content].flat_map { |argument| find_heredocs(argument) }
                             .select { |heredoc| removed?(heredoc, write_node) }
                             .sort_by { |heredoc| heredoc.loc.heredoc_body.begin_pos }
        end

        def find_heredocs(node)
          [node, *node.each_descendant(:any_str)].select do |child|
            child.respond_to?(:heredoc?) && child.heredoc?
          end
        end

        def removed?(heredoc, write_node)
          heredoc.loc.heredoc_end.end_pos <= write_node.source_range.end_pos
        end

        def foreign_heredoc_body?(range, heredocs)
          find_heredocs(processed_source.ast).any? do |heredoc|
            next false if heredocs.any? { |removed| removed.equal?(heredoc) }

            range.contains?(heredoc_range(heredoc))
          end
        end

        def heredoc_range(heredoc)
          range_between(heredoc.loc.heredoc_body.begin_pos, heredoc.loc.heredoc_end.end_pos)
        end

        def restored_heredocs(heredocs, arguments)
          containers = arguments.map(&:source_range) + heredocs.map { |h| heredoc_range(h) }

          heredocs.reject do |heredoc|
            body = heredoc_range(heredoc)

            containers.any? { |container| container != body && container.contains?(body) }
          end
        end

        def restorable?(range, heredocs, write_node)
          return !overlaps_later_replacement?(range, write_node) if heredocs.empty?

          rest = rest_of_line(range)
          return false if line_ends_inside_literal?(rest)

          !overlaps_later_replacement?(range.join(rest), write_node)
        end

        def rest_of_line(range)
          range.end.join(processed_source.buffer.line_range(range.last_line).end)
        end

        def line_ends_inside_literal?(rest)
          line_end = rest.end_pos
          innermost = nil
          processed_source.ast.each_node do |node|
            range = node.source_range
            innermost = node if range && range.begin_pos < line_end && line_end < range.end_pos
          end

          !innermost.nil? && literal?(innermost)
        end

        def literal?(node)
          return node.percent_literal? if node.array_type?

          node.type?(:any_str, :regexp, :any_sym)
        end

        def overlaps_later_replacement?(corrected, write_node)
          processed_source.ast.each_node(:send).any? do |node|
            other_write_node = evidence(node) { |*, other| other }
            next false unless other_write_node
            next false if other_write_node.equal?(write_node)

            range = replaced_range(node, other_write_node)
            corrected.begin_pos < range.begin_pos && range.begin_pos < corrected.end_pos
          end
        end

        def replace_and_restore_heredocs(corrector, range, replacement, heredocs)
          return corrector.replace(range, replacement) if heredocs.empty?

          rest = rest_of_line(range)
          bodies = heredocs.map { |heredoc| "\n#{heredoc_range(heredoc).source}" }

          corrector.replace(range.join(rest), "#{replacement}#{rest.source}#{bodies.join}")
        end
      end
    end
  end
end
