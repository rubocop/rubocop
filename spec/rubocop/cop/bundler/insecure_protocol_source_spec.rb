# frozen_string_literal: true

describe RuboCop::Cop::Bundler::InsecureProtocolSource do
  let(:config) { RuboCop::Config.new }

  subject(:cop) { described_class.new(config) }

  it 'registers an offense when using `source :gemcutter`' do
    expect_offense(<<-RUBY.strip_indent)
      source :gemcutter
             ^^^^^^^^^^ The source `:gemcutter` is deprecated because HTTP requests are insecure. Please change your source to 'https://rubygems.org' if possible, or 'http://rubygems.org' if not.
    RUBY
  end

  it 'registers an offense when using `source :rubygems`' do
    expect_offense(<<-RUBY.strip_indent)
      source :rubygems
             ^^^^^^^^^ The source `:rubygems` is deprecated because HTTP requests are insecure. Please change your source to 'https://rubygems.org' if possible, or 'http://rubygems.org' if not.
    RUBY
  end

  it 'registers an offense when using `source :rubyforge`' do
    expect_offense(<<-RUBY.strip_indent)
      source :rubyforge
             ^^^^^^^^^^ The source `:rubyforge` is deprecated because HTTP requests are insecure. Please change your source to 'https://rubygems.org' if possible, or 'http://rubygems.org' if not.
    RUBY
  end

  it 'autocorrects `source :gemcutter`' do
    new_source = autocorrect_source('source :gemcutter')

    expect(new_source).to eq "source 'https://rubygems.org'"
  end

  it 'autocorrects `source :rubygems`' do
    new_source = autocorrect_source('source :rubygems')

    expect(new_source).to eq "source 'https://rubygems.org'"
  end

  it 'autocorrects `source :rubyforge`' do
    new_source = autocorrect_source('source :rubyforge')

    expect(new_source).to eq "source 'https://rubygems.org'"
  end
end
