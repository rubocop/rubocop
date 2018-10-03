# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::ClassVariableName do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'as a function arg' do
    it 'registers an offense when using `clazz`' do
      expect_offense(<<-RUBY.strip_indent)
      def do_something(clazz)
                       ^^^^^ Use `klass` instead of `clazz`.
      end
      RUBY
    end

    it 'does not register an offense when using `klass`' do
      expect_no_offenses(<<-RUBY.strip_indent)
      def do_something(klass)
      end
      RUBY
    end
  end

  context 'as a block variable' do
    it 'registers an offense when using `clazz`' do
      expect_offense(<<-RUBY.strip_indent)
        classes.map { |clazz| puts clazz.name }
                       ^^^^^ Use `klass` instead of `clazz`.
      RUBY
    end

    it 'does not register an offense when using `klass`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        classes.map { |klass| puts klass.name }
      RUBY
    end
  end

  context 'as a variable' do
    it 'registers an offense when using `clazz`' do
      expect_offense(<<-RUBY.strip_indent)
        clazz = Array
        ^^^^^^^^^^^^^ Use `klass` instead of `clazz`.
      RUBY
    end

    it 'does not register an offense when using `klass`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        klass = Array
      RUBY
    end
  end
end
