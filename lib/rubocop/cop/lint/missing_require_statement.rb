# frozen_string_literal: true

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Lint
      # Checks for missing require statements in your code
      #
      # @example
      #   # bad
      #   Faraday.new(...)
      #
      #   # good
      #   require 'faraday'
      #
      #   Faraday.new(...)
      class MissingRequireStatement < Cop
        MSG = '`%<constant>s` not found, you\'re probably missing a require statement'.freeze

        attr_writer :timeline

        def timeline
          @timeline ||= []
        end

        # Builds 
        def investigate(processed_source)
          processing_methods = self.methods.select { |m| m.to_s.start_with? "process_" }

          stack = [processed_source.ast]
          skip = Set.new
          until stack.empty?
            node = stack.pop
            next unless node
            results = processing_methods.map { |m| self.send(m, node, processed_source) }.compact

            next if node.kind_of? Hash

            to_skip, to_push = [:skip, :push].map { |mode| results.flat_map { |r| r[mode] }.compact }

            skip.merge(to_skip)

            children_to_explore = node.children
                                      .select { |c| c.kind_of? RuboCop::AST::Node }
                                      .reject { |c| skip.include? c }
                                      .reverse
            stack.push(*to_push)
            stack.push(*children_to_explore)
          end

          # 
          err_events = check_timeline(timeline).group_by { |e| e[:name] }.values
          err_events.each do |events|
            first = events.first
            node = first[:node]
            message = format(
              MSG,
              constant: first[:name]
            )
            add_offense(node, message: message)
          end
        end

        def_node_matcher :extract_inner_const, <<-PATTERN
          (const $!nil? _)
        PATTERN

        def_node_matcher :extract_const, <<-PATTERN
          (const _ $_)
        PATTERN

        def find_consts(node)
          inner = node
          outer_const = extract_const(node)
          return unless outer_const
          consts = [outer_const]
          while inner = extract_inner_const(inner)
            const = extract_const(inner)
            consts << const
          end
          consts.reverse
        end

        def process_const(node, source)
          return unless node.kind_of? RuboCop::AST::Node
          consts = find_consts(node)
          return unless consts
          const_name = consts.join("::")

          self.timeline << { event: :const_access, name: const_name, node: node }

          { skip: node.children }
        end

        def_node_matcher :extract_const_assignment, <<-PATTERN
          (casgn nil? $_ ...)
        PATTERN

        def process_const_assign(node, source)
          const_assign_name = extract_const_assignment(node)
          return unless const_assign_name

          self.timeline << { event: :const_assign, name: const_assign_name}

          { skip: node.children }
        end

        def_node_matcher :module_or_class_name, <<-PATTERN
          ({module class} (const nil? $_) ...)
        PATTERN

        def_node_matcher :inherited_class_name, <<-PATTERN
          (class (const nil? _) (const nil? $_) ...)
        PATTERN

        def process_definition(node, source)
          if node.kind_of? Hash
            self.timeline << node
            return 
          end

          name = module_or_class_name(node)
          inherited = inherited_class_name(node)
          return unless name
          self.timeline << { event: :const_def, name: name }

          # Not entirely accurate, but the subclass has access to everything it's inherited, so this should work
          self.timeline << { event: :const_def, name: inherited } if inherited

          # First child is the module/class name => skip or it'll be picked up by `process_const`
          skip_list = [node.children.first]
          skip_list << node.children[1] if inherited

          push_list = []
          push_list << { event: :const_undef, name: inherited } if inherited
          push_list << { event: :const_undef, name: name }


          { skip: skip_list, push: push_list}
        end

        def_node_matcher :extract_require, <<-PATTERN
          (send nil? ${:require :require_relative} (str $_))
        PATTERN

        def process_require(node, source)
          return unless node.kind_of? RuboCop::AST::Node
          required = extract_require(node)
          return unless required && required.length == 2
          method, file = required
          self.timeline << { event: method, file: file, path: source.path }

          { skip: node.children }
        end

        private
        
        # Returns the problematic events from the timeline, i.e. those for which a require might be missing
        def check_timeline(timeline)
          # To avoid having to marshal/unmarshal the nodes, the fork will just return indices with an error
          err_indices = perform_in_fork do
            err_indices = []
            defined_constants = []
            const_stack = []
            timeline.each_with_index do |event, i|
              case event[:event]
              when :require
                begin 
                  require event[:file]
                rescue Exception
                end
              when :require_relative
                path_to_investigated_file = event[:path]
                relative_path = File.expand_path(File.join(File.dirname(path_to_investigated_file), event[:file]))
                require_relative relative_path rescue nil
              when :const_def
                name = event[:name]
                new = []
                defined_constants.each do |c|
                  found = Object.const_get("#{c}::#{name}") rescue nil
                  new << found if found
                end
                defined_constants.push(*new)
                const_stack.push(event[:name])
                defined_constants.push(event[:name], const_stack.join("::"))
              when :const_undef
                const_stack.pop
                defined_constants.delete_if { |c| c.to_s == event[:name] }
              when :const_access
                name = event[:name]
                prefix = const_stack.join("::")
                result = Object.const_get(name.to_s) rescue nil                                        # Defined elsewhere, top-level
                result ||= defined_constants.find { |c| Object.const_get("#{c}::#{name}") rescue nil } # Defined elsewhere, nested
                result ||= defined_constants.find { |c| [name.to_s, "#{prefix}::#{name}"].include? c } # Defined in this file, other module/class
                result ||= const_stack.join("::") == name.to_s                                         # Defined in this file, in current module/class
                err_indices << i unless result
              when :const_assign
                full_name = [const_stack.join("::"), event[:name]].join("::")
                defined_constants << full_name
              end
            end
            err_indices
          end

          err_indices.map { |i| timeline[i] }
        end

        def perform_in_fork
          r, w = IO.pipe

          # The close statements are as they are used in the IO#pipe documentation
          pid = Process.fork do
            r.close
            result = yield
            Marshal.dump(result, w)
            w.close
          end

          w.close
          result = Marshal.load(r)
          r.close
          _, status = Process.waitpid2(pid)

          raise "An error occured while forking" unless status == 0

          return result
        end
      end
    end
  end
end
