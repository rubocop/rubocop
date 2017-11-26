# frozen_string_literal: true

describe RuboCop::Cop::Bundler::DuplicatedGem, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'Include' => ['**/Gemfile'] } }

  context 'when investigating Ruby files' do
    it 'does not register any offenses' do
      expect_no_offenses(<<-RUBY.strip_indent)
        # cop will not read these contents
        gem('rubocop')
        gem('rubocop')
      RUBY
    end
  end

  context 'when investigating Gemfiles' do
    context 'and the file is empty' do
      let(:source) { '' }

      it 'does not raise an error' do
        expect { inspect_source('gems.rb') }.not_to raise_error
      end

      it 'does not register any offenses' do
        expect(cop.offenses.empty?).to be(true)
      end
    end

    context 'and no duplicate gems are present' do
      it 'does not register any offenses' do
        expect_no_offenses(<<-RUBY.strip_indent, 'Gemfile')
          gem 'rubocop'
          gem 'flog'
        RUBY
      end
    end

    context 'and a gem is duplicated in default group' do
      let(:source) { <<-GEM }
        source 'https://rubygems.org'
        gem 'rubocop'
        gem 'rubocop'
      GEM

      it 'registers an offense' do
        inspect_gemfile(source)
        expect(cop.offenses.size).to eq(1)
      end

      it "references gem's first occurrence in message" do
        inspect_gemfile(source)
        expect(cop.offenses.first.message).to include('2')
      end

      it 'highlights the duplicate gem' do
        inspect_gemfile(source)
        expect(cop.highlights).to eq(["gem 'rubocop'"])
      end
    end

    context 'and a duplicated gem is in a git/path/group/platforms block' do
      let(:source) { <<-GEM }
        gem 'rubocop'
        group :development do
          gem 'rubocop', path: '/path/to/gem'
        end
      GEM

      it 'registers an offense' do
        inspect_gemfile(source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'highlights the duplicate gem' do
        inspect_gemfile(source)
        expect(cop.highlights).to eq(["gem 'rubocop', path: '/path/to/gem'"])
      end
    end
  end
end
