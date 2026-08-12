# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLineAfterMagicComment, :config do
  it 'registers an offense for code that immediately follows comment' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      class Foo; end
      ^ Expected at least 1 empty line after magic comments; found 0.
    RUBY

    expect_correction(<<~RUBY)
      # frozen_string_literal: true

      class Foo; end
    RUBY
  end

  it 'registers an offense when code that immediately follows `rbs_inline: enabled` comment' do
    expect_offense(<<~RUBY)
      # rbs_inline: enabled
      class Foo; end
      ^ Expected at least 1 empty line after magic comments; found 0.
    RUBY

    expect_correction(<<~RUBY)
      # rbs_inline: enabled

      class Foo; end
    RUBY
  end

  it 'registers an offense when code that immediately follows `rbs_inline: disabled` comment' do
    expect_offense(<<~RUBY)
      # rbs_inline: disabled
      class Foo; end
      ^ Expected at least 1 empty line after magic comments; found 0.
    RUBY

    expect_correction(<<~RUBY)
      # rbs_inline: disabled

      class Foo; end
    RUBY
  end

  it 'does not register an offense when code that immediately follows `rbs_inline: invalid_value` comment' do
    expect_no_offenses(<<~RUBY)
      # rbs_inline: invalid_value
      class Foo; end
    RUBY
  end

  it 'registers an offense when code that immediately follows typed comment' do
    expect_offense(<<~RUBY)
      # typed: true
      class Foo; end
      ^ Expected at least 1 empty line after magic comments; found 0.
    RUBY

    expect_correction(<<~RUBY)
      # typed: true

      class Foo; end
    RUBY
  end

  it 'registers an offense for documentation immediately following comment' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      # Documentation for Foo
      ^ Expected at least 1 empty line after magic comments; found 0.
      class Foo; end
    RUBY

    expect_correction(<<~RUBY)
      # frozen_string_literal: true

      # Documentation for Foo
      class Foo; end
    RUBY
  end

  it 'registers an offense when multiple magic comments without empty line' do
    expect_offense(<<~RUBY)
      # encoding: utf-8
      # frozen_string_literal: true
      class Foo; end
      ^ Expected at least 1 empty line after magic comments; found 0.
    RUBY

    expect_correction(<<~RUBY)
      # encoding: utf-8
      # frozen_string_literal: true

      class Foo; end
    RUBY
  end

  it 'accepts magic comment followed by encoding' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
      # encoding: utf-8

      class Foo; end
    RUBY
  end

  it 'accepts magic comment with shareable_constant_value' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
      # shareable_constant_value: literal

      class Foo; end
    RUBY

    expect_no_offenses(<<~RUBY)
      # shareable_constant_value: experimental_everything
      # frozen_string_literal: true

      class Foo; end
    RUBY
  end

  it 'accepts magic comment with `rbs_inline: enabled`' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
      # rbs_inline: enabled

      class Foo; end
    RUBY

    expect_no_offenses(<<~RUBY)
      # rbs_inline: enabled
      # frozen_string_literal: true

      class Foo; end
    RUBY
  end

  it 'accepts magic comment with `rbs_inline: disabled`' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
      # rbs_inline: disabled

      class Foo; end
    RUBY

    expect_no_offenses(<<~RUBY)
      # rbs_inline: disabled
      # frozen_string_literal: true

      class Foo; end
    RUBY
  end

  it 'accepts magic comment with typed' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
      # typed: true

      class Foo; end
    RUBY

    expect_no_offenses(<<~RUBY)
      # typed: true
      # frozen_string_literal: true

      class Foo; end
    RUBY
  end

  it 'registers an offense when frozen_string_literal used with shareable_constant_value without empty line' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      # shareable_constant_value: none
      class Foo; end
      ^ Expected at least 1 empty line after magic comments; found 0.
    RUBY

    expect_correction(<<~RUBY)
      # frozen_string_literal: true
      # shareable_constant_value: none

      class Foo; end
    RUBY
  end

  it 'registers an offense when the file is comments only' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      # Hello!
      ^ Expected at least 1 empty line after magic comments; found 0.
    RUBY

    expect_correction(<<~RUBY)
      # frozen_string_literal: true

      # Hello!
    RUBY
  end

  it 'accepts code that separates the comment from the code with a newline' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true

      class Foo; end
    RUBY
  end

  it 'accepts an empty source file' do
    expect_no_offenses('')
  end

  it 'accepts a source file with only a magic comment' do
    expect_no_offenses('# frozen_string_literal: true')
  end

  it 'accepts a magic comment followed only by empty lines' do
    expect_no_offenses("# frozen_string_literal: true\n\n  \n\n")
  end

  it 'accepts more empty lines than required' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true


      class Foo; end
    RUBY
  end

  context 'when `NumberOfEmptyLines: 2`' do
    let(:cop_config) { { 'NumberOfEmptyLines' => 2 } }

    it 'registers an offense for code that immediately follows the comment' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: true
        class Foo; end
        ^ Expected at least 2 empty lines after magic comments; found 0.
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true


        class Foo; end
      RUBY
    end

    it 'registers an offense when only one empty line follows the comment' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: true

        ^{} Expected at least 2 empty lines after magic comments; found 1.
        class Foo; end
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true


        class Foo; end
      RUBY
    end

    it 'accepts code separated from the comment by two empty lines' do
      expect_no_offenses(<<~RUBY)
        # frozen_string_literal: true


        class Foo; end
      RUBY
    end

    it 'accepts more empty lines than required' do
      expect_no_offenses(<<~RUBY)
        # frozen_string_literal: true



        class Foo; end
      RUBY
    end

    it 'accepts a source file with only a magic comment' do
      expect_no_offenses('# frozen_string_literal: true')
    end
  end

  describe 'invalid `NumberOfEmptyLines` configuration' do
    shared_examples 'invalid value' do |value|
      context "when `NumberOfEmptyLines: #{value.inspect}`" do
        let(:cop_config) { { 'NumberOfEmptyLines' => value } }

        it 'raises a validation error' do
          expect { expect_no_offenses('# frozen_string_literal: true') }
            .to raise_error(RuboCop::ValidationError, /only accepts a positive integer/)
        end
      end
    end

    it_behaves_like 'invalid value', 0
    it_behaves_like 'invalid value', -1
    it_behaves_like 'invalid value', 1.5
    it_behaves_like 'invalid value', 'two'
  end
end
