# frozen_string_literal: true

describe RuboCop::Cop::Metrics::LineLength, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'Max' => 80, 'IgnoredPatterns' => nil } }

  it "registers an offense for a line that's 81 characters wide" do
    inspect_source('#' * 81)
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.first.message).to eq('Line is too long. [81/80]')
    expect(cop.config_to_allow_offenses).to eq('Max' => 81)
  end

  it 'highlights excessive characters' do
    inspect_source('#' * 80 + 'abc')
    expect(cop.highlights).to eq(['abc'])
  end

  it "accepts a line that's 80 characters wide" do
    inspect_source('#' * 80)
    expect(cop.offenses.empty?).to be(true)
  end

  it 'registers an offense for long line before __END__ but not after' do
    inspect_source(['#' * 150,
                    '__END__',
                    '#' * 200])
    expect(cop.messages).to eq(['Line is too long. [150/80]'])
  end

  context 'when AllowURI option is enabled' do
    let(:cop_config) { { 'Max' => 80, 'AllowURI' => true } }

    context 'and all the excessive characters are part of an URL' do
      # This code example is allowed by AllowURI feature itself :).
      let(:source) { <<-RUBY }
        # Some documentation comment...
        # See: https://github.com/bbatsov/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c
      RUBY

      it 'accepts the line' do
        inspect_source(source)
        expect(cop.offenses.empty?).to be(true)
      end
    end

    context 'and the excessive characters include a complete URL' do
      let(:source) { <<-RUBY }
        # See: http://google.com/, http://gmail.com/, https://maps.google.com/, http://plus.google.com/
      RUBY

      it 'registers an offense for the line' do
        inspect_source(source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'highlights all the excessive characters' do
        inspect_source(source)
        expect(cop.highlights).to eq(['http://plus.google.com/'])
      end
    end

    context 'and the excessive characters include part of an URL ' \
            'and another word' do
      let(:source) { <<-RUBY }
        # See: https://github.com/bbatsov/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c and
        #   http://google.com/
      RUBY

      it 'registers an offense for the line' do
        inspect_source(source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'highlights only the non-URL part' do
        inspect_source(source)
        expect(cop.highlights).to eq([' and'])
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

        it 'accepts the line' do
          inspect_source(source)
          expect(cop.offenses.empty?).to be(true)
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
      inspect_source(source)
      expect(cop.offenses.empty?).to be(true)
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
          1st offence: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          \#{<<-OK}
            no offence (whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          OK
          2nd offence: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        DOC
          no offence (whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          \#{<<-XXX}
            no offence (nested inside whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          XXX
          no offence (whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        SQL
          3rd offence: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          \#{<<-SQL}
            no offence (whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          SQL
          4th offence: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
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
      let(:source) { <<-RUBY }
        # See: https://github.com/bbatsov/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c
      RUBY

      it 'registers an offense for the line' do
        inspect_source(source)
        expect(cop.offenses.size).to eq(1)
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
        inspect_source(source)
        expect(cop.offenses.empty?).to be(true)
      end
    end

    context 'and the Rubocop directive causes an excessive line length' do
      let(:source) { <<-RUBY }
        def method_definition_that_is_just_under_the_line_length_limit(foo, bar) # rubocop:disable Metrics/AbcSize
          # complex method
        end
      RUBY

      it 'accepts the line' do
        inspect_source(source)
        expect(cop.offenses.empty?).to be(true)
      end

      context 'and has explanatory text' do
        let(:source) { <<-RUBY }
          def method_definition_that_is_just_under_the_line_length_limit(foo) # rubocop:disable Metrics/AbcSize inherently complex!
            # complex
          end
        RUBY

        it 'accepts the line' do
          inspect_source(source)
          expect(cop.offenses.empty?).to be(true)
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
end
