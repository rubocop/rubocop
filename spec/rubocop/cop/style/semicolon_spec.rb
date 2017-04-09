# frozen_string_literal: true

describe RuboCop::Cop::Style::Semicolon, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'AllowAsExpressionSeparator' => false } }

  it 'registers an offense for a single expression' do
    inspect_source(cop,
                   'puts "this is a test";')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for several expressions' do
    inspect_source(cop,
                   'puts "this is a test"; puts "So is this"')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for one line method with two statements' do
    inspect_source(cop,
                   'def foo(a) x(1); y(2); z(3); end')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts semicolon before end if so configured' do
    inspect_source(cop,
                   'def foo(a) z(3); end')
    expect(cop.offenses).to be_empty
  end

  it 'accepts semicolon after params if so configured' do
    inspect_source(cop,
                   'def foo(a); z(3) end')
    expect(cop.offenses).to be_empty
  end

  it 'accepts one line method definitions' do
    inspect_source(cop, <<-END.strip_indent)
      def foo1; x(3) end
      def initialize(*_); end
      def foo2() x(3); end
      def foo3; x(3); end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts one line empty class definitions' do
    inspect_source(cop, <<-END.strip_indent)
      # Prefer a single-line format for class ...
      class Foo < Exception; end

      class Bar; end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts one line empty method definitions' do
    inspect_source(cop, <<-END.strip_indent)
      # One exception to the rule are empty-body methods
      def no_op; end

      def foo; end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts one line empty module definitions' do
    inspect_source(cop,
                   'module Foo; end')
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for semicolon at the end no matter what' do
    inspect_source(cop,
                   'module Foo; end;')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accept semicolons inside strings' do
    inspect_source(cop, <<-END.strip_indent)
      string = ";
      multi-line string"
    END
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for a semicolon at the beginning of a line' do
    inspect_source(cop, '; puts 1')
    expect(cop.offenses.size).to eq(1)
  end

  it 'auto-corrects semicolons when syntactically possible' do
    corrected =
      autocorrect_source(cop, <<-END.strip_indent)
        module Foo; end;
        puts "this is a test";
        puts "this is a test"; puts "So is this"
        def foo(a) x(1); y(2); z(3); end
        ;puts 1
      END
    expect(corrected)
      .to eq(<<-END.strip_indent)
        module Foo; end
        puts "this is a test"
        puts "this is a test"; puts "So is this"
        def foo(a) x(1); y(2); z(3); end
        puts 1
      END
  end

  context 'when AllowAsExpressionSeparator is true' do
    let(:cop_config) { { 'AllowAsExpressionSeparator' => true } }

    it 'accepts several expressions' do
      inspect_source(cop,
                     'puts "this is a test"; puts "So is this"')
      expect(cop.offenses).to be_empty
    end

    it 'accepts one line method with two statements' do
      inspect_source(cop,
                     'def foo(a) x(1); y(2); z(3); end')
      expect(cop.offenses).to be_empty
    end
  end
end
