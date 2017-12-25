# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UselessSetterCall do
  subject(:cop) { described_class.new }

  context 'with method ending with setter call on local object' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def test
          top = Top.new
          top.attr = 5
          ^^^ Useless setter call to local variable `top`.
        end
      RUBY
    end
  end

  context 'with singleton method ending with setter call on local object' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def Top.test
          top = Top.new
          top.attr = 5
          ^^^ Useless setter call to local variable `top`.
        end
      RUBY
    end
  end

  context 'with method ending with square bracket setter on local object' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def test
          top = Top.new
          top[:attr] = 5
          ^^^ Useless setter call to local variable `top`.
        end
      RUBY
    end
  end

  context 'with method ending with ivar assignment' do
    it 'accepts' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def test
          something
          @top = 5
        end
      RUBY
    end
  end

  context 'with method ending with setter call on ivar' do
    it 'accepts' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def test
          something
          @top.attr = 5
        end
      RUBY
    end
  end

  context 'with method ending with setter call on argument' do
    it 'accepts' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def test(some_arg)
          unrelated_local_variable = Top.new
          some_arg.attr = 5
        end
      RUBY
    end
  end

  context 'when a lvar contains an object passed as argument ' \
          'at the end of the method' do
    it 'accepts the setter call on the lvar' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def test(some_arg)
          @some_ivar = some_arg
          @some_ivar.do_something
          some_lvar = @some_ivar
          some_lvar.do_something
          some_lvar.attr = 5
        end
      RUBY
    end
  end

  context 'when a lvar contains an object passed as argument ' \
          'by multiple-assignment at the end of the method' do
    it 'accepts the setter call on the lvar' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def test(some_arg)
          _first, some_lvar, _third  = 1, some_arg, 3
          some_lvar.attr = 5
        end
      RUBY
    end
  end

  context 'when a lvar does not contain any object passed as argument ' \
          'with multiple-assignment at the end of the method' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def test(some_arg)
          _first, some_lvar, _third  = do_something
          some_lvar.attr = 5
          ^^^^^^^^^ Useless setter call to local variable `some_lvar`.
        end
      RUBY
    end
  end

  context 'when a lvar possibly contains an object passed as argument ' \
          'by logical-operator-assignment at the end of the method' do
    it 'accepts the setter call on the lvar' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def test(some_arg)
          some_lvar = nil
          some_lvar ||= some_arg
          some_lvar.attr = 5
        end
      RUBY
    end
  end

  context 'when a lvar does not contain any object passed as argument ' \
          'by binary-operator-assignment at the end of the method' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def test(some_arg)
          some_lvar = some_arg
          some_lvar += some_arg
          some_lvar.attr = 5
          ^^^^^^^^^ Useless setter call to local variable `some_lvar`.
        end
      RUBY
    end
  end

  context 'when a lvar declared as an argument ' \
          'is no longer the passed object at the end of the method' do
    it 'registers an offense for the setter call on the lvar' do
      expect_offense(<<-RUBY.strip_indent)
        def test(some_arg)
          some_arg = Top.new
          some_arg.attr = 5
          ^^^^^^^^ Useless setter call to local variable `some_arg`.
        end
      RUBY
    end
  end

  context 'when a lvar contains a local object instantiated with literal' do
    it 'registers an offense for the setter call on the lvar' do
      expect_offense(<<-RUBY.strip_indent)
        def test
          some_arg = {}
          some_arg[:attr] = 1
          ^^^^^^^^ Useless setter call to local variable `some_arg`.
        end
      RUBY
    end
  end

  context 'when a lvar contains a non-local object returned by a method' do
    it 'accepts' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def test
          some_lvar = Foo.shared_object
          some_lvar[:attr] = 1
        end
      RUBY
    end
  end

  it 'is not confused by operators ending with =' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def test
        top.attr == 5
      end
    RUBY
  end

  it 'handles exception assignments without exploding' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo(bar)
        begin
        rescue StandardError => _
        end
        bar[:baz] = true
      end
    RUBY
  end
end
