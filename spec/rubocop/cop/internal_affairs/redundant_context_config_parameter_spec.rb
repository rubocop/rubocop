# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::RedundantContextConfigParameter, :config do
  it 'registers an offense when using `:config` parameter' do
    expect_offense(<<~RUBY)
      context 'foo', :config do
                     ^^^^^^^ Remove the redundant `:config` parameter.
      end
    RUBY

    expect_correction(<<~RUBY)
      context 'foo' do
      end
    RUBY
  end

  it 'registers an offense when using `:config` parameter with other parameters' do
    expect_offense(<<~RUBY)
      context 'foo', :ruby30, :rails70, :config do
                                        ^^^^^^^ Remove the redundant `:config` parameter.
      end
    RUBY

    expect_correction(<<~RUBY)
      context 'foo', :ruby30, :rails70 do
      end
    RUBY
  end

  it 'does not register an offense when not using `:config`' do
    expect_no_offenses(<<~RUBY)
      context 'foo' do
      end
    RUBY
  end

  it 'does not register an offense when using `:ruby30` only' do
    expect_no_offenses(<<~RUBY)
      context 'foo', :ruby30 do
      end
    RUBY
  end

  it 'does not register an offense when using `:config` in other than `context`' do
    expect_no_offenses(<<~RUBY)
      shared_context 'foo', :config do
      end
    RUBY
  end
end
