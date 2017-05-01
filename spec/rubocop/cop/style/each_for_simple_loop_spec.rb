# frozen_string_literal: true

describe RuboCop::Cop::Style::EachForSimpleLoop do
  subject(:cop) { described_class.new }

  OFFENSE_MSG = 'Use `Integer#times` for a simple loop ' \
                'which iterates a fixed number of times.'.freeze

  it 'registers offense for inclusive end range' do
    inspect_source(cop, '(0..10).each {}')
    expect(cop.offenses.size).to eq 1
    expect(cop.messages).to eq([OFFENSE_MSG])
    expect(cop.highlights).to eq(['(0..10).each'])
  end

  it 'registers offense for exclusive end range' do
    inspect_source(cop, '(0...10).each {}')
    expect(cop.offenses.size).to eq 1
    expect(cop.messages).to eq([OFFENSE_MSG])
    expect(cop.highlights).to eq(['(0...10).each'])
  end

  it 'registers offense for exclusive end range with do ... end syntax' do
    inspect_source(cop, <<-END.strip_indent)
      (0...10).each do
      end
    END
    expect(cop.offenses.size).to eq 1
    expect(cop.messages).to eq([OFFENSE_MSG])
    expect(cop.highlights).to eq(['(0...10).each'])
  end

  it 'registers an offense for range not starting with zero' do
    inspect_source(cop, <<-END.strip_indent)
      (3..7).each do
      end
    END
    expect(cop.offenses.size).to eq 1
    expect(cop.messages).to eq([OFFENSE_MSG])
    expect(cop.highlights).to eq(['(3..7).each'])
  end

  it 'does not register offense if range startpoint is not constant' do
    expect_no_offenses('(a..10).each {}')
  end

  it 'does not register offense if range endpoint is not constant' do
    expect_no_offenses('(0..b).each {}')
  end

  it 'does not register offense for inline block with parameters' do
    expect_no_offenses('(0..10).each { |n| puts n }')
  end

  it 'does not register offense for multiline block with parameters' do
    inspect_source(cop, <<-END.strip_indent)
      (0..10).each do |n|
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'does not register offense for character range' do
    expect_no_offenses("('a'..'b').each {}")
  end

  context 'when using an inclusive range' do
    it 'autocorrects the source with inline block' do
      corrected = autocorrect_source(cop, '(0..10).each {}')
      expect(corrected).to eq '11.times {}'
    end

    it 'autocorrects the source with multiline block' do
      corrected = autocorrect_source(cop, <<-END.strip_indent)
        (0..10).each do
        end
      END

      expect(corrected).to eq <<-END.strip_indent
        11.times do
        end
      END
    end

    it 'autocorrects the range not starting with zero' do
      corrected = autocorrect_source(cop, <<-END.strip_indent)
        (3..7).each do
        end
      END

      expect(corrected).to eq <<-END.strip_indent
        5.times do
        end
      END
    end

    it 'does not autocorrect range not starting with zero and using param' do
      source = <<-END.strip_indent
        (3..7).each do |n|
        end
      END
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(source)
    end
  end

  context 'when using an exclusive range' do
    it 'autocorrects the source with inline block' do
      corrected = autocorrect_source(cop, '(0...10).each {}')
      expect(corrected).to eq '10.times {}'
    end

    it 'autocorrects the source with multiline block' do
      corrected = autocorrect_source(cop, <<-END.strip_indent)
        (0...10).each do
        end
      END

      expect(corrected).to eq <<-END.strip_indent
        10.times do
        end
      END
    end

    it 'autocorrects the range not starting with zero' do
      corrected = autocorrect_source(cop, <<-END.strip_indent)
        (3...7).each do
        end
      END

      expect(corrected).to eq <<-END.strip_indent
        4.times do
        end
      END
    end

    it 'does not autocorrect range not starting with zero and using param' do
      source = <<-END.strip_indent
        (3...7).each do |n|
        end
      END
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(source)
    end
  end
end
