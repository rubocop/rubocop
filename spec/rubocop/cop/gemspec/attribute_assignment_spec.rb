# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Gemspec::AttributeAssignment, :config do
  it 'does not register an offense when only indexed hash assignment is used' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.metadata['key-0'] = 'value-0'
        spec.metadata['key-1'] = 'value-1'
      end
    RUBY
  end

  it 'does not register an offense when only normal hash assignment is used' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.metadata = { 'key' => 'value' }
        spec.metadata = { 'key' => 'value' }
      end
    RUBY
  end

  it 'does not register an offense when only indexed array assignment is used' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.authors[0] = 'author-0'
        spec.authors[1] = 'author-1'
      end
    RUBY
  end

  it 'does not register an offense when only normal array assignment is used' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.authors = %w[author-1 author-2]
        spec.authors = %w[author-1 author-2]
      end
    RUBY
  end

  it 'registers an offense for inconsistent hash assignment' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.metadata = { 'key-0' => 'value-0' }
        spec.metadata['key-1'] = 'value-1'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use consistent style for Gemspec attributes assignment.
        spec.metadata['key-2'] = 'value-2'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use consistent style for Gemspec attributes assignment.
      end
    RUBY
  end

  it 'registers an offense for inconsistent array assignment' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.authors = %w[author-0 author-1]
        spec.authors[2] = 'author-2'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use consistent style for Gemspec attributes assignment.
      end
    RUBY
  end

  context 'when the gemspec is blank' do
    it 'does not register an offense' do
      expect_no_offenses('', 'my.gemspec')
    end
  end
end
