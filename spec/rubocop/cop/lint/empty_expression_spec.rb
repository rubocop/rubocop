# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyExpression, :config do
  subject(:cop) { described_class.new(config) }

  before do
    inspect_source(source)
  end

  shared_examples 'code with offense' do |code, expected = nil|
    context "when checking #{code}" do
      let(:source) { code }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq([message])
      end

      if expected
        it 'auto-corrects' do
          expect(autocorrect_source(code)).to eq(expected)
        end
      else
        it 'does not auto-correct' do
          expect(autocorrect_source(code)).to eq(code)
        end
      end
    end
  end

  let(:message) { 'Avoid empty expressions.' }

  context 'when used as a standalone expression' do
    it_behaves_like 'code with offense',
                    '()'

    context 'with nested empty expressions' do
      it_behaves_like 'code with offense',
                      '(())'
    end
  end

  context 'when used in a condition' do
    it_behaves_like 'code with offense',
                    'if (); end'

    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      if foo
        1
      elsif ()
        2
      end
    RUBY

    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      case ()
      when :foo then 1
      end
    RUBY

    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      case foo
      when () then 1
      end
    RUBY

    it_behaves_like 'code with offense',
                    '() ? true : false'

    it_behaves_like 'code with offense',
                    'foo ? () : bar'
  end

  context 'when used as a return value' do
    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      def foo
        ()
      end
    RUBY

    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      if foo
        ()
      end
    RUBY

    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      case foo
      when :bar then ()
      end
    RUBY
  end

  context 'when used as an assignment' do
    it_behaves_like 'code with offense',
                    'foo = ()'
  end
end
