# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Metrics::LineLength, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Max' => 80 } }

  it "registers an offense for a line that's 81 characters wide" do
    inspect_source(cop, '#' * 81)
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.first.message).to eq('Line is too long. [81/80]')
    expect(cop.config_to_allow_offenses).to eq('Max' => 81)
  end

  it 'highlights excessive characters' do
    inspect_source(cop, '#' * 80 + 'abc')
    expect(cop.highlights).to eq(['abc'])
  end

  it "accepts a line that's 80 characters wide" do
    inspect_source(cop, '#' * 80)
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for long line before __END__ but not after' do
    inspect_source(cop, ['#' * 150,
                         '__END__',
                         '#' * 200])
    expect(cop.messages).to eq(['Line is too long. [150/80]'])
  end

  context 'when AllowURI option is enabled' do
    let(:cop_config) { { 'Max' => 80, 'AllowURI' => true } }

    context 'and all the excessive characters are part of an URL' do
      # This code example is allowed by AllowURI feature itself :).
      let(:source) { <<-END }
        # Some documentation comment...
        # See: https://github.com/bbatsov/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c
      END

      it 'accepts the line' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    context 'and the excessive characters include a complete URL' do
      let(:source) { <<-END }
        # See: http://google.com/, http://gmail.com/, https://maps.google.com/, http://plus.google.com/
      END

      it 'registers an offense for the line' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'highlights all the excessive characters' do
        inspect_source(cop, source)
        expect(cop.highlights).to eq(['http://plus.google.com/'])
      end
    end

    context 'and the excessive characters include part of an URL ' \
            'and another word' do
      let(:source) { <<-END }
        # See: https://github.com/bbatsov/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c and
        #   http://google.com/
      END

      it 'registers an offense for the line' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'highlights only the non-URL part' do
        inspect_source(cop, source)
        expect(cop.highlights).to eq([' and'])
      end
    end

    context 'and an error other than URI::InvalidURIError is raised ' \
            'while validating an URI-ish string' do
      let(:cop_config) do
        { 'Max' => 80, 'AllowURI' => true, 'URISchemes' => %w(LDAP) }
      end

      let(:source) { <<-END }
        xxxxxxxxxxxxxxxxxxxxxxxxxxxxzxxxxxxxxxxx = LDAP::DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY
      END

      it 'does not crash' do
        expect { inspect_source(cop, source) }.not_to raise_error
      end
    end

    context 'and the URL does not have a http(s) scheme' do
      let(:source) { <<-END }
        xxxxxxxxxxxxxxxxxxxxxxxxxxxxzxxxxxxxxxxx = 'otherprotocol://a.very.long.line.which.violates.LineLength/sadf'
      END

      it 'rejects the line' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end

      context 'and the scheme has been configured' do
        let(:cop_config) do
          { 'Max' => 80, 'AllowURI' => true, 'URISchemes' => %w(otherprotocol) }
        end

        it 'accepts the line' do
          inspect_source(cop, source)
          expect(cop.offenses).to be_empty
        end
      end
    end
  end

  context 'when AllowHeredoc option is enabled' do
    let(:cop_config) { { 'Max' => 80, 'AllowHeredoc' => true } }

    let(:source) { <<-END }
      <<-SQL
        SELECT posts.id, posts.title, users.name FROM posts LEFT JOIN users ON posts.user_id = users.id;
      SQL
    END

    it 'accepts long lines in heredocs' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    context 'when the source has no AST' do
      let(:source) { '# this results in AST being nil' }

      it 'does not crash' do
        expect { inspect_source(cop, source) }.not_to raise_error
      end
    end

    context 'and only certain heredoc delimiters are whitelisted' do
      let(:cop_config) do
        { 'Max' => 80, 'AllowHeredoc' => %w(SQL OK) }
      end

      let(:source) { <<-END }
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
      END

      it 'rejects long lines in heredocs with not whitelisted delimiters' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(4)
      end
    end
  end

  context 'when AllowURI option is disabled' do
    let(:cop_config) { { 'Max' => 80, 'AllowURI' => false } }

    context 'and all the excessive characters are part of an URL' do
      let(:source) { <<-END }
        # See: https://github.com/bbatsov/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c
      END

      it 'registers an offense for the line' do
        inspect_source(cop, source)
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
          inspect_source(cop, source)
          expect(cop.offenses.size).to eq(1)
        end

        it 'highlights the excess directive' do
          inspect_source(cop, source)
          expect(cop.highlights).to eq([cop_directive])
        end
      end

      context 'with an inline comment' do
        let(:excess_comment) { ' ###' }
        let(:source) { acceptable_source + excess_comment }

        it 'highlights the excess comment' do
          inspect_source(cop, source)
          expect(cop.highlights).to eq([excess_comment])
        end
      end
    end

    context 'and the source is too long and has a trailing cop directive' do
      let(:excess_with_directive) { 'b # rubocop:disable Metrics/AbcSize' }
      let(:source) { 'a' * 80 + excess_with_directive }

      it 'highlights the excess source and cop directive' do
        inspect_source(cop, source)
        expect(cop.highlights).to eq([excess_with_directive])
      end
    end
  end

  context 'when IgnoreCopDirectives is enabled' do
    let(:cop_config) { { 'Max' => 80, 'IgnoreCopDirectives' => true } }

    context 'and the Rubocop directive is excessively long' do
      let(:source) { <<-END }
        # rubocop:disable Metrics/SomeReallyLongMetricNameThatShouldBeMuchShorterAndNeedsANameChange
      END

      it 'accepts the line' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    context 'and the Rubocop directive causes an excessive line length' do
      let(:source) { <<-END }
        def method_definition_that_is_just_under_the_line_length_limit(foo, bar) # rubocop:disable Metrics/AbcSize
          # complex method
        end
      END

      it 'accepts the line' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end

      context 'and has explanatory text' do
        let(:source) { <<-END }
          def method_definition_that_is_just_under_the_line_length_limit(foo) # rubocop:disable Metrics/AbcSize inherently complex!
            # complex
          end
        END

        it 'accepts the line' do
          inspect_source(cop, source)
          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'and the source is too long' do
      let(:source) { 'a' * 80 + 'bcd' + ' # rubocop:enable Style/ClassVars' }

      it 'registers an offense for the line' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'highlights only the non-directive part' do
        inspect_source(cop, source)
        expect(cop.highlights).to eq(['bcd'])
      end
    end
  end
end
