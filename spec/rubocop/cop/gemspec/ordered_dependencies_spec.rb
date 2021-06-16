# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Gemspec::OrderedDependencies, :config do
  let(:cop_config) { { 'TreatCommentsAsGroupSeparators' => treat_comments_as_group_separators } }
  let(:treat_comments_as_group_separators) { false }

  shared_examples 'ordered dependency' do |add_dependency|
    context "when #{add_dependency}" do
      context 'When gems are alphabetically sorted' do
        it 'does not register any offenses' do
          expect_no_offenses(<<~RUBY)
            Gem::Specification.new do |spec|
              spec.#{add_dependency} 'rspec'
              spec.#{add_dependency} 'rubocop'
            end
          RUBY
        end
      end

      context 'when gems are not alphabetically sorted' do
        it 'registers an offense' do
          expect_offense(<<~RUBY, add_dependency: add_dependency)
            Gem::Specification.new do |spec|
              spec.%{add_dependency} 'rubocop'
              spec.%{add_dependency} 'rspec'
              ^^^^^^{add_dependency}^^^^^^^^ Dependencies should be sorted in an alphabetical order within their section of the gemspec. Dependency `rspec` should appear before `rubocop`.
            end
          RUBY

          expect_correction(<<~RUBY)
            Gem::Specification.new do |spec|
              spec.#{add_dependency} 'rspec'
              spec.#{add_dependency} 'rubocop'
            end
          RUBY
        end
      end

      context 'when each individual group of line is sorted' do
        it 'does not register any offenses' do
          expect_no_offenses(<<~RUBY)
            Gem::Specification.new do |spec|
              spec.#{add_dependency} 'rspec'
              spec.#{add_dependency} 'rubocop'

              spec.#{add_dependency} 'hello'
              spec.#{add_dependency} 'world'
            end
          RUBY
        end
      end

      context 'when dependency is separated by multiline comment' do
        context 'with TreatCommentsAsGroupSeparators: true' do
          let(:treat_comments_as_group_separators) { true }

          it 'accepts' do
            expect_no_offenses(<<~RUBY)
              Gem::Specification.new do |spec|
                # For code quality
                spec.#{add_dependency} 'rubocop'
                # For
                # test
                spec.#{add_dependency} 'rspec'
              end
            RUBY
          end
        end

        context 'with TreatCommentsAsGroupSeparators: false' do
          it 'registers an offense' do
            expect_offense(<<~RUBY, add_dependency: add_dependency)
              Gem::Specification.new do |spec|
                # For code quality
                spec.%{add_dependency} 'rubocop'
                # For
                # test
                spec.%{add_dependency} 'rspec'
                ^^^^^^{add_dependency}^^^^^^^^ Dependencies should be sorted in an alphabetical order within their section of the gemspec. Dependency `rspec` should appear before `rubocop`.
              end
            RUBY

            expect_correction(<<~RUBY)
              Gem::Specification.new do |spec|
                # For
                # test
                spec.#{add_dependency} 'rspec'
                # For code quality
                spec.#{add_dependency} 'rubocop'
              end
            RUBY
          end
        end
      end
    end
  end

  it_behaves_like 'ordered dependency', 'add_dependency'
  it_behaves_like 'ordered dependency', 'add_runtime_dependency'
  it_behaves_like 'ordered dependency', 'add_development_dependency'

  context 'when different dependencies are consecutive' do
    it 'does not register any offenses' do
      expect_no_offenses(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.add_dependency         'rubocop'
          spec.add_runtime_dependency 'rspec'
        end
      RUBY
    end
  end

  context 'When using method call to gem names' do
    it 'does not register any offenses' do
      expect_no_offenses(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.add_dependency         'rubocop'.freeze
          spec.add_runtime_dependency 'rspec'.freeze
        end
      RUBY
    end
  end

  context 'When using a local variable in an argument of dependent gem' do
    it 'does not register any offenses' do
      expect_no_offenses(<<~RUBY)
        Gem::Specification.new do |spec|
          %w(rubocop-performance rubocop-rails).each { |dep| spec.add_dependency dep }
          spec.add_dependency 'parser'
        end
      RUBY
    end
  end
end
