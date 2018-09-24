# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::MethodLength, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'Max' => 5, 'CountComments' => false } }

  context 'when method is an instance method' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def m
        ^^^^^ Method has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when method is defined with `define_method`' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        define_method(:m) do
        ^^^^^^^^^^^^^^^^^^^^ Method has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when method is a class method' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def self.m
        ^^^^^^^^^^ Method has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when method is defined on a singleton class' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        class K
          class << self
            def m
            ^^^^^ Method has too many lines. [6/5]
              a = 1
              a = 2
              a = 3
              a = 4
              a = 5
              a = 6
            end
          end
        end
      RUBY
    end
  end

  it 'accepts a method with less than 5 lines' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def m
        a = 1
        a = 2
        a = 3
        a = 4
      end
    RUBY
  end

  it 'accepts a method with multiline arguments ' \
     'and less than 5 lines of body' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def m(x,
            y,
            z)
        a = 1
        a = 2
        a = 3
        a = 4
      end
    RUBY
  end

  it 'does not count blank lines' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def m()
        a = 1
        a = 2
        a = 3
        a = 4


        a = 7
      end
    RUBY
  end

  it 'accepts empty methods' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def m()
      end
    RUBY
  end

  it 'is not fooled by one-liner methods, syntax #1' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def one_line; 10 end
      def self.m()
        a = 1
        a = 2
        a = 4
        a = 5
        a = 6
      end
    RUBY
  end

  it 'is not fooled by one-liner methods, syntax #2' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def one_line(test) 10 end
      def self.m()
        a = 1
        a = 2
        a = 4
        a = 5
        a = 6
      end
    RUBY
  end

  it 'properly counts lines when method ends with block' do
    expect_offense(<<-RUBY.strip_indent)
      def m
      ^^^^^ Method has too many lines. [6/5]
        something do
          a = 2
          a = 3
          a = 4
          a = 5
        end
      end
    RUBY
  end

  it 'does not count commented lines by default' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def m()
        a = 1
        #a = 2
        a = 3
        #a = 4
        a = 5
        a = 6
      end
    RUBY
  end

  context 'when CountComments is enabled' do
    before { cop_config['CountComments'] = true }

    it 'also counts commented lines' do
      expect_offense(<<-RUBY.strip_indent)
        def m
        ^^^^^ Method has too many lines. [6/5]
          a = 1
          #a = 2
          a = 3
          #a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when method is defined in `ExcludedMethods`' do
    before { cop_config['ExcludedMethods'] = ['foo'] }

    it 'still rejects other methods with more than 5 lines' do
      expect_offense(<<-RUBY.strip_indent)
        def m 
        ^^^^^^ Method has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end

    it 'accepts the foo method with more than 5 lines' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def foo
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end
end
