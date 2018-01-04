# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnneededCopEnableDirective do
  subject(:cop) { described_class.new }

  it 'registers offense for unnecessary enable' do
    expect_offense(<<-RUBY.strip_indent)
      foo
      # rubocop:enable Metrics/LineLength
                       ^^^^^^^^^^^^^^^^^^ Unnecessary enabling of Metrics/LineLength.
    RUBY
  end

  it 'registers multiple offenses for same comment' do
    expect_offense(<<-RUBY.strip_indent)
      foo
      # rubocop:enable Metrics/ModuleLength, Metrics/AbcSize
                                             ^^^^^^^^^^^^^^^ Unnecessary enabling of Metrics/AbcSize.
                       ^^^^^^^^^^^^^^^^^^^^ Unnecessary enabling of Metrics/ModuleLength.
      bar
    RUBY
  end

  it 'registers correct offense when combined with necessary enable' do
    expect_offense(<<-RUBY.strip_indent)
      # rubocop:disable Metrics/LineLength
      fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo = barrrrrrrrrrrrrrrrrrrrrrrrrr
      # rubocop:enable Metrics/AbcSize, Metrics/LineLength
                       ^^^^^^^^^^^^^^^ Unnecessary enabling of Metrics/AbcSize.
      bar
    RUBY
  end

  it 'registers offense for redundant enabling of same cop' do
    expect_offense(<<-RUBY.strip_indent)
      # rubocop:disable Metrics/LineLength
      fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo = barrrrrrrrrrrrrrrrrrrrrrrrrr
      # rubocop:enable Metrics/LineLength

      bar

      # rubocop:enable Metrics/LineLength
                       ^^^^^^^^^^^^^^^^^^ Unnecessary enabling of Metrics/LineLength.
      bar
    RUBY
  end

  context 'autocorrection' do
    context 'when entire comment unnecessarily enables' do
      let(:source) do
        <<-RUBY.strip_indent
          foo
          # rubocop:enable Metrics/LineLength
        RUBY
      end

      it 'removes unnecessary enables' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq(<<-RUBY.strip_indent)
          foo

        RUBY
      end
    end

    context 'when first cop unnecessarily enables' do
      let(:source) do
        <<-RUBY.strip_indent
          # rubocop:disable Metrics/LineLength
          foo
          # rubocop:enable Metrics/AbcSize, Metrics/LineLength
        RUBY
      end

      it 'removes unnecessary enables' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq(<<-RUBY.strip_indent)
          # rubocop:disable Metrics/LineLength
          foo
          # rubocop:enable Metrics/LineLength
        RUBY
      end
    end

    context 'when last cop unnecessarily enables' do
      let(:source) do
        <<-RUBY.strip_indent
          # rubocop:disable Metrics/LineLength
          foo
          # rubocop:enable Metrics/LineLength, Metrics/AbcSize
        RUBY
      end

      it 'removes unnecessary enables' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq(<<-RUBY.strip_indent)
          # rubocop:disable Metrics/LineLength
          foo
          # rubocop:enable Metrics/LineLength
        RUBY
      end

      context 'with no space between cops & comma' do
        let(:source) do
          <<-RUBY.strip_indent
            # rubocop:disable Metrics/LineLength
            foo
            # rubocop:enable Metrics/LineLength,Metrics/AbcSize
          RUBY
        end

        it 'removes unnecessary enables' do
          corrected = autocorrect_source(source)
          expect(corrected).to eq(<<-RUBY.strip_indent)
            # rubocop:disable Metrics/LineLength
            foo
            # rubocop:enable Metrics/LineLength
          RUBY
        end
      end
    end

    context 'when middle cop unnecessarily enables' do
      let(:source) do
        <<-RUBY.strip_indent
          # rubocop:disable Metrics/LineLength, Lint/Debugger
          foo
          # rubocop:enable Metrics/LineLength, Metrics/AbcSize, Lint/Debugger
        RUBY
      end

      it 'removes unnecessary enables' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq(<<-RUBY.strip_indent)
          # rubocop:disable Metrics/LineLength, Lint/Debugger
          foo
          # rubocop:enable Metrics/LineLength, Lint/Debugger
        RUBY
      end

      context 'with extra space after commas' do
        let(:source) do
          <<-RUBY.strip_indent
            # rubocop:disable Metrics/LineLength,  Lint/Debugger
            foo
            # rubocop:enable Metrics/LineLength,  Metrics/AbcSize,  Lint/Debugger
          RUBY
        end

        it 'removes unnecessary enables' do
          corrected = autocorrect_source(source)
          expect(corrected).to eq(<<-RUBY.strip_indent)
            # rubocop:disable Metrics/LineLength,  Lint/Debugger
            foo
            # rubocop:enable Metrics/LineLength,  Lint/Debugger
          RUBY
        end
      end
    end
  end
end
