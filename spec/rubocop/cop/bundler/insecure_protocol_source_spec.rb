# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Bundler::InsecureProtocolSource, :config do
  it 'registers an offense when using `source :gemcutter`' do
    expect_offense(<<~RUBY)
      source :gemcutter
             ^^^^^^^^^^ The source `:gemcutter` is deprecated [...]
    RUBY

    expect_correction(<<~RUBY)
      source 'https://rubygems.org'
    RUBY
  end

  it 'registers an offense when using `source :rubygems`' do
    expect_offense(<<~RUBY)
      source :rubygems
             ^^^^^^^^^ The source `:rubygems` is deprecated [...]
    RUBY

    expect_correction(<<~RUBY)
      source 'https://rubygems.org'
    RUBY
  end

  it 'registers an offense when using `source :rubyforge`' do
    expect_offense(<<~RUBY)
      source :rubyforge
             ^^^^^^^^^^ The source `:rubyforge` is deprecated [...]
    RUBY

    expect_correction(<<~RUBY)
      source 'https://rubygems.org'
    RUBY
  end

  it "does not register an offense when using `source 'https://rubygems.org'`" do
    expect_no_offenses(<<~RUBY)
      source 'https://rubygems.org'
    RUBY
  end

  context 'when `AllowHttpProtocol: true`' do
    let(:cop_config) { { 'AllowHttpProtocol' => true } }

    it "does not register an offense when using `source 'http://rubygems.org'`" do
      expect_no_offenses(<<~RUBY)
        source 'http://rubygems.org'
      RUBY
    end
  end

  context 'when `AllowHttpProtocol: false`' do
    let(:cop_config) { { 'AllowHttpProtocol' => false } }

    it "registers an offense when using `source 'http://rubygems.org'`" do
      expect_offense(<<~RUBY)
        source 'http://rubygems.org'
               ^^^^^^^^^^^^^^^^^^^^^ Use `https://rubygems.org` instead of `http://rubygems.org`.
      RUBY

      expect_correction(<<~RUBY)
        source 'https://rubygems.org'
      RUBY
    end
  end
end
