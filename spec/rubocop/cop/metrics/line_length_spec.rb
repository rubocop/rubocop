# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::LineLength, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'Max' => 80, 'IgnoredPatterns' => nil } }

  it "registers an offense for a line that's 81 characters wide" do
    inspect_source('#' * 81)
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.first.message).to eq('Line is too long. [81/80]')
    expect(cop.config_to_allow_offenses).to eq(exclude_limit: { 'Max' => 81 })
  end

  it 'highlights excessive characters' do
    inspect_source('#' * 80 + 'abc')
    expect(cop.highlights).to eq(['abc'])
  end

  it "accepts a line that's 80 characters wide" do
    expect_no_offenses('#' * 80)
  end

  it 'registers an offense for long line before __END__ but not after' do
    inspect_source(['#' * 150,
                    '__END__',
                    '#' * 200].join("\n"))
    expect(cop.messages).to eq(['Line is too long. [150/80]'])
  end

  context 'when AllowURI option is enabled' do
    let(:cop_config) { { 'Max' => 80, 'AllowURI' => true } }

    context 'and all the excessive characters are part of an URL' do
      it 'accepts the line' do
        expect_no_offenses(<<-RUBY)
          # Some documentation comment...
          # See: https://github.com/rubocop-hq/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c
        RUBY
      end

      context 'and the URL is wrapped in single quotes' do
        it 'accepts the line' do
          expect_no_offenses(<<-RUBY)
            # See: 'https://github.com/rubocop-hq/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c'
          RUBY
        end
      end

      context 'and the URL is wrapped in double quotes' do
        it 'accepts the line' do
          expect_no_offenses(<<-RUBY)
            # See: "https://github.com/rubocop-hq/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c"
          RUBY
        end
      end
    end

    context 'and the excessive characters include a complete URL' do
      it 'registers an offense for the line' do
        expect_offense(<<-RUBY)
          # See: http://google.com/, http://gmail.com/, https://maps.google.com/, http://plus.google.com/
                                                                                ^^^^^^^^^^^^^^^^^^^^^^^^^ Line is too long. [105/80]
        RUBY
      end
    end

    context 'and the excessive characters include part of an URL ' \
            'and another word' do
      it 'registers an offense for the line' do
        expect_offense(<<-RUBY)
          # See: https://github.com/rubocop-hq/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c and
                                                                                                      ^^^^ Line is too long. [106/80]
          #   http://google.com/
        RUBY
      end
    end

    context 'and an error other than URI::InvalidURIError is raised ' \
            'while validating an URI-ish string' do
      let(:cop_config) do
        { 'Max' => 80, 'AllowURI' => true, 'URISchemes' => %w[LDAP] }
      end

      let(:source) { <<-RUBY }
        xxxxxxxxxxxxxxxxxxxxxxxxxxxxzxxxxxxxxxxx = LDAP::DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY
      RUBY

      it 'does not crash' do
        expect { inspect_source(source) }.not_to raise_error
      end
    end

    context 'and the URL does not have a http(s) scheme' do
      let(:source) { <<-RUBY }
        xxxxxxxxxxxxxxxxxxxxxxxxxxxxzxxxxxxxxxxx = 'otherprotocol://a.very.long.line.which.violates.LineLength/sadf'
      RUBY

      it 'rejects the line' do
        inspect_source(source)
        expect(cop.offenses.size).to eq(1)
      end

      context 'and the scheme has been configured' do
        let(:cop_config) do
          { 'Max' => 80, 'AllowURI' => true, 'URISchemes' => %w[otherprotocol] }
        end

        it 'does not register an offense' do
          expect_no_offenses(source)
        end
      end
    end
  end

  context 'when IgnoredPatterns option is set' do
    let(:cop_config) do
      {
        'Max' => 18,
        'IgnoredPatterns' => ['^\s*test\s', /^\s*def\s+test_/]
      }
    end

    let(:source) do
      <<-RUBY.strip_indent
        class ExampleTest < TestCase
          test 'some really long test description which exceeds length' do
          end
          def test_some_other_long_test_description_which_exceeds_length
          end
        end
      RUBY
    end

    it 'accepts long lines matching a pattern but not other long lines' do
      inspect_source(source)
      expect(cop.highlights).to eq(['< TestCase'])
    end
  end

  context 'when AllowHeredoc option is enabled' do
    let(:cop_config) { { 'Max' => 80, 'AllowHeredoc' => true } }

    let(:source) { <<-RUBY }
      <<-SQL
        SELECT posts.id, posts.title, users.name FROM posts LEFT JOIN users ON posts.user_id = users.id;
      SQL
    RUBY

    it 'accepts long lines in heredocs' do
      expect_no_offenses(source)
    end

    context 'when the source has no AST' do
      let(:source) { '# this results in AST being nil' }

      it 'does not crash' do
        expect { inspect_source(source) }.not_to raise_error
      end
    end

    context 'and only certain heredoc delimiters are whitelisted' do
      let(:cop_config) do
        { 'Max' => 80, 'AllowHeredoc' => %w[SQL OK], 'IgnoredPatterns' => [] }
      end

      let(:source) { <<-RUBY }
        foo(<<-DOC, <<-SQL, <<-FOO)
          1st offense: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          \#{<<-OK}
            no offense (whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          OK
          2nd offense: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        DOC
          no offense (whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          \#{<<-XXX}
            no offense (nested inside whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          XXX
          no offense (whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        SQL
          3rd offense: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          \#{<<-SQL}
            no offense (whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          SQL
          4th offense: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        FOO
      RUBY

      it 'rejects long lines in heredocs with not whitelisted delimiters' do
        inspect_source(source)
        expect(cop.offenses.size).to eq(4)
      end
    end
  end

  context 'when AllowURI option is disabled' do
    let(:cop_config) { { 'Max' => 80, 'AllowURI' => false } }

    context 'and all the excessive characters are part of an URL' do
      it 'registers an offense for the line' do
        expect_offense(<<-RUBY)
          # See: https://github.com/rubocop-hq/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c
                                                                                ^^^^^^^^^^^^^^^^^^^^^^ Line is too long. [102/80]
        RUBY
      end
    end
  end

  context 'when IgnoreCopDirectives is disabled' do
    let(:cop_config) { { 'Max' => 80, 'IgnoreCopDirectives' => false } }

    context 'and the source is acceptable length' do
      let(:acceptable_source) { 'a' * 80 }

      context 'with a trailing Rubocop directive' do
        let(:cop_directive) { ' # rubcop:disable Metrics/SomeCop' }
        let(:source) { acceptable_source + cop_directive }

        it 'registers an offense for the line' do
          inspect_source(source)
          expect(cop.offenses.size).to eq(1)
        end

        it 'highlights the excess directive' do
          inspect_source(source)
          expect(cop.highlights).to eq([cop_directive])
        end
      end

      context 'with an inline comment' do
        let(:excess_comment) { ' ###' }
        let(:source) { acceptable_source + excess_comment }

        it 'highlights the excess comment' do
          inspect_source(source)
          expect(cop.highlights).to eq([excess_comment])
        end
      end
    end

    context 'and the source is too long and has a trailing cop directive' do
      let(:excess_with_directive) { 'b # rubocop:disable Metrics/AbcSize' }
      let(:source) { 'a' * 80 + excess_with_directive }

      it 'highlights the excess source and cop directive' do
        inspect_source(source)
        expect(cop.highlights).to eq([excess_with_directive])
      end
    end
  end

  context 'when IgnoreCopDirectives is enabled' do
    let(:cop_config) { { 'Max' => 80, 'IgnoreCopDirectives' => true } }

    context 'and the Rubocop directive is excessively long' do
      let(:source) { <<-RUBY }
        # rubocop:disable Metrics/SomeReallyLongMetricNameThatShouldBeMuchShorterAndNeedsANameChange
      RUBY

      it 'accepts the line' do
        expect_no_offenses(source)
      end
    end

    context 'and the Rubocop directive causes an excessive line length' do
      let(:source) { <<-RUBY }
        def method_definition_that_is_just_under_the_line_length_limit(foo, bar) # rubocop:disable Metrics/AbcSize
          # complex method
        end
      RUBY

      it 'accepts the line' do
        expect_no_offenses(source)
      end

      context 'and has explanatory text' do
        let(:source) { <<-RUBY }
          def method_definition_that_is_just_under_the_line_length_limit(foo) # rubocop:disable Metrics/AbcSize inherently complex!
            # complex
          end
        RUBY

        it 'does not register an offense' do
          expect_no_offenses(source)
        end
      end
    end

    context 'and the source is too long' do
      let(:source) { 'a' * 80 + 'bcd' + ' # rubocop:enable Style/ClassVars' }

      it 'registers an offense for the line' do
        inspect_source(source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'highlights only the non-directive part' do
        inspect_source(source)
        expect(cop.highlights).to eq(['bcd'])
      end

      context 'and the source contains non-directive # as comment' do
        let(:source) { <<-RUBY }
          aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa # bbbbbbbbbbbbbb # rubocop:enable Style/ClassVars'
        RUBY

        it 'registers an offense for the line' do
          inspect_source(source)
          expect(cop.offenses.size).to eq(1)
        end

        it 'highlights only the non-directive part' do
          inspect_source(source)
          expect(cop.highlights).to eq(['bbbbbbb'])
        end
      end

      context 'and the source contains non-directive #s as non-comment' do
        let(:source) { <<-RUBY }
          LARGE_DATA_STRING_PATTERN = %r{\A([A-Za-z0-9\+\/#]*\={0,2})#([A-Za-z0-9\+\/#]*\={0,2})#([A-Za-z0-9\+\/#]*\={0,2})\z} # rubocop:disable LineLength
        RUBY

        it 'registers an offense for the line' do
          inspect_source(source)
          expect(cop.offenses.size).to eq(1)
        end

        it 'highlights only the non-directive part' do
          inspect_source(source)
          expect(cop.highlights).to eq([']*={0,2})#([A-Za-z0-9+/#]*={0,2})z}'])
        end
      end
    end
  end

  context 'affecting by IndentationWidth from Layout\Tab' do
    shared_examples 'with tabs indentation' do
      it "registers an offense for a line that's including 2 tab with size 2" \
         ' and 28 other characters' do
        inspect_source("\t\t" + '#' * 28)
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to eq('Line is too long. [32/30]')
        expect(cop.config_to_allow_offenses)
          .to eq(exclude_limit: { 'Max' => 32 })
      end

      it 'highlights excessive characters' do
        inspect_source("\t" + '#' * 28 + 'a')
        expect(cop.highlights).to eq(['a'])
      end

      it "accepts a line that's including 1 tab with size 2" \
         ' and 28 other characters' do
        expect_no_offenses("\t" + '#' * 28)
      end
    end

    context 'without AllowURI option' do
      let(:config) do
        RuboCop::Config.new(
          'Layout/IndentationWidth' => {
            'Width' => 1
          },
          'Layout/Tab' => {
            'Enabled' => false,
            'IndentationWidth' => 2
          },
          'Metrics/LineLength' => {
            'Max' => 30
          }
        )
      end

      it_behaves_like 'with tabs indentation'
    end

    context 'with AllowURI option' do
      let(:config) do
        RuboCop::Config.new(
          'Layout/IndentationWidth' => {
            'Width' => 1
          },
          'Layout/Tab' => {
            'Enabled' => false,
            'IndentationWidth' => 2
          },
          'Metrics/LineLength' => {
            'Max' => 30,
            'AllowURI' => true
          }
        )
      end

      it_behaves_like 'with tabs indentation'

      it "accepts a line that's including URI" do
        expect_no_offenses("\t\t# https://github.com/rubocop-hq/rubocop")
      end

      it "accepts a line that's including URI and exceeds by 1 char" do
        expect_no_offenses("\t\t# https://github.com/ruboco")
      end

      it "accepts a line that's including URI with text" do
        expect_no_offenses("\t\t# See https://github.com/rubocop-hq/rubocop")
      end

      it "accepts a line that's including URI in quotes with text" do
        expect_no_offenses("\t\t# See 'https://github.com/rubocop-hq/rubocop'")
      end
    end
  end
end
