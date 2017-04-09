# frozen_string_literal: true

describe RuboCop::Cop::Style::SpaceInsideBrackets do
  subject(:cop) { described_class.new }

  it 'registers an offense for an array literal with spaces inside' do
    inspect_source(cop, <<-END.strip_indent)
      a = [1, 2 ]
      b = [ 1, 2]
    END
    expect(cop.messages).to eq(
      ['Space inside square brackets detected.',
       'Space inside square brackets detected.']
    )
  end

  it 'registers an offense for Hash#[] with symbol key and spaces inside' do
    inspect_source(cop, <<-END.strip_indent)
      a[ :key]
      b[:key ]
    END
    expect(cop.messages).to eq(
      ['Space inside square brackets detected.',
       'Space inside square brackets detected.']
    )
  end

  it 'registers an offense for Hash#[] with string key and spaces inside' do
    inspect_source(cop, <<-END.strip_indent)
      a[\'key\' ]
      b[ \'key\']
    END
    expect(cop.messages).to eq(
      ['Space inside square brackets detected.',
       'Space inside square brackets detected.']
    )
  end

  it 'accepts space inside strings within square brackets' do
    inspect_source(cop, <<-END.strip_indent)
      ['Encoding:',
       '  Enabled: false']
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts space inside square brackets if on its own row' do
    inspect_source(cop, <<-END.strip_indent)
      a = [
           1, 2
          ]
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts space inside square brackets if with comment' do
    inspect_source(cop, <<-END.strip_indent)
      a = [ # Comment
           1, 2
          ]
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts square brackets as method name' do
    inspect_source(cop, <<-END.strip_indent)
      def Vector.[](*array)
      end
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts square brackets called with method call syntax' do
    inspect_source(cop, 'subject.[](0)')
    expect(cop.messages).to be_empty
  end

  it 'only reports a single space once' do
    inspect_source(cop, '[ ]')
    expect(cop.messages).to eq(
      ['Space inside square brackets detected.']
    )
  end

  it 'auto-corrects unwanted space' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      a = [1, 2 ]
      b = [ 1, 2]
      c[ :key]
      d[:key ]
      e["key" ]
      f[ "key"]
    END
    expect(new_source).to eq(<<-END.strip_indent)
      a = [1, 2]
      b = [1, 2]
      c[:key]
      d[:key]
      e["key"]
      f["key"]
    END
  end
end
