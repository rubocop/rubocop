# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyWhen, :config do
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

  shared_examples 'code without offense' do |code|
    let(:source) { code }

    it 'does not register an offense' do
      expect(cop.offenses.empty?).to be(true)
    end
  end

  let(:message) { 'Avoid `when` branches without a body.' }

  context 'when a `when` body is missing' do
    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      case foo
      when :bar then 1
      when :baz # nothing
      end
    RUBY

    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      case foo
      when :bar then 1
      when :baz # nothing
      else 3
      end
    RUBY

    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      case foo
      when :bar then 1
      when :baz then # nothing
      end
    RUBY

    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      case foo
      when :bar then 1
      when :baz then # nothing
      else 3
      end
    RUBY

    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      case foo
      when :bar
        1
      when :baz
        # nothing
      end
    RUBY

    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      case foo
      when :bar
        1
      when :baz
        # nothing
      else
        3
      end
    RUBY

    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      case
      when :bar
        1
      when :baz
        # nothing
      else
        3
      end
    RUBY
  end

  context 'when a `when` body is present' do
    it_behaves_like 'code without offense', <<-RUBY.strip_indent
      case foo
      when :bar then 1
      when :baz then 2
      end
    RUBY

    it_behaves_like 'code without offense', <<-RUBY.strip_indent
      case foo
      when :bar then 1
      when :baz then 2
      else 3
      end
    RUBY

    it_behaves_like 'code without offense', <<-RUBY.strip_indent
      case foo
      when :bar
        1
      when :baz
        2
      end
    RUBY

    it_behaves_like 'code without offense', <<-RUBY.strip_indent
      case foo
      when :bar
        1
      when :baz
        2
      else
        3
      end
    RUBY
    it_behaves_like 'code without offense', <<-RUBY.strip_indent
      case
      when :bar
        1
      when :baz
        2
      else
        3
      end
    RUBY
  end
end
