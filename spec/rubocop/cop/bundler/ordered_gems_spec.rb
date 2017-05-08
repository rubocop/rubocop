# frozen_string_literal: true

describe RuboCop::Cop::Bundler::OrderedGems, :config do
  let(:cop_config) do
    {
      'TreatCommentsAsGroupSeparators' => treat_comments_as_group_separators,
      'Include' => nil
    }
  end
  let(:treat_comments_as_group_separators) { false }
  let(:message) do
    'Gems should be sorted in an alphabetical order within their ' \
      'section of the Gemfile. Gem `%s` should appear before `%s`.'
  end
  subject(:cop) { described_class.new(config) }

  context 'When gems are alphabetically sorted' do
    let(:source) { <<-END.strip_indent }
      gem 'rspec'
      gem 'rubocop'
    END

    it 'does not register any offenses' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'When gems are not alphabetically sorted' do
    let(:source) { <<-END.strip_indent }
      gem 'rubocop'
      gem 'rspec'
    END

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        gem 'rubocop'
        gem 'rspec'
        ^^^^^^^^^^^ #{format(message, 'rspec', 'rubocop')}
      RUBY
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(<<-END.strip_indent)
        gem 'rspec'
        gem 'rubocop'
      END
    end
  end

  context 'When each individual group of line is sorted' do
    let(:source) { <<-END.strip_indent }
      gem 'rspec'
      gem 'rubocop'

      gem 'hello'
      gem 'world'
    END

    it 'does not register any offenses' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'When a gem declaration takes several lines' do
    let(:source) { <<-END.strip_indent }
      gem 'rubocop',
          '0.1.1'
      gem 'rspec'
    END

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        gem 'rubocop',
            '0.1.1'
        gem 'rspec'
        ^^^^^^^^^^^ #{format(message, 'rspec', 'rubocop')}
      RUBY
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(<<-END.strip_indent)
        gem 'rspec'
        gem 'rubocop',
            '0.1.1'
      END
    end
  end

  context 'When the gemfile is empty' do
    let(:source) { <<-END.strip_indent }
      # Gemfile
    END

    it 'does not register any offenses' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(0)
    end
  end

  context 'When each individual group of line is not sorted' do
    let(:source) { <<-END.strip_indent }
        gem "d"
        gem "b"
        gem "e"
        gem "a"
        gem "c"

        gem "h"
        gem "g"
        gem "j"
        gem "f"
        gem "i"
    END

    it 'registers some offenses' do
      expect_offense(<<-RUBY.strip_indent)
        gem "d"
        gem "b"
        ^^^^^^^ #{format(message, 'b', 'd')}
        gem "e"
        gem "a"
        ^^^^^^^ #{format(message, 'a', 'e')}
        gem "c"

        gem "h"
        gem "g"
        ^^^^^^^ #{format(message, 'g', 'h')}
        gem "j"
        gem "f"
        ^^^^^^^ #{format(message, 'f', 'j')}
        gem "i"
      RUBY
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(<<-END.strip_indent)
        gem "a"
        gem "b"
        gem "c"
        gem "d"
        gem "e"

        gem "f"
        gem "g"
        gem "h"
        gem "i"
        gem "j"
      END
    end
  end

  context 'When gem groups is separated by multiline comment' do
    let(:source) { <<-END.strip_indent }
      # For code quality
      gem 'rubocop'
      # For
      # test
      gem 'rspec'
    END

    context 'with TreatCommentsAsGroupSeparators: true' do
      let(:treat_comments_as_group_separators) { true }

      it 'accepts' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    context 'with TreatCommentsAsGroupSeparators: false' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          # For code quality
          gem 'rubocop'
          # For
          # test
          gem 'rspec'
          ^^^^^^^^^^^ #{format(message, 'rspec', 'rubocop')}
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source_with_loop(cop, source)
        expect(new_source).to eq(<<-END.strip_indent)
          # For
          # test
          gem 'rspec'
          # For code quality
          gem 'rubocop'
        END
      end
    end
  end

  context 'When gems have an inline comment, and not sorted' do
    let(:source) { <<-END.strip_indent }
      gem 'rubocop' # For code quality
      gem 'pry'
      gem 'rspec'   # For test
    END

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        gem 'rubocop' # For code quality
        gem 'pry'
        ^^^^^^^^^ #{format(message, 'pry', 'rubocop')}
        gem 'rspec'   # For test
      RUBY
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(<<-END.strip_indent)
        gem 'pry'
        gem 'rspec'   # For test
        gem 'rubocop' # For code quality
      END
    end
  end

  context 'When gems are asciibetically sorted' do
    let(:source) { <<-END.strip_indent }
      gem 'paper_trail'
      gem 'paperclip'
    END

    it 'does not register an offense' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'When a gem that starts with a capital letter is sorted' do
    let(:source) { <<-END.strip_indent }
      gem 'a'
      gem 'Z'
    END

    it 'does not register an offense' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'When a gem that starts with a capital letter is not sorted' do
    let(:source) { <<-END.strip_indent }
      gem 'Z'
      gem 'a'
    END

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        gem 'Z'
        gem 'a'
        ^^^^^^^ #{format(message, 'a', 'Z')}
      RUBY
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(<<-END.strip_indent)
        gem 'a'
        gem 'Z'
      END
    end
  end
end
