# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::LeadingEmptyLines, :config do
  it 'allows an empty input' do
    expect_no_offenses('')
  end

  it 'allows blank lines without any comments or code' do
    expect_no_offenses("\n")
  end

  it 'accepts not having a blank line before a class' do
    expect_no_offenses(<<~RUBY)
      class Foo
      end
    RUBY
  end

  it 'accepts not having a blank line before code' do
    expect_no_offenses(<<~RUBY)
      puts 1
    RUBY
  end

  it 'accepts not having a blank line before a comment' do
    expect_no_offenses(<<~RUBY)
      # something
    RUBY
  end

  it 'registers an offense and corrects a new line before a class' do
    expect_offense(<<~RUBY)

      class Foo
      ^^^^^ Unnecessary blank line at the beginning of the source.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
      end
    RUBY
  end

  it 'registers an offense and corrects a new line before code' do
    expect_offense(<<~RUBY)

      puts 1
      ^^^^ Unnecessary blank line at the beginning of the source.
    RUBY

    expect_correction(<<~RUBY)
      puts 1
    RUBY
  end

  it 'registers an offense and corrects a new line before a comment' do
    expect_offense(<<~RUBY)

      # something
      ^^^^^^^^^^^ Unnecessary blank line at the beginning of the source.
    RUBY

    expect_correction(<<~RUBY)
      # something
    RUBY
  end

  it 'registers an offense and corrects multiple new lines before a class' do
    expect_offense(<<~RUBY)


      class Foo
      ^^^^^ Unnecessary blank line at the beginning of the source.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
      end
    RUBY
  end

  context 'autocorrect' do
    context 'in collaboration' do
      let(:config) do
        RuboCop::Config.new('Layout/SpaceAroundEqualsInParameterDefault' => {
                              'SupportedStyles' => %i[space no_space],
                              'EnforcedStyle' => :space
                            })
      end
      let(:cops) do
        cop_classes = [described_class, RuboCop::Cop::Layout::SpaceAroundEqualsInParameterDefault]
        RuboCop::Cop::Registry.new(cop_classes)
      end

      it 'does not invoke conflicts with other cops' do
        source_with_offenses = <<~RUBY

          def bar(arg =1); end
        RUBY

        options = { autocorrect: true, stdin: true }
        team = RuboCop::Cop::Team.mobilize(cops, config, options)
        team.inspect_file(parse_source(source_with_offenses, nil))
        new_source = options[:stdin]

        expect(new_source).to eq(<<~RUBY)
          def bar(arg = 1); end
        RUBY
      end
    end
  end
end
