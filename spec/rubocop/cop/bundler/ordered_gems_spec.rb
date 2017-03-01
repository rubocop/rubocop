# frozen_string_literal: true

describe RuboCop::Cop::Bundler::OrderedGems, :config do
  subject(:cop) { described_class.new(config) }

  context 'When gems are alphabetically sorted' do
    let(:source) { <<-END }
      gem 'rspec'
      gem 'rubocop'
    END

    it 'does not register any offenses' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'When gems are not alphabetically sorted' do
    let(:source) { <<-END }
      gem 'rubocop'
      gem 'rspec'
    END

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'has the correct offense message' do
      inspect_source(cop, source)
      expect(cop.messages)
        .to eq(['Gems should be sorted in an alphabetical '\
                'order within their section of the Gemfile. '\
                'Gem `rspec` should appear before `rubocop`.'])
    end

    it 'highlights the second gem' do
      inspect_source(cop, source)
      expect(cop.highlights).to eq(["gem 'rspec'"])
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(["      gem 'rspec'",
                                "      gem 'rubocop'",
                                ''].join("\n"))
    end
  end

  context 'When each individual group of line is sorted' do
    let(:source) { <<-END }
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
    let(:source) { <<-END }
      gem 'rubocop',
          '0.1.1'
      gem 'rspec'
    END

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(["      gem 'rspec'",
                                "      gem 'rubocop',",
                                "          '0.1.1'",
                                ''].join("\n"))
    end
  end

  context 'When the gemfile is empty' do
    let(:source) { <<-END }
      # Gemfile
    END

    it 'does not register any offenses' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(0)
    end
  end

  context 'When each individual group of line is not sorted' do
    let(:source) { <<-END }
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
      inspect_source(cop, source)
      expect(cop.offenses).not_to be_empty
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(['        gem "a"',
                                '        gem "b"',
                                '        gem "c"',
                                '        gem "d"',
                                '        gem "e"',
                                '',
                                '        gem "f"',
                                '        gem "g"',
                                '        gem "h"',
                                '        gem "i"',
                                '        gem "j"',
                                ''].join("\n"))
    end
  end

  context 'When gem groups is separated by comment' do
    let(:source) { <<-END }
      # For code quality
      gem 'rubocop'
      # For test
      gem 'rspec'
    END

    it 'accepts' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'When gems have an inline comment, and not sorted' do
    let(:source) { <<-END }
      gem 'rubocop' # For code quality
      gem 'pry'
      gem 'rspec'   # For test
    END

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(["      gem 'pry'",
                                "      gem 'rspec'   # For test",
                                "      gem 'rubocop' # For code quality",
                                ''].join("\n"))
    end
  end

  context 'When gems are asciibetically sorted' do
    let(:source) { <<-END }
      gem 'paper_trail'
      gem 'paperclip'
    END

    it 'does not register an offense' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'When a gem that starts with a capital letter is sorted' do
    let(:source) { <<-END }
      gem 'a'
      gem 'Z'
    END

    it 'does not register an offense' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'When a gem that starts with a capital letter is not sorted' do
    let(:source) { <<-END }
      gem 'Z'
      gem 'a'
    END

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(["      gem 'a'",
                                "      gem 'Z'",
                                ''].join("\n"))
    end
  end
end
