# frozen_string_literal: true

describe RuboCop::Cop::Performance::CaseWhenSplat do
  subject(:cop) { described_class.new }

  it 'allows case when without splat' do
    inspect_source(cop, <<-END.strip_indent)
      case foo
      when 1
        bar
      else
        baz
      end
    END

    expect(cop.messages).to be_empty
  end

  it 'allows splat on a variable in the last when condition' do
    inspect_source(cop, <<-END.strip_indent)
      case foo
      when 4
        foobar
      when *cond
        bar
      else
        baz
      end
    END

    expect(cop.messages).to be_empty
  end

  it 'allows multiple splat conditions on variables at the end' do
    inspect_source(cop, <<-END.strip_indent)
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
    END

    expect(cop.messages).to be_empty
  end

  it 'registers an offense for case when with a splat in the first condition' do
    inspect_source(cop, <<-END.strip_indent)
      case foo
      when *cond
        bar
      when 4
        foobar
      else
        baz
      end
    END

    expect(cop.messages).to eq([described_class::MSG])
    expect(cop.highlights).to eq(['when *cond'])
  end

  it 'registers an offense for case when with a splat without an else' do
    inspect_source(cop, <<-END.strip_indent)
      case foo
      when *baz
        bar
      when 4
        foobar
      end
    END

    expect(cop.messages).to eq([described_class::MSG])
    expect(cop.highlights).to eq(['when *baz'])
  end

  it 'registers an offense for splat conditions in when then' do
    inspect_source(cop, <<-END.strip_indent)
      case foo
      when *cond then bar
      when 4 then baz
      end
    END

    expect(cop.messages).to eq([described_class::MSG])
    expect(cop.highlights).to eq(['when *cond'])
  end

  it 'registers an offense for a single when with splat expansion followed ' \
     'by another value' do
    inspect_source(cop, <<-END.strip_indent)
      case foo
      when *Foo, Bar
        nil
      end
    END
    expect(cop.messages).to eq([described_class::MSG])
    expect(cop.highlights).to eq(['when *Foo'])
  end

  it 'registers an offense for multiple splat conditions at the beginning' do
    inspect_source(cop, <<-END.strip_indent)
      case foo
      when *cond1
        bar
      when *cond2
        doo
      when 4
        foobar
      else
        baz
      end
    END

    expect(cop.messages).to eq([described_class::MSG, described_class::MSG])
    expect(cop.highlights).to eq(['when *cond1', 'when *cond2'])
  end

  it 'registers an offense for multiple out of order splat conditions' do
    inspect_source(cop, <<-END.strip_indent)
      case foo
      when *cond1
        bar
      when 8
        barfoo
      when *SOME_CONSTANT
        doo
      when 4
        foobar
      else
        baz
      end
    END

    expect(cop.messages).to eq([described_class::MSG, described_class::MSG])
    expect(cop.highlights).to eq(['when *cond1', 'when *SOME_CONSTANT'])
  end

  it 'registers an offense for splat condition that do not appear at the end' do
    inspect_source(cop, <<-END.strip_indent)
      case foo
      when *cond1
        bar
      when 8
        barfoo
      when *cond2
        doo
      when 4
        foobar
      when *cond3
        doofoo
      else
        baz
      end
    END

    expect(cop.messages).to eq([described_class::MSG, described_class::MSG])
    expect(cop.highlights).to eq(['when *cond1', 'when *cond2'])
  end

  it 'allows splat expansion on an array literal' do
    inspect_source(cop, <<-END.strip_indent)
      case foo
      when *[1, 2]
        bar
      when *[3, 4]
        bar
      when 5
        baz
      end
    END

    expect(cop.offenses).to be_empty
  end

  it 'allows splat expansion on array literal as the last condition' do
    inspect_source(cop, <<-END.strip_indent)
      case foo
      when *[1, 2]
        bar
      end
    END

    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for a splat on a variable that proceeds a splat ' \
     'on an array literal as the last condition' do
    inspect_source(cop, <<-END.strip_indent)
      case foo
      when *cond
        bar
      when *[1, 2]
        baz
      end
    END

    expect(cop.messages).to eq([described_class::MSG])
    expect(cop.highlights).to eq(['when *cond'])
  end

  it 'registers an offense when splat is part of the condition' do
    inspect_source(cop, <<-END.strip_indent)
      case foo
      when cond1, *cond2
        bar
      when cond3
        baz
      end
    END

    expect(cop.messages).to eq([described_class::MSG])
    expect(cop.highlights).to eq(['when cond1, *cond2'])
  end

  context 'autocorrect' do
    it 'corrects a single when with splat expansion followed by ' \
      'another value' do
      source = <<-END.strip_indent
        case foo
        when *Foo, Bar, Baz
          nil
        end
      END
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(<<-END.strip_indent)
        case foo
        when Bar, Baz, *Foo
          nil
        end
      END
    end

    it 'corrects a when with splat expansion followed by another value ' \
      'when there are multiple whens' do
      source = <<-END.strip_indent
        case foo
        when *Foo, Bar
          nil
        when FooBar
          1
        end
      END
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(<<-END.strip_indent)
        case foo
        when FooBar
          1
        when Bar, *Foo
          nil
        end
      END
    end

    it 'corrects a when with multiple out of order splat expansions ' \
      'followed by other values when there are multiple whens' do
      source = <<-END.strip_indent
        case foo
        when *Foo, Bar, *Baz, Qux
          nil
        when FooBar
          1
        end
      END
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(<<-END.strip_indent)
        case foo
        when FooBar
          1
        when Bar, Qux, *Foo, *Baz
          nil
        end
      END
    end

    it 'moves a single splat condition to the end of the when conditions' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        case foo
        when *cond
          bar
        when 3
          baz
        end
      END

      expect(new_source).to eq(<<-END.strip_indent)
        case foo
        when 3
          baz
        when *cond
          bar
        end
      END
    end

    it 'moves multiple splat condition to the end of the when conditions' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        case foo
        when *cond1
          bar
        when *cond2
          foobar
        when 5
          baz
        end
      END

      # CaseWhenSplat requires multiple rounds of correction to avoid
      # "clobbering errors" from Source::Rewriter
      cop = described_class.new
      new_source = autocorrect_source(cop, new_source)

      expect(new_source).to eq(<<-END.strip_indent)
        case foo
        when 5
          baz
        when *cond1
          bar
        when *cond2
          foobar
        end
      END
    end

    it 'moves multiple out of order splat condition to the end ' \
       'of the when conditions' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
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
      END

      # CaseWhenSplat requires multiple rounds of correction to avoid
      # "clobbering errors" from Source::Rewriter
      cop = described_class.new
      new_source = autocorrect_source(cop, new_source)

      expect(new_source).to eq(<<-END.strip_indent)
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
      END
    end

    it 'corrects splat condition when using when then' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        case foo
        when *cond then bar
        when 4 then baz
        end
      END

      expect(new_source).to eq(<<-END.strip_indent)
        case foo
        when 4 then baz
        when *cond then bar
        end
      END
    end

    it 'corrects nested case when statements' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        def check
          case foo
          when *cond
            bar
          when 3
            baz
          end
        end
      END

      expect(new_source).to eq(<<-END.strip_indent)
        def check
          case foo
          when 3
            baz
          when *cond
            bar
          end
        end
      END
    end

    it 'corrects splat on a variable and leaves an array literal alone' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        case foo
        when *cond
          bar
        when *[1, 2]
          baz
        end
      END

      expect(new_source).to eq(<<-END.strip_indent)
        case foo
        when *[1, 2]
          baz
        when *cond
          bar
        end
      END
    end

    it 'corrects a splat as part of the condition' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        case foo
        when cond1, *cond2
          bar
        when cond3
          baz
        end
      END

      expect(new_source).to eq(<<-END.strip_indent)
        case foo
        when cond3
          baz
        when cond1, *cond2
          bar
        end
      END
    end

    it 'corrects an array followed by splat in the same condition' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        case foo
        when *[cond1, cond2], *cond3
          bar
        when cond4
          baz
        end
      END

      expect(new_source).to eq(<<-END.strip_indent)
        case foo
        when cond4
          baz
        when *[cond1, cond2], *cond3
          bar
        end
      END
    end

    it 'corrects a splat followed by array in the same condition' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        case foo
        when *cond1, *[cond2, cond3]
          bar
        when cond4
          baz
        end
      END

      expect(new_source).to eq(<<-END.strip_indent)
        case foo
        when cond4
          baz
        when *cond1, *[cond2, cond3]
          bar
        end
      END
    end
  end
end
