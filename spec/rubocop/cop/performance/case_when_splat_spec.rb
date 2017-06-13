# frozen_string_literal: true

describe RuboCop::Cop::Performance::CaseWhenSplat do
  subject(:cop) { described_class.new }

  let(:message) do
    'Place `when` conditions with a splat at ' \
      'the end of the `when` branches.'
  end

  it 'allows case when without splat' do
    expect_no_offenses(<<-RUBY.strip_indent)
      case foo
      when 1
        bar
      else
        baz
      end
    RUBY
  end

  it 'allows splat on a variable in the last when condition' do
    expect_no_offenses(<<-RUBY.strip_indent)
      case foo
      when 4
        foobar
      when *cond
        bar
      else
        baz
      end
    RUBY
  end

  it 'allows multiple splat conditions on variables at the end' do
    expect_no_offenses(<<-RUBY.strip_indent)
      case foo
      when 4
        foobar
      when *cond1
        bar
      when *cond2
        doo
      else
        baz
      end
    RUBY
  end

  it 'registers an offense for case when with a splat in the first condition' do
    expect_offense(<<-RUBY.strip_indent)
      case foo
      when *cond
      ^^^^^^^^^^ Place `when` conditions with a splat at the end of the `when` branches.
        bar
      when 4
        foobar
      else
        baz
      end
    RUBY
  end

  it 'registers an offense for case when with a splat without an else' do
    expect_offense(<<-RUBY.strip_indent)
      case foo
      when *baz
      ^^^^^^^^^ Place `when` conditions with a splat at the end of the `when` branches.
        bar
      when 4
        foobar
      end
    RUBY
  end

  it 'registers an offense for splat conditions in when then' do
    expect_offense(<<-RUBY.strip_indent)
      case foo
      when *cond then bar
      ^^^^^^^^^^ Place `when` conditions with a splat at the end of the `when` branches.
      when 4 then baz
      end
    RUBY
  end

  it 'registers an offense for a single when with splat expansion followed ' \
     'by another value' do
    inspect_source(<<-RUBY.strip_indent)
      case foo
      when *Foo, Bar
        nil
      end
    RUBY
    expect(cop.messages).to eq([message])
    expect(cop.highlights).to eq(['when *Foo'])
  end

  it 'registers an offense for multiple splat conditions at the beginning' do
    expect_offense(<<-RUBY.strip_indent)
      case foo
      when *cond1
      ^^^^^^^^^^^ Place `when` conditions with a splat at the end of the `when` branches.
        bar
      when *cond2
      ^^^^^^^^^^^ Place `when` conditions with a splat at the end of the `when` branches.
        doo
      when 4
        foobar
      else
        baz
      end
    RUBY
  end

  it 'registers an offense for multiple out of order splat conditions' do
    expect_offense(<<-RUBY.strip_indent)
      case foo
      when *cond1
      ^^^^^^^^^^^ Place `when` conditions with a splat at the end of the `when` branches.
        bar
      when 8
        barfoo
      when *SOME_CONSTANT
      ^^^^^^^^^^^^^^^^^^^ Place `when` conditions with a splat at the end of the `when` branches.
        doo
      when 4
        foobar
      else
        baz
      end
    RUBY
  end

  it 'registers an offense for splat condition that do not appear at the end' do
    expect_offense(<<-RUBY.strip_indent)
      case foo
      when *cond1
      ^^^^^^^^^^^ Place `when` conditions with a splat at the end of the `when` branches.
        bar
      when 8
        barfoo
      when *cond2
      ^^^^^^^^^^^ Place `when` conditions with a splat at the end of the `when` branches.
        doo
      when 4
        foobar
      when *cond3
        doofoo
      else
        baz
      end
    RUBY
  end

  it 'allows splat expansion on an array literal' do
    expect_no_offenses(<<-RUBY.strip_indent)
      case foo
      when *[1, 2]
        bar
      when *[3, 4]
        bar
      when 5
        baz
      end
    RUBY
  end

  it 'allows splat expansion on array literal as the last condition' do
    expect_no_offenses(<<-RUBY.strip_indent)
      case foo
      when *[1, 2]
        bar
      end
    RUBY
  end

  it 'registers an offense for a splat on a variable that proceeds a splat ' \
     'on an array literal as the last condition' do
    inspect_source(<<-RUBY.strip_indent)
      case foo
      when *cond
        bar
      when *[1, 2]
        baz
      end
    RUBY

    expect(cop.messages).to eq([message])
    expect(cop.highlights).to eq(['when *cond'])
  end

  it 'registers an offense when splat is part of the condition' do
    expect_offense(<<-RUBY.strip_indent)
      case foo
      when cond1, *cond2
      ^^^^^^^^^^^^^^^^^^ Place `when` conditions with a splat at the end of the `when` branches.
        bar
      when cond3
        baz
      end
    RUBY
  end

  context 'autocorrect' do
    it 'corrects a single when with splat expansion followed by ' \
      'another value' do
      source = <<-RUBY.strip_indent
        case foo
        when *Foo, Bar, Baz
          nil
        end
      RUBY
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(<<-RUBY.strip_indent)
        case foo
        when Bar, Baz, *Foo
          nil
        end
      RUBY
    end

    it 'corrects a when with splat expansion followed by another value ' \
      'when there are multiple whens' do
      source = <<-RUBY.strip_indent
        case foo
        when *Foo, Bar
          nil
        when FooBar
          1
        end
      RUBY
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(<<-RUBY.strip_indent)
        case foo
        when FooBar
          1
        when Bar, *Foo
          nil
        end
      RUBY
    end

    it 'corrects a when with multiple out of order splat expansions ' \
      'followed by other values when there are multiple whens' do
      source = <<-RUBY.strip_indent
        case foo
        when *Foo, Bar, *Baz, Qux
          nil
        when FooBar
          1
        end
      RUBY
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(<<-RUBY.strip_indent)
        case foo
        when FooBar
          1
        when Bar, Qux, *Foo, *Baz
          nil
        end
      RUBY
    end

    it 'moves a single splat condition to the end of the when conditions' do
      new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
        case foo
        when *cond
          bar
        when 3
          baz
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        case foo
        when 3
          baz
        when *cond
          bar
        end
      RUBY
    end

    it 'moves multiple splat condition to the end of the when conditions' do
      new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
        case foo
        when *cond1
          bar
        when *cond2
          foobar
        when 5
          baz
        end
      RUBY

      # CaseWhenSplat requires multiple rounds of correction to avoid
      # "clobbering errors" from Source::Rewriter
      cop = described_class.new
      new_source = autocorrect_source(cop, new_source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
        case foo
        when 5
          baz
        when *cond1
          bar
        when *cond2
          foobar
        end
      RUBY
    end

    it 'moves multiple out of order splat condition to the end ' \
       'of the when conditions' do
      new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
        case foo
        when *cond1
          bar
        when 3
          doo
        when *cond2
          foobar
        when 6
          baz
        end
      RUBY

      # CaseWhenSplat requires multiple rounds of correction to avoid
      # "clobbering errors" from Source::Rewriter
      cop = described_class.new
      new_source = autocorrect_source(cop, new_source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
        case foo
        when 3
          doo
        when 6
          baz
        when *cond1
          bar
        when *cond2
          foobar
        end
      RUBY
    end

    it 'corrects splat condition when using when then' do
      new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
        case foo
        when *cond then bar
        when 4 then baz
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        case foo
        when 4 then baz
        when *cond then bar
        end
      RUBY
    end

    it 'corrects nested case when statements' do
      new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
        def check
          case foo
          when *cond
            bar
          when 3
            baz
          end
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def check
          case foo
          when 3
            baz
          when *cond
            bar
          end
        end
      RUBY
    end

    it 'corrects splat on a variable and leaves an array literal alone' do
      new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
        case foo
        when *cond
          bar
        when *[1, 2]
          baz
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        case foo
        when *[1, 2]
          baz
        when *cond
          bar
        end
      RUBY
    end

    it 'corrects a splat as part of the condition' do
      new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
        case foo
        when cond1, *cond2
          bar
        when cond3
          baz
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        case foo
        when cond3
          baz
        when cond1, *cond2
          bar
        end
      RUBY
    end

    it 'corrects an array followed by splat in the same condition' do
      new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
        case foo
        when *[cond1, cond2], *cond3
          bar
        when cond4
          baz
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        case foo
        when cond4
          baz
        when *[cond1, cond2], *cond3
          bar
        end
      RUBY
    end

    it 'corrects a splat followed by array in the same condition' do
      new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
        case foo
        when *cond1, *[cond2, cond3]
          bar
        when cond4
          baz
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        case foo
        when cond4
          baz
        when *cond1, *[cond2, cond3]
          bar
        end
      RUBY
    end
  end
end
