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
        MSG = 'Symbol not found, you\'re probably missing a require statment'.freeze

        attr_writer :required_so_far
        attr_writer :classes_and_modules

        def required_so_far
          @required_so_far ||= []
        end

        def classes_and_modules
          @classes_and_modules ||= []
        end

        def_node_matcher :require?, <<-PATTERN
          (send nil? :require (str $_))
        PATTERN

        def_node_matcher :extract_inner_const, <<-PATTERN
          (const $!nil? _)
        PATTERN

        def_node_matcher :extract_const, <<-PATTERN
          (const _ $_)
        PATTERN

        def_node_matcher :module_or_class_name, <<-PATTERN
          ({module class} (const nil? $_) ...)
        PATTERN

        def_node_matcher :inherited_class_name, <<-PATTERN
          (class (const nil? _) (const nil? $_) ...)
        PATTERN

        def initialize(config = nil, options = nil)
          super(config, options)
        end

        def investigate(processed_source)
          # TODO: Just found this method. Gameplan for next version: 
          # - Put the AST traversal in here instead of relying on the `on_*` methods
          # - Save a 'timeline' of the file, e.g. [{require: "filename}, {constant: "CONST"}, ...]
          # - Rewrite AvailabilityChecker so that it gets that timeline and only has to fork once
          # - Find a way to return data from the forked process (parallel gem is already used, possibly supports this, otherwise: pipes)
          # It'll still be slow because of the requires but there's not much we can do about that
          # This will also make time cost go down to O(n) vs O(n + m) now with n = required files, m = constants
        end

        def find_consts(node)
          inner = node
          consts = []
          while inner = extract_inner_const(inner)
            const = extract_const(inner)
            consts << const
          end
          outer_const = extract_const(node)
          consts << outer_const
        end


        def on_const(node)
          consts = find_consts(node)
          const_name = consts.join("::")
          add_offense(node) unless AvailabilityChecker.check_if_exists(const_name, required_files: self.required_so_far, classes_and_modules: self.classes_and_modules)
        end

        def save_name(class_or_module)
          return unless class_or_module
          self.classes_and_modules << class_or_module.to_s
        end

        def on_module(node)
          save_name(module_or_class_name(node))
        end

        def on_class(node)
          save_name(module_or_class_name(node))
          save_name(inherited_class_name(node))
        end

        def on_send(node)
          required = require?(node)
          return unless required 
          self.required_so_far << required
        end

        class AvailabilityChecker
          @@builtin = [:UnboundMethod, :Integer, :Float, :String, :Array, :Hash, :NilClass, :STDOUT, :STDIN, :NIL, :STDERR, :Delegator, :SimpleDelegator, :ARGF, :UncaughtThrowError, :FileTest, :File, :GC, :Fiber, :FiberError, :Rational, :IRB, :Data, :TrueClass, :TRUE, :FalseClass, :FALSE, :Encoding, :ZeroDivisionError, :FloatDomainError, :Numeric, :DidYouMean, :Complex, :ObjectSpace, :Gem, :ENV, :Struct, :Enumerator, :RegexpError, :RUBY_RELEASE_DATE, :RUBY_VERSION, :Comparable, :RUBY_PLATFORM, :RUBY_PATCHLEVEL, :Enumerable, :StopIteration, :Regexp, :RUBY_REVISION, :RubyVM, :Thread, :RUBY_ENGINE, :Fixnum, :RUBY_DESCRIPTION, :RUBY_COPYRIGHT, :TracePoint, :RUBY_ENGINE_VERSION, :RubyLex, :TOPLEVEL_BINDING, :CROSS_COMPILING, :MatchData, :ARGV, :Bignum, :ThreadGroup, :Dir, :ThreadError, :Mutex, :Queue, :ClosedQueueError, :Exception2MessageMapper, :SizedQueue, :ConditionVariable, :Time, :Marshal, :Monitor, :Range, :IOError, :EOFError, :MonitorMixin, :RubyToken, :RbConfig, :Process, :IO, :Random, :Symbol, :Readline, :Exception, :Signal, :StringIO, :SystemExit, :BasicObject, :Object, :Module, :Class, :SignalException, :Kernel, :TypeError, :Interrupt, :StandardError, :KeyError, :ArgumentError, :IndexError, :SyntaxError, :RangeError, :ScriptError, :NameError, :NotImplementedError, :NoMethodError, :Proc, :SystemStackError, :RuntimeError, :SecurityError, :NoMemoryError, :EncodingError, :Method, :LoadError, :SystemCallError, :Errno, :Binding, :Warning, :LocalJumpError, :Math, :RUBYGEMS_ACTIVATION_MONITOR]

          # @@cache = {}

          def self.const_exists?(const, lookup: [])
            lookup.map { |l| 
              Object.const_get("#{l}::#{const}") rescue false 
            }.any?
          end

          def self.build_lookup_table(classes_and_modules: [])
            classes_and_modules.reduce([Object]) do |lookup, class_or_module|
              new = []
              lookup.each do |l|
                name = Object.const_get("#{l}::#{class_or_module}") rescue nil
                new << name if name
              end
              lookup += new
            end
          end

          def self.check_if_exists(const_name, required_files: [], classes_and_modules: [])
            return true if @@builtin.include?(const_name)
            # return @@cache[const_name] if @@cache.include?(const_name)
            return true if classes_and_modules.include?(const_name)
            pre_fork = Time.now
            pid = Process.fork do 
              puts "After fork: #{Time.now - pre_fork}"
              puts "requireing #{required_files}"
              now = Time.now
              required_files.each do |r| 
                begin
                  require r 
                rescue LoadError
                rescue NameError
                end
              end
              puts "Require took #{Time.now - now}"

              lookup = self.build_lookup_table(classes_and_modules: classes_and_modules)

              if self.const_exists?(const_name, lookup: lookup)
                exit! 0 
              else 
                exit! 1
              end
            end
            pid, status = Process.waitpid2(pid)
            result = (status == 0)
            # @@cache[const_name] = result
            return result
          end
        end
      end
    end
  end
end
