# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::For, :config do
  subject(:cop) { described_class.new(config) }

  context 'when each is the enforced style' do
    let(:cop_config) { { 'EnforcedStyle' => 'each' } }

    it 'registers an offense for for' do
      expect_offense(<<-RUBY.strip_indent)
        def func
          for n in [1, 2, 3] do
          ^^^ Prefer `each` over `for`.
            puts n
          end
        end
      RUBY
    end

    it 'registers an offense for opposite + correct style' do
      expect_offense(<<-RUBY.strip_indent)
        def func
          for n in [1, 2, 3] do
          ^^^ Prefer `each` over `for`.
            puts n
          end
          [1, 2, 3].each do |n|
            puts n
          end
        end
      RUBY
    end

    it 'accepts multiline each' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def func
          [1, 2, 3].each do |n|
            puts n
          end
        end
      RUBY
    end

    it 'accepts :for' do
      expect_no_offenses('[:for, :ala, :bala]')
    end

    it 'accepts def for' do
      expect_no_offenses('def for; end')
    end
  end

  context 'when for is the enforced style' do
    let(:cop_config) { { 'EnforcedStyle' => 'for' } }

    it 'accepts for' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def func
          for n in [1, 2, 3] do
            puts n
          end
        end
      RUBY
    end

    it 'registers an offense for multiline each' do
      expect_offense(<<-RUBY.strip_indent)
        def func
          [1, 2, 3].each do |n|
                    ^^^^ Prefer `for` over `each`.
            puts n
          end
        end
      RUBY
    end

    it 'registers an offense for correct + opposite style' do
      expect_offense(<<-RUBY.strip_indent)
        def func
          for n in [1, 2, 3] do
            puts n
          end
          [1, 2, 3].each do |n|
                    ^^^^ Prefer `for` over `each`.
            puts n
          end
        end
      RUBY
    end

    it 'accepts single line each' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def func
          [1, 2, 3].each { |n| puts n }
        end
      RUBY
    end

    context 'when using safe navigation operator' do
      let(:ruby_version) { 2.3 }

      it 'does not break' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def func
            [1, 2, 3]&.each { |n| puts n }
          end
        RUBY
      end
    end
  end
end
