# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantCopEnableDirective do
  subject(:cop) { described_class.new }

  it 'registers offense and corrects unnecessary enable' do
    expect_offense(<<~RUBY)
      foo
      # rubocop:enable Layout/LineLength
                       ^^^^^^^^^^^^^^^^^ Unnecessary enabling of Layout/LineLength.
    RUBY

    expect_correction(<<~RUBY)
      foo

    RUBY
  end

  it 'registers multiple offenses and corrects the same comment' do
    expect_offense(<<~RUBY)
      foo
      # rubocop:enable Metrics/ModuleLength, Metrics/AbcSize
                                             ^^^^^^^^^^^^^^^ Unnecessary enabling of Metrics/AbcSize.
                       ^^^^^^^^^^^^^^^^^^^^ Unnecessary enabling of Metrics/ModuleLength.
      bar
    RUBY

    expect_correction(<<~RUBY)
      foo
      # rubocop:enable
      bar
    RUBY
  end

  it 'registers correct offense when combined with necessary enable' do
    expect_offense(<<~RUBY)
      # rubocop:disable Layout/LineLength
      fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo = barrrrrrrrrrrrrrrrrrrrrrrrrr
      # rubocop:enable Metrics/AbcSize, Layout/LineLength
                       ^^^^^^^^^^^^^^^ Unnecessary enabling of Metrics/AbcSize.
      bar
    RUBY

    expect_correction(<<~RUBY)
      # rubocop:disable Layout/LineLength
      fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo = barrrrrrrrrrrrrrrrrrrrrrrrrr
      # rubocop:enable Layout/LineLength
      bar
    RUBY
  end

  it 'registers offense and corrects redundant enabling of same cop' do
    expect_offense(<<~RUBY)
      # rubocop:disable Layout/LineLength
      fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo = barrrrrrrrrrrrrrrrrrrrrrrrrr
      # rubocop:enable Layout/LineLength

      bar

      # rubocop:enable Layout/LineLength
                       ^^^^^^^^^^^^^^^^^ Unnecessary enabling of Layout/LineLength.
      bar
    RUBY

    expect_correction(<<~RUBY)
      # rubocop:disable Layout/LineLength
      fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo = barrrrrrrrrrrrrrrrrrrrrrrrrr
      # rubocop:enable Layout/LineLength

      bar


      bar
    RUBY
  end

  context 'all switch' do
    it 'registers offense and corrects unnecessary enable all' do
      expect_offense(<<~RUBY)
        foo
        # rubocop:enable all
                         ^^^ Unnecessary enabling of all cops.
      RUBY

      expect_correction(<<~RUBY)
        foo

      RUBY
    end

    context 'when at least one cop was disabled' do
      it 'does not register offense' do
        expect_no_offenses(<<~RUBY)
          # rubocop:disable Layout/LineLength
          foooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
          # rubocop:enable all
        RUBY
      end
    end
  end

  context 'autocorrection' do
    context 'when first cop unnecessarily enables' do
      let(:source) do
        <<~RUBY
          # rubocop:disable Layout/LineLength
          foo
          # rubocop:enable Metrics/AbcSize, Layout/LineLength
        RUBY
      end

      it 'removes unnecessary enables' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq(<<~RUBY)
          # rubocop:disable Layout/LineLength
          foo
          # rubocop:enable Layout/LineLength
        RUBY
      end
    end

    context 'when last cop unnecessarily enables' do
      let(:source) do
        <<~RUBY
          # rubocop:disable Layout/LineLength
          foo
          # rubocop:enable Layout/LineLength, Metrics/AbcSize
        RUBY
      end

      it 'removes unnecessary enables' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq(<<~RUBY)
          # rubocop:disable Layout/LineLength
          foo
          # rubocop:enable Layout/LineLength
        RUBY
      end

      context 'with no space between cops & comma' do
        let(:source) do
          <<~RUBY
            # rubocop:disable Layout/LineLength
            foo
            # rubocop:enable Layout/LineLength,Metrics/AbcSize
          RUBY
        end

        it 'removes unnecessary enables' do
          corrected = autocorrect_source(source)
          expect(corrected).to eq(<<~RUBY)
            # rubocop:disable Layout/LineLength
            foo
            # rubocop:enable Layout/LineLength
          RUBY
        end
      end
    end

    context 'when middle cop unnecessarily enables' do
      let(:source) do
        <<~RUBY
          # rubocop:disable Layout/LineLength, Lint/Debugger
          foo
          # rubocop:enable Layout/LineLength, Metrics/AbcSize, Lint/Debugger
        RUBY
      end

      it 'removes unnecessary enables' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq(<<~RUBY)
          # rubocop:disable Layout/LineLength, Lint/Debugger
          foo
          # rubocop:enable Layout/LineLength, Lint/Debugger
        RUBY
      end

      context 'with extra space after commas' do
        let(:source) do
          <<~RUBY
            # rubocop:disable Layout/LineLength,  Lint/Debugger
            foo
            # rubocop:enable Layout/LineLength,  Metrics/AbcSize,  Lint/Debugger
          RUBY
        end

        it 'removes unnecessary enables' do
          corrected = autocorrect_source(source)
          expect(corrected).to eq(<<~RUBY)
            # rubocop:disable Layout/LineLength,  Lint/Debugger
            foo
            # rubocop:enable Layout/LineLength,  Lint/Debugger
          RUBY
        end
      end
    end
  end
end
