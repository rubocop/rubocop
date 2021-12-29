# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Gemspec::RequireMFA, :config do
  context 'when the gemspec is blank' do
    it 'does not register an offense' do
      expect_no_offenses('', 'my.gemspec')
    end
  end

  context 'when the specification is blank' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY, 'my.gemspec')
        Gem::Specification.new do |spec|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `metadata['rubygems_mfa_required']` must be set to `'true'`.
        end
      RUBY

      expect_correction(<<~RUBY)
        Gem::Specification.new do |spec|
        spec.metadata['rubygems_mfa_required'] = 'true'
        end
      RUBY
    end
  end

  context 'when the specification has a metadata hash but no rubygems_mfa_required key' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY, 'my.gemspec')
        Gem::Specification.new do |spec|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `metadata['rubygems_mfa_required']` must be set to `'true'`.
          spec.metadata = {
          }
        end
      RUBY

      expect_correction(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.metadata = {
          'rubygems_mfa_required' => 'true'}
        end
      RUBY
    end
  end

  context 'when the specification has an non-hash metadata' do
    it 'registers an offense but does not correct' do
      expect_offense(<<~RUBY, 'my.gemspec')
        Gem::Specification.new do |spec|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `metadata['rubygems_mfa_required']` must be set to `'true'`.
          spec.metadata = Metadata.new
        end
      RUBY
    end
  end

  context 'when there are other metadata keys' do
    context 'and `rubygems_mfa_required` is included' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'my.gemspec')
          Gem::Specification.new do |spec|
            spec.metadata = {
              'foo' => 'bar',
              'rubygems_mfa_required' => 'true',
              'baz' => 'quux'
            }
          end
        RUBY
      end
    end

    context 'and `rubygems_mfa_required` is not included' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY, 'my.gemspec')
          Gem::Specification.new do |spec|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `metadata['rubygems_mfa_required']` must be set to `'true'`.
            spec.metadata = {
              'foo' => 'bar',
              'baz' => 'quux'
            }
          end
        RUBY

        expect_correction(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.metadata = {
              'foo' => 'bar',
              'baz' => 'quux',
          'rubygems_mfa_required' => 'true'
            }
          end
        RUBY
      end
    end
  end

  context 'when metadata is set by key assignment' do
    context 'and `rubygems_mfa_required` is included' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'my.gemspec')
          Gem::Specification.new do |spec|
            spec.metadata['foo'] = 'bar'
            spec.metadata['rubygems_mfa_required'] = 'true'
          end
        RUBY
      end
    end

    context 'and `rubygems_mfa_required` is not included' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, 'my.gemspec')
          Gem::Specification.new do |spec|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `metadata['rubygems_mfa_required']` must be set to `'true'`.
            spec.metadata['foo'] = 'bar'
          end
        RUBY

        expect_correction(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.metadata['foo'] = 'bar'
          spec.metadata['rubygems_mfa_required'] = 'true'
          end
        RUBY
      end
    end
  end

  context 'with rubygems_mfa_required: true' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'my.gemspec')
        Gem::Specification.new do |spec|
          spec.metadata = {
            'rubygems_mfa_required' => 'true'
          }
        end
      RUBY
    end
  end

  context 'with rubygems_mfa_required: false' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY, 'my.gemspec')
        Gem::Specification.new do |spec|
          spec.metadata = {
            'rubygems_mfa_required' => 'false'
                                       ^^^^^^^ `metadata['rubygems_mfa_required']` must be set to `'true'`.
          }
        end
      RUBY

      expect_correction(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.metadata = {
            'rubygems_mfa_required' => 'true'
          }
        end
      RUBY
    end
  end

  context 'with rubygems_mfa_required: false by key access' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY, 'my.gemspec')
        Gem::Specification.new do |spec|
          spec.metadata['rubygems_mfa_required'] = 'false'
                                                   ^^^^^^^ `metadata['rubygems_mfa_required']` must be set to `'true'`.
        end
      RUBY

      expect_correction(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.metadata['rubygems_mfa_required'] = 'true'
        end
      RUBY
    end
  end
end
