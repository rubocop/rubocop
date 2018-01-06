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
        MSG = '`%<constant>s` not found, you\'re probably missing a require statement or there is a cycle in your dependencies'.freeze

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

        def_node_matcher :is_module_or_class?, <<-PATTERN
          ({module class} ...)
        PATTERN

        def_node_matcher :has_superclass?, <<-PATTERN
          (class (const ...) (const ...) ...)
        PATTERN

        def process_definition(node, source)
          if node.kind_of? Hash
            self.timeline << node
            return 
          end

          return unless is_module_or_class?(node)
          name = find_consts(node.children.first).join("::")
          inherited = find_consts(node.children[1]).join("::") if has_superclass?(node)

          # Inheritance technically has to happen before the actual class definition
          self.timeline << { event: :const_inherit, name: inherited, node: node } if inherited

          self.timeline << { event: :const_def, name: name }


          # First child is the module/class name => skip or it'll be picked up by `process_const`
          skip_list = [node.children.first]
          skip_list << node.children[1] if inherited

          push_list = []
          push_list << { event: :const_undef, name: name }
          push_list << { event: :const_undef, name: inherited } if inherited


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
            state = State.new
            err_indices = []
            timeline.each_with_index do |event, i|
              case event[:event]
              when :require
                state.require(file: event[:file])
              when :require_relative
                path_to_investigated_file = event[:path]
                relative_path = File.expand_path(File.join(File.dirname(path_to_investigated_file), event[:file]))
                state.require_relative(relative_path: relative_path)
              when :const_access
                err_indices << i unless state.access_const(const_name: event[:name])
              when :const_def
                state.define_const(const_name: event[:name])
              when :const_undef
                state.undefine_const(const_name: event[:name])
              when :const_assign
                state.const_assigned(const_name: event[:name])
              when :const_inherit
                success = state.access_const(const_name: event[:name])
                if success
                  state.define_const(const_name: event[:name], is_part_of_stack: false)
                else
                  err_indices << i
                end
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

      class State
        attr_accessor :defined_constants
        attr_accessor :const_stack

        def initialize
          self.defined_constants = []
          self.const_stack = []
        end

        def require(file: nil)
          Kernel.require(file)
        rescue LoadError => ex
        rescue NameError => ex
          puts "Note: Could not load #{file}:"
          puts ex.message
          puts "Check your dependencies, they could be circular"
        end

        def require_relative(relative_path: nil)
          Kernel.require_relative(relative_path)
        rescue LoadError => ex
        rescue NameError => ex
          puts "Note: Could not load relative file #{relative_path}:"
          puts ex.message
          puts "Check your dependencies, they could be circular"
        end

        def access_const(const_name: nil)
          name = const_name.to_s.sub(/^:*/, '').sub(/:*$/, '') # Strip leading/trailing ::
          prefix = self.const_stack.join("::")
          # I use const_get here because in testing const_get and const_defined? have yielded different results
          result = Object.const_get(name) rescue nil                                                   # Defined elsewhere, top-level
          result ||= self.defined_constants.find { |c| Object.const_get("#{c}::#{name}") rescue nil }  # Defined elsewhere, nested
          result ||= self.defined_constants.find { |c| [name, "#{prefix}::#{name}"].include? c }       # Defined in this file, other module/class
          result ||= self.const_stack.join("::") == name                                               # Defined in this file, in current module/class
          return result
        end

        def define_const(const_name: nil, is_part_of_stack: true)
          new = []
          self.defined_constants.each do |c|
            found = Object.const_get("#{c}::#{const_name}") rescue nil
            new << found.to_s if found
          end
          self.defined_constants.push(*new)
          self.const_stack.push(const_name) if is_part_of_stack
          self.defined_constants.push(const_name.to_s, self.const_stack.join("::"))
          self.defined_constants.uniq!
        end

        def undefine_const(const_name: nil)
          self.const_stack.pop
        end

        def const_assigned(const_name: nil)
          full_name = [self.const_stack.join("::"), const_name].join("::")
          self.defined_constants << full_name
          self.defined_constants.uniq!
        end
      end
    end
  end
end
