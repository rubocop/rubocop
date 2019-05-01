# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::InheritException, :config do
  subject(:cop) { described_class.new(config) }

  context 'when class inherits from `Exception`' do
    context 'with enforced style set to `runtime_error`' do
      let(:cop_config) { { 'EnforcedStyle' => 'runtime_error' } }

      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          class C < Exception; end
                    ^^^^^^^^^ Inherit from `RuntimeError` instead of `Exception`.
        RUBY
      end

      it 'auto-corrects' do
        corrected = autocorrect_source('class C < Exception; end')

        expect(corrected).to eq('class C < RuntimeError; end')
      end

      context 'when creating a subclass using Class.new' do
        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            Class.new(Exception)
                      ^^^^^^^^^ Inherit from `RuntimeError` instead of `Exception`.
          RUBY
        end

        it 'auto-corrects' do
          corrected = autocorrect_source('Class.new(Exception)')

          expect(corrected).to eq('Class.new(RuntimeError)')
        end
      end
    end

    context 'with enforced style set to `standard_error`' do
      let(:cop_config) { { 'EnforcedStyle' => 'standard_error' } }

      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          class C < Exception; end
                    ^^^^^^^^^ Inherit from `StandardError` instead of `Exception`.
        RUBY
      end

      it 'auto-corrects' do
        corrected = autocorrect_source('class C < Exception; end')

        expect(corrected).to eq('class C < StandardError; end')
      end

      context 'when creating a subclass using Class.new' do
        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            Class.new(Exception)
                      ^^^^^^^^^ Inherit from `StandardError` instead of `Exception`.
          RUBY
        end

        it 'auto-corrects' do
          corrected = autocorrect_source('Class.new(Exception)')

          expect(corrected).to eq('Class.new(StandardError)')
        end
      end
    end
  end
end
