# frozen_string_literal: true

describe RuboCop::Cop::Style::MethodMissing do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  shared_examples 'code with offense' do |code|
    let(:source) { code }

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq([message])
    end
  end

  shared_examples 'code without offense' do |code|
    let(:source) { code }

    it 'does not register an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  describe 'when not implementing #respond_to_missing? or calling #super' do
    let(:message) do
      'When using `method_missing`, define `respond_to_missing?` and ' \
      'fall back on `super`.'
    end

    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      class Test
        def method_missing; end
      end
    RUBY
  end

  describe 'when not implementing #respond_to_missing?' do
    let(:message) do
      'When using `method_missing`, define `respond_to_missing?`.'
    end

    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      class Test
        def method_missing
          super
        end
      end
    RUBY
  end

  describe 'when not calling #super' do
    let(:message) do
      'When using `method_missing`, fall back on `super`.'
    end

    it_behaves_like 'code with offense', <<-RUBY.strip_indent
      class Test
        def respond_to_missing?; end
        def method_missing; end
      end
    RUBY
  end

  describe 'when implementing #respond_to_missing? and calling #super' do
    context 'when implemented as instance methods' do
      it_behaves_like 'code without offense', <<-RUBY.strip_indent
        class Test
          def respond_to_missing?; end
          def method_missing
            super
          end
        end
      RUBY
    end

    context 'when implemented as class methods' do
      it_behaves_like 'code without offense', <<-RUBY.strip_indent
        class Test
          def self.respond_to_missing?; end
          def self.method_missing
            super
          end
        end
      RUBY
    end

    context 'when implemented with different scopes' do
      let(:message) do
        'When using `method_missing`, define `respond_to_missing?`.'
      end

      it_behaves_like 'code with offense', <<-RUBY.strip_indent
        class Test
          def respond_to_missing?; end
          def self.method_missing
            super
          end
        end
      RUBY
    end
  end
end
