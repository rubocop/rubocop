# frozen_string_literal: true

describe RuboCop::Cop::Style::EmptyMethod, :config do
  subject(:cop) { described_class.new(config) }

  before do
    inspect_source(source)
  end

  shared_examples 'code with offense' do |code, expected|
    context "when checking #{code}" do
      let(:source) { code }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq([message])
      end

      if expected
        it 'auto-corrects' do
          expect(autocorrect_source(cop, code)).to eq(expected)
        end
      else
        it 'does not auto-correct' do
          expect(autocorrect_source(cop, code)).to eq(code)
        end
      end
    end
  end

  shared_examples 'code without offense' do |code|
    let(:source) { code }

    it 'does not register an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'when configured with compact style' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    let(:message) { 'Put empty method definitions on a single line.' }

    context 'with an empty instance method definition' do
      it_behaves_like 'code with offense',
                      ['def foo',
                       'end'].join("\n"),
                      'def foo; end'

      it_behaves_like 'code with offense',
                      ['def foo(bar, baz)',
                       'end'].join("\n"),
                      'def foo(bar, baz); end'

      it_behaves_like 'code with offense',
                      ['def foo',
                       '',
                       'end'].join("\n"),
                      'def foo; end'

      it_behaves_like 'code without offense',
                      'def foo; end'
    end

    context 'with a non-empty instance method definition' do
      it_behaves_like 'code without offense',
                      ['def foo',
                       '  bar',
                       'end']

      it_behaves_like 'code without offense',
                      'def foo; bar; end'

      it_behaves_like 'code without offense',
                      ['def foo',
                       '  # bar',
                       'end']
    end

    context 'with an empty class method definition' do
      it_behaves_like 'code with offense',
                      ['def self.foo',
                       'end'].join("\n"),
                      'def self.foo; end'

      it_behaves_like 'code with offense',
                      ['def self.foo(bar, baz)',
                       'end'].join("\n"),
                      'def self.foo(bar, baz); end'

      it_behaves_like 'code with offense',
                      ['def self.foo',
                       '',
                       'end'].join("\n"),
                      'def self.foo; end'

      it_behaves_like 'code without offense',
                      'def self.foo; end'
    end

    context 'with a non-empty class method definition' do
      it_behaves_like 'code without offense',
                      ['def self.foo',
                       '  bar',
                       'end']

      it_behaves_like 'code without offense',
                      'def self.foo; bar; end'

      it_behaves_like 'code without offense',
                      ['def self.foo',
                       '  # bar',
                       'end']
    end
  end

  context 'when configured with expanded style' do
    let(:cop_config) { { 'EnforcedStyle' => 'expanded' } }

    let(:message) do
      'Put the `end` of empty method definitions on the next line.'
    end

    context 'with an empty instance method definition' do
      it_behaves_like 'code without offense',
                      ['def foo',
                       'end'].join("\n")

      it_behaves_like 'code without offense',
                      ['def foo',
                       '',
                       'end'].join("\n")

      it_behaves_like 'code with offense',
                      'def foo; end',
                      ['def foo',
                       'end'].join("\n")
    end

    context 'with a non-empty instance method definition' do
      it_behaves_like 'code without offense',
                      ['def foo',
                       '  bar',
                       'end']

      it_behaves_like 'code without offense',
                      'def foo; bar; end'

      it_behaves_like 'code without offense',
                      ['def foo',
                       '  # bar',
                       'end']
    end

    context 'with an empty class method definition' do
      it_behaves_like 'code without offense',
                      ['def self.foo',
                       'end'].join("\n")

      it_behaves_like 'code without offense',
                      ['def self.foo',
                       '',
                       'end'].join("\n")

      it_behaves_like 'code with offense',
                      'def self.foo; end',
                      ['def self.foo',
                       'end'].join("\n")
    end

    context 'with a non-empty class method definition' do
      it_behaves_like 'code without offense',
                      ['def self.foo',
                       '  bar',
                       'end']

      it_behaves_like 'code without offense',
                      'def self.foo; bar; end'

      it_behaves_like 'code without offense',
                      ['def self.foo',
                       '  # bar',
                       'end']
    end

    context 'when method is nested in class scope' do
      it_behaves_like 'code with offense',
                      ['class Foo',
                       '  def bar; end',
                       'end'].join("\n"),
                      ['class Foo',
                       '  def bar',
                       '  end',
                       'end'].join("\n")
    end
  end
end
