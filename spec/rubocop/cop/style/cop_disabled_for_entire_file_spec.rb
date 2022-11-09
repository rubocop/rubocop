# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CopDisabledForEntireFile, :config do
  let(:message) do
    'Prefer using directives on smaller sections of code, ' \
      'or if you need to disable the entire file, do it in your configuration file.'
  end

  it 'registers an offense when all the code is wrapped in a disable directive' do
    expect_offense(<<~RUBY)
      # rubocop:disable Department/CopName
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      false
      # rubocop:enable Department/CopName
    RUBY
  end

  it 'registers an offense when all the code is wrapped in a todo directive' do
    expect_offense(<<~RUBY)
      # rubocop:todo Department/CopName
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      false
      # rubocop:enable Department/CopName
    RUBY
  end

  context "when enabling instead of disabling" do
    let(:other_cops) { { "Department/CopName" => { "Enabled" => false } } }
    let(:message) { super().gsub('disable', 'enable') }

    it 'registers an offense when all the code is wrapped in an enable directive' do
      expect_offense(<<~RUBY)
        # rubocop:enable Department/CopName
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        false
        # rubocop:disable Department/CopName
      RUBY
    end
  end

  it 'registers an offense when multiple lines of code are wrapped in a disable directive' do
    expect_offense(<<~RUBY)
      # rubocop:disable Department/CopName
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      class LotsOfCode
        attr_reader :stuff

        def initialize(stuff)
          @stuff = stuff
        end
      end
      # rubocop:enable Department/CopName
    RUBY
  end

  it 'registers an offense when all the code is wrapped in a disable directive, even if a sigil comment is present' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      # rubocop:disable Department/CopName
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      false
      # rubocop:enable Department/CopName
    RUBY
  end

  it 'registers an offense for block directives wrapping the only line of code, even if it has an inline directive' do
    expect_offense(<<~RUBY)
      # rubocop:disable Department/CopName
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      true # rubocop:disable Department/AnotherCopName
      # rubocop:enable Department/CopName
    RUBY
  end

  it 'registers an offense for nested block directives wrapping all the code' do
    expect_offense(<<~RUBY)
      # rubocop:disable Department/CopName
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      # rubocop:disable Department/AnotherCopName
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      true
      # rubocop:enable Department/AnotherCopName
      # rubocop:enable Department/CopName
    RUBY
  end

  it 'registers only offenses for block directives wrapping all the code, not all block directives' do
    expect_offense(<<~RUBY)
      # rubocop:disable Department/CopName
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      123
      # rubocop:disable Department/AnotherCopName
      456
      # rubocop:enable Department/AnotherCopName
      # rubocop:enable Department/CopName
    RUBY
  end

  it 'registers no offenses when there is code after the enable directive' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Department/CopName
      false
      # rubocop:enable Department/CopName
      true
    RUBY
  end

  it 'registers no offenses when there is code before the disable directive' do
    expect_no_offenses(<<~RUBY)
      true
      # rubocop:disable Department/CopName
      false
      # rubocop:enable Department/CopName
    RUBY
  end

  it 'registers no offenses when the file is empty except for comments' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Department/CopName
      # rubocop:enable Department/CopName
    RUBY
  end

  it 'registers no offenses when the file is empty' do
    expect_no_offenses('')
  end

  it 'registers no offenses for single inline directive' do
    expect_no_offenses(<<~RUBY)
      true # rubocop:disable Department/CopName
    RUBY
  end

  it 'registers no offenses when disabling all cops' do
    # Because `rubocop:disable all` disables all cops, it disables this one too.
    # Ideally, it would probably still apply, but then this cop would need to be a special case.
    expect_no_offenses(<<~RUBY)
      # rubocop:disable all
      false
      # rubocop:enable all
    RUBY
  end

  it 'registers no offenses when disabling itself' do
    # Similarly to disabling `all`, this should probably also be an offense,
    # but it's unlikely anyone would ever do this anyway.
    expect_no_offenses(<<~RUBY)
      # rubocop:disable #{cop_class.cop_name}
      false
      # rubocop:enable #{cop_class.cop_name}
    RUBY
  end
end
