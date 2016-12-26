# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Bundler::DuplicatedGem, :config do
  let(:cop_config) { { 'Include' => ['**/Gemfile'] } }
  subject(:cop) { described_class.new(config) }

  context 'when investigating Ruby files' do
    let(:source) { <<-END }
      # cop will not read these contents
      gem('rubocop')
      gem('rubocop')
    END

    it 'does not register any offenses' do
      inspect_source_file(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'when investigating Gemfiles' do
    context 'and the file is empty' do
      let(:source) { '' }

      it 'does not raise an error' do
        expect { inspect_source(cop, source, 'gems.rb') }.not_to raise_error
      end

      it 'does not register any offenses' do
        expect(cop.offenses).to be_empty
      end
    end

    context 'and no duplicate gems are present' do
      let(:source) { <<-GEM }
        gem 'rubocop'
        gem 'flog'
      GEM

      it 'does not register any offenses' do
        inspect_gemfile(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    context 'and a gem is duplicated in default group' do
      let(:source) { <<-GEM }
        source 'https://rubygems.org'
        gem 'rubocop'
        gem 'rubocop'
      GEM

      it 'registers an offense' do
        inspect_gemfile(cop, source)
        expect(cop.offenses.size).to eq(1)
      end

      it "references gem's first occurance in message" do
        inspect_gemfile(cop, source)
        expect(cop.offenses.first.message).to include('2')
      end

      it 'highlights the duplicate gem' do
        inspect_gemfile(cop, source)
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
        inspect_gemfile(cop, source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'highlights the duplicate gem' do
        inspect_gemfile(cop, source)
        expect(cop.highlights).to eq(["gem 'rubocop', path: '/path/to/gem'"])
      end
    end

    context 'and same gems have different version specifications' do
      let(:source) { <<-END }
        if RUBY_VERSION < '2.2.5'
          gem 'beaker', '~> 2.0', require: false
          gem 'beaker-rspec', '~> 5.0', require: false
        else
          gem 'beaker-rspec', require: false
        end
      END

      it 'does not register any offenses' do
        inspect_gemfile(cop, source)
        expect(cop.offenses).to be_empty
      end
    end
  end
end
