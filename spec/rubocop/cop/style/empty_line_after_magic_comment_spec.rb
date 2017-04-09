# frozen_string_literal: true

describe RuboCop::Cop::Style::EmptyLineAfterMagicComment do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  it 'registers an offense for code that immediately follows comment' do
    inspect_source(cop, <<-END.strip_indent)
      # frozen_string_literal: true
      class Foo; end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Add an empty line after magic comments.'])
  end

  it 'registers an offense for documentation immediately following comment' do
    inspect_source(cop, <<-END.strip_indent)
      # frozen_string_literal: true
      # Documentation for Foo
      class Foo; end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Add an empty line after magic comments.'])
  end

  it 'registers an offense when multiple magic comments without empty line' do
    inspect_source(cop, <<-END.strip_indent)
      # encoding: utf-8
      # frozen_string_literal: true
      class Foo; end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Add an empty line after magic comments.'])
  end

  it 'accepts code that separates the comment from the code with a newline' do
    inspect_source(cop, <<-END.strip_indent)
      # frozen_string_literal: true

      class Foo; end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts an empty source file' do
    inspect_source(cop, '')
    expect(cop.offenses).to be_empty
  end

  it 'accepts a source file with only a magic comment' do
    inspect_source(cop, '# frozen_string_literal: true')
    expect(cop.offenses).to be_empty
  end

  it 'autocorrects by adding a newline' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      # frozen_string_literal: true
      class Foo; end
    END

    expect(new_source).to eq(<<-END.strip_indent)
      # frozen_string_literal: true\n
      class Foo; end
    END
  end

  it 'autocorrects by adding a newline above the documentation' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      # frozen_string_literal: true
      # Documentation for Foo
      class Foo; end
    END

    expect(new_source).to eq(<<-END.strip_indent)
      # frozen_string_literal: true

      # Documentation for Foo
      class Foo; end
    END
  end

  it 'autocorrects by adding a newline above the documentation' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      # frozen_string_literal: true
      # Documentation for Foo
      class Foo; end
    END

    expect(new_source).to eq(<<-END.strip_indent)
      # frozen_string_literal: true

      # Documentation for Foo
      class Foo; end
    END
  end
end
