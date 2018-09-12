# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::MethodName, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'never accepted' do |enforced_style|
    it 'registers an offense for mixed snake case and camel case' do
      expect_offense(<<-RUBY.strip_indent)
        def visit_Arel_Nodes_SelectStatement
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.
        end
      RUBY
    end

    it 'registers an offense for capitalized camel case' do
      expect_offense(<<-RUBY.strip_indent)
        class MyClass
          def MyMethod
              ^^^^^^^^ Use #{enforced_style} for method names.
          end
        end
      RUBY
    end

    it 'registers an offense for singleton upper case method without ' \
       'corresponding class' do
      expect_offense(<<-RUBY.strip_indent)
        module Sequel
          def self.Model(source)
                   ^^^^^ Use #{enforced_style} for method names.
          end
        end
      RUBY
    end
  end

  shared_examples 'always accepted' do
    it 'accepts one line methods' do
      expect_no_offenses("def body; '' end")
    end

    it 'accepts operator definitions' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def +(other)
          # ...
        end
      RUBY
    end

    it 'accepts unary operator definitions' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def ~@; end
      RUBY

      expect_no_offenses(<<-RUBY.strip_indent)
        def !@; end
      RUBY
    end

    %w[class module].each do |kind|
      it "accepts class emitter method in a #{kind}" do
        expect_no_offenses(<<-RUBY.strip_indent)
          #{kind} Sequel
                      def self.Model(source)
                      end
          
                      class Model
                      end
                    end
        RUBY
      end

      it "accepts class emitter method in a #{kind}, even when it is " \
         'defined inside another method' do
        expect_no_offenses(<<-RUBY.strip_indent)
          module DPN
            module Flow
              module BaseFlow
                class Start
                end
                def self.included(base)
                  def base.Start(aws_env, *args)
                  end
                end
              end
            end
          end
        RUBY
      end
    end
  end

  context 'when configured for snake_case' do
    let(:cop_config) { { 'EnforcedStyle' => 'snake_case' } }

    it 'registers an offense for camel case in instance method name' do
      expect_offense(<<-RUBY.strip_indent)
        def myMethod
            ^^^^^^^^ Use snake_case for method names.
          # ...
        end
      RUBY
    end

    it 'registers an offense for opposite + correct' do
      expect_offense(<<-RUBY.strip_indent)
        def my_method
        end
        def myMethod
            ^^^^^^^^ Use snake_case for method names.
        end
      RUBY
    end

    it 'registers an offense for camel case in singleton method name' do
      expect_offense(<<-RUBY.strip_indent)
        def self.myMethod
                 ^^^^^^^^ Use snake_case for method names.
          # ...
        end
      RUBY
    end

    it 'accepts snake case in names' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def my_method
        end
      RUBY
    end

    it 'accepts snake case in names, utf-8 Latin alphabet lowercase part 1' do
      method_name = 97.upto(122).to_a.map { |i| [i].pack('U*') }.join('')
      expect_no_offenses(<<-RUBY.strip_indent)
        def my_#{method_name}
        end
      RUBY
    end

    it 'accepts snake case in names, utf-8 Latin alphabet lowercase part 2' do
      method_name = 223.upto(246).to_a.map { |i| [i].pack('U*') }.join('')
      expect_no_offenses(<<-RUBY.strip_indent)
        def my_#{method_name}
        end
      RUBY
    end

    it 'accepts snake case in names, utf-8 Latin alphabet lowercase part 3' do
      method_name = 248.upto(255).to_a.map { |i| [i].pack('U*') }.join('')
      expect_no_offenses(<<-RUBY.strip_indent)
        def my_#{method_name}
        end
      RUBY
    end

    it 'accepts snake case in names, utf-8 Latin Extended-A part 1' do
      method_name = (257..311).to_a.select(&:odd?)
                              .map { |i| [i].pack('U*') }.join('')
      expect_no_offenses(<<-RUBY.strip_indent)
        def my_#{method_name}
        end
      RUBY
    end

    it 'accepts snake case in names, utf-8 Latin Extended-A part 2' do
      method_name = (312..328).to_a.select(&:even?)
                              .map { |i| [i].pack('U*') }.join('')
      expect_no_offenses(<<-RUBY.strip_indent)
        def my_#{method_name}
        end
      RUBY
    end

    it 'accepts snake case in names, utf-8 Latin Extended-A part 3' do
      method_name = (331..375).to_a.select(&:odd?)
                              .map { |i| [i].pack('U*') }.join('')
      expect_no_offenses(<<-RUBY.strip_indent)
        def my_#{method_name}
        end
      RUBY
    end

    it 'accepts snake case in names, utf-8 Latin Extended-A part 4' do
      method_name = [378, 380, 382, 383]
                    .map { |i| [i].pack('U*') }.join('')
      expect_no_offenses(<<-RUBY.strip_indent)
        def my_#{method_name}
        end
      RUBY
    end

    it 'accepts snake case in names, utf-8 Latin Extended-B part 1' do
      method_name = [384, 387, 389, 392, 396, 397, 402, 405, 409, 410, 411, 414,
                     417, 419, 421, 424, 427, 429, 432, 436, 438, 441, 442, 445,
                     454, 457, 460, 462, 464, 466, 468, 470, 472, 474, 476, 477,
                     479, 481, 483, 485, 487, 489, 491, 493, 495, 496, 499, 501,
                     505, 507, 509, 511].map { |i| [i].pack('U*') }.join('')
      expect_no_offenses(<<-RUBY.strip_indent)
        def my_#{method_name}
        end
      RUBY
    end

    it 'accepts snake case in names, utf-8 Latin Extended-B part 2' do
      method_name = (513..563).to_a.select(&:odd?)
                              .map { |i| [i].pack('U*') }.join('')
      expect_no_offenses(<<-RUBY.strip_indent)
        def my_#{method_name}
        end
      RUBY
    end

    it 'accepts snake case in names, utf-8 Latin Extended-B part 3' do
      method_name = 564.upto(569).to_a
                       .map { |i| [i].pack('U*') }.join('')
      expect_no_offenses(<<-RUBY.strip_indent)
        def my_#{method_name}
        end
      RUBY
    end

    it 'accepts snake case in names, utf-8 Latin Extended-B part 4' do
      method_name = [572, 575, 576, 578, 583, 585, 587, 589, 591]
                    .map { |i| [i].pack('U*') }.join('')
      expect_no_offenses(<<-RUBY.strip_indent)
        def my_#{method_name}
        end
      RUBY
    end

    it 'registers an offense for singleton camelCase method within class' do
      expect_offense(<<-RUBY.strip_indent)
        class Sequel
          def self.fooBar
                   ^^^^^^ Use snake_case for method names.
          end
        end
      RUBY
    end

    include_examples 'never accepted', 'snake_case'
    include_examples 'always accepted', 'snake_case'
  end

  context 'when configured for camelCase' do
    let(:cop_config) { { 'EnforcedStyle' => 'camelCase' } }

    it 'accepts camel case in instance method name' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def myMethod
          # ...
        end
      RUBY
    end

    it 'accepts camel case in singleton method name' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def self.myMethod
          # ...
        end
      RUBY
    end

    it 'registers an offense for snake case in names' do
      expect_offense(<<-RUBY.strip_indent)
        def my_method
            ^^^^^^^^^ Use camelCase for method names.
        end
      RUBY
    end

    it 'registers an offense for correct + opposite' do
      expect_offense(<<-RUBY.strip_indent)
        def myMethod
        end
        def my_method
            ^^^^^^^^^ Use camelCase for method names.
        end
      RUBY
    end

    it 'registers an offense for singleton snake_case method within class' do
      expect_offense(<<-RUBY.strip_indent)
        class Sequel
          def self.foo_bar
                   ^^^^^^^ Use camelCase for method names.
          end
        end
      RUBY
    end

    include_examples 'always accepted', 'camelCase'
    include_examples 'never accepted', 'camelCase'
  end
end
