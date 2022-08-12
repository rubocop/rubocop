# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceBeforeBlockBraces, :config do
  let(:cop_config) { { 'EnforcedStyle' => 'space' } }

  context 'when EnforcedStyle is space' do
    it 'accepts braces surrounded by spaces' do
      expect_no_offenses('each { puts }')
    end

    it 'registers an offense and corrects left brace without outer space' do
      expect_offense(<<~RUBY)
        each{ puts }
            ^ Space missing to the left of {.
      RUBY

      expect_correction(<<~RUBY)
        each { puts }
      RUBY
    end

    it 'registers an offense and corrects opposite + correct style' do
      expect_offense(<<~RUBY)
        each{ puts }
            ^ Space missing to the left of {.
        each { puts }
      RUBY

      expect_correction(<<~RUBY)
        each { puts }
        each { puts }
      RUBY
    end

    it 'registers an offense and corrects multiline block where the left ' \
       'brace has no outer space' do
      expect_offense(<<~RUBY)
        foo.map{ |a|
               ^ Space missing to the left of {.
          a.bar.to_s
        }
      RUBY

      expect_correction(<<~RUBY)
        foo.map { |a|
          a.bar.to_s
        }
      RUBY
    end

    context 'Ruby 2.7', :ruby27 do
      it 'registers an offense and corrects opposite + correct style' do
        expect_offense(<<~RUBY)
          each{ _1 }
              ^ Space missing to the left of {.
          each { _1 }
        RUBY

        expect_correction(<<~RUBY)
          each { _1 }
          each { _1 }
        RUBY
      end

      it 'registers an offense and corrects multiline block where the left ' \
         'brace has no outer space' do
        expect_offense(<<~RUBY)
          foo.map{
                 ^ Space missing to the left of {.
            _1.bar.to_s
          }
        RUBY

        expect_correction(<<~RUBY)
          foo.map {
            _1.bar.to_s
          }
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'registers an offense and corrects braces surrounded by spaces' do
      expect_offense(<<~RUBY)
        each { puts }
            ^ Space detected to the left of {.
      RUBY

      expect_correction(<<~RUBY)
        each{ puts }
      RUBY
    end

    it 'registers an offense and corrects correct + opposite style' do
      expect_offense(<<~RUBY)
        each{ puts }
        each { puts }
            ^ Space detected to the left of {.
      RUBY

      expect_correction(<<~RUBY)
        each{ puts }
        each{ puts }
      RUBY
    end

    it 'accepts left brace without outer space' do
      expect_no_offenses('each{ puts }')
    end

    context 'Ruby 2.7', :ruby27 do
      it 'registers an offense and corrects correct + opposite style' do
        expect_offense(<<~RUBY)
          each{ _1 }
          each { _1 }
              ^ Space detected to the left of {.
        RUBY

        expect_correction(<<~RUBY)
          each{ _1 }
          each{ _1 }
        RUBY
      end
    end

    context 'with `EnforcedStyle` of `Style/BlockDelimiters`' do
      let(:config) do
        merged_config = RuboCop::ConfigLoader.default_configuration[
          'Layout/SpaceBeforeBlockBraces'
        ].merge(cop_config)

        RuboCop::Config.new(
          'Layout/SpaceBeforeBlockBraces' => merged_config,
          'Style/BlockDelimiters' => { 'EnforcedStyle' => 'line_count_based' }
        )
      end

      it 'accepts left brace without outer space' do
        expect_no_offenses(<<~RUBY)
          let(:foo){{foo: 1, bar: 2}}
        RUBY
      end
    end
  end

  context 'with space before empty braces not allowed' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'space',
        'EnforcedStyleForEmptyBraces' => 'no_space'
      }
    end

    it 'accepts empty braces without outer space' do
      expect_no_offenses('->{}')
    end

    it 'registers an offense and corrects empty braces' do
      expect_offense(<<~RUBY)
        -> {}
          ^ Space detected to the left of {.
      RUBY

      expect_correction(<<~RUBY)
        ->{}
      RUBY
    end
  end

  context 'with space before empty braces allowed' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'no_space',
        'EnforcedStyleForEmptyBraces' => 'space'
      }
    end

    it 'accepts empty braces with outer space' do
      expect_no_offenses('-> {}')
    end

    it 'registers an offense and corrects empty braces' do
      expect_offense(<<~RUBY)
        ->{}
          ^ Space missing to the left of {.
      RUBY

      expect_correction(<<~RUBY)
        -> {}
      RUBY
    end
  end

  context 'with invalid value for EnforcedStyleForEmptyBraces' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBraces' => 'unknown' } }

    it 'fails with an error' do
      expect { expect_no_offenses('each {}') }
        .to raise_error('Unknown EnforcedStyleForEmptyBraces selected!')
    end
  end
end
