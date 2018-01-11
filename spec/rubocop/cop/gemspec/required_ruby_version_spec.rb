# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Gemspec::RequiredRubyVersion, :config do
  subject(:cop) { described_class.new(config) }

  context 'target ruby version > 2.4', :ruby24 do
    it 'registers an offense when `required_ruby_version` is lower than ' \
       '`TargetRubyVersion`' do
      expect_offense(<<-RUBY.strip_indent, '/path/to/foo.gemspec')
        Gem::Specification.new do |spec|
          spec.required_ruby_version = '>= 2.3.0'
                                       ^^^^^^^^^^ `required_ruby_version` (2.3, declared in foo.gemspec) and `TargetRubyVersion` (2.4, which may be specified in .rubocop.yml) should be equal.
        end
      RUBY
    end

    describe 'false negatives' do
      it 'does not register an offense when `required_ruby_version` ' \
         'is assigned as a variable (string literal)' do
        expect_no_offenses(<<-RUBY.strip_indent)
          Gem::Specification.new do |spec|
            version = '>= 2.3.0'
            spec.required_ruby_version = version
          end
        RUBY
      end

      it 'does not register an offense when `required_ruby_version` ' \
         'is assigned as a variable (an array of string literal)' do
        expect_no_offenses(<<-RUBY.strip_indent)
          Gem::Specification.new do |spec|
            lowest_version = '>= 2.3.0'
            highest_version = '< 2.5.0'
            spec.required_ruby_version = [lowest_version, highest_version]
          end
        RUBY
      end
    end
  end

  context 'target ruby version > 2.2', :ruby22 do
    it 'registers an offense when `required_ruby_version` is higher than ' \
       '`TargetRubyVersion`' do
      expect_offense(<<-RUBY.strip_indent, '/path/to/bar.gemspec')
        Gem::Specification.new do |spec|
          spec.required_ruby_version = '>= 2.3.0'
                                       ^^^^^^^^^^ `required_ruby_version` (2.3, declared in bar.gemspec) and `TargetRubyVersion` (2.2, which may be specified in .rubocop.yml) should be equal.
        end
      RUBY
    end
  end

  context 'target ruby version > 2.3', :ruby23 do
    it 'does not register an offense when `required_ruby_version` equals ' \
       '`TargetRubyVersion`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        Gem::Specification.new do |spec|
          spec.required_ruby_version = '>= 2.3.0'
        end
      RUBY
    end

    it 'does not register an offense when `required_ruby_version` ' \
       '(omit patch version) equals `TargetRubyVersion`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        Gem::Specification.new do |spec|
          spec.required_ruby_version = '>= 2.3'
        end
      RUBY
    end

    it 'does not register an offense when lowest version of ' \
       '`required_ruby_version` equals `TargetRubyVersion`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        Gem::Specification.new do |spec|
          spec.required_ruby_version = ['>= 2.3.0', '< 2.5.0']
        end
      RUBY
    end
  end
end
