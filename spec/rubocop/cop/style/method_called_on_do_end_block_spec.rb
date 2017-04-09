# frozen_string_literal: true

describe RuboCop::Cop::Style::MethodCalledOnDoEndBlock do
  subject(:cop) { described_class.new }

  context 'with a multi-line do..end block' do
    it 'registers an offense for a chained call' do
      inspect_source(cop, <<-END.strip_indent)
        a do
          b
        end.c
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['end.c'])
    end

    it 'accepts it if there is no chained call' do
      inspect_source(cop, <<-END.strip_indent)
        a do
          b
        end
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts a chained block' do
      inspect_source(cop, <<-END.strip_indent)
        a do
          b
        end.c do
          d
        end
      END
      expect(cop.offenses).to be_empty
    end
  end

  context 'with a single-line do..end block' do
    it 'registers an offense for a chained call' do
      inspect_source(cop, 'a do b end.c')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['end.c'])
    end

    it 'accepts a single-line do..end block with a chained block' do
      inspect_source(cop, 'a do b end.c do d end')
      expect(cop.offenses).to be_empty
    end
  end

  context 'with a {} block' do
    it 'accepts a multi-line block with a chained call' do
      inspect_source(cop, <<-END.strip_indent)
        a {
          b
        }.c
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts a single-line block with a chained call' do
      inspect_source(cop, 'a { b }.c')
      expect(cop.offenses).to be_empty
    end
  end
end
