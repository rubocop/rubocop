# frozen_string_literal: true

describe RuboCop::Cop::Style::MultilineBlockChain do
  subject(:cop) { described_class.new }

  context 'with multi-line block chaining' do
    it 'registers an offense for a simple case' do
      inspect_source(cop, <<-END.strip_indent)
        a do
          b
        end.c do
          d
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['end.c'])
    end

    it 'registers an offense for a slightly more complicated case' do
      inspect_source(cop, <<-END.strip_indent)
        a do
          b
        end.c1.c2 do
          d
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['end.c1.c2'])
    end

    it 'registers two offenses for a chain of three blocks' do
      inspect_source(cop, <<-END.strip_indent)
        a do
          b
        end.c do
          d
        end.e do
          f
        end
      END
      expect(cop.offenses.size).to eq(2)
      expect(cop.highlights).to eq(['end.c', 'end.e'])
    end

    it 'registers an offense for a chain where the second block is ' \
       'single-line' do
      inspect_source(cop, <<-END.strip_indent)
        Thread.list.find_all { |t|
          t.alive?
        }.map { |thread| thread.object_id }
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['}.map'])
    end

    it 'accepts a chain where the first block is single-line' do
      inspect_source(cop,
                     ['Thread.list.find_all { |t| t.alive? }.map { |t| ',
                      '  t.object_id',
                      '}'])
      expect(cop.offenses).to be_empty
    end
  end

  it 'accepts a chain of blocks spanning one line' do
    expect_no_offenses(<<-END.strip_indent)
      a { b }.c { d }
      w do x end.y do z end
    END
  end

  it 'accepts a multi-line block chained with calls on one line' do
    expect_no_offenses(<<-END.strip_indent)
      a do
        b
      end.c.d
    END
  end

  it 'accepts a chain of calls followed by a multi-line block' do
    expect_no_offenses(<<-END.strip_indent)
      a1.a2.a3 do
        b
      end
    END
  end
end
