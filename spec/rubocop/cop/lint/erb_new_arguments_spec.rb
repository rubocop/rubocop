# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ErbNewArguments, :config do
  subject(:cop) { described_class.new(config) }

  context '<= Ruby 2.5', :ruby25 do
    it 'does not register an offense when using `ERB.new` ' \
       'with non-keyword arguments' do
      expect_no_offenses(<<-RUBY.strip_indent)
        ERB.new(str, nil, '-', '@output_buffer')
      RUBY
    end
  end

  context '>= Ruby 2.6', :ruby26 do
    it 'registers an offense when using `ERB.new` ' \
       'with non-keyword 2nd argument' do
      expect_offense(<<-RUBY.strip_indent)
        ERB.new(str, nil)
                     ^^^ Passing safe_level with the 2nd argument of `ERB.new` is deprecated. Do not use it, and specify other arguments as keyword arguments.
      RUBY
    end

    it 'registers an offense when using `ERB.new` ' \
       'with non-keyword 2nd and 3rd arguments' do
      expect_offense(<<-RUBY.strip_indent)
        ERB.new(str, nil, '-')
                          ^^^ Passing trim_mode with the 3rd argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, trim_mode: '-')` instead.
                     ^^^ Passing safe_level with the 2nd argument of `ERB.new` is deprecated. Do not use it, and specify other arguments as keyword arguments.
      RUBY
    end

    it 'registers an offense when using `ERB.new` ' \
       'with non-keyword 2nd, 3rd and 4th arguments' do
      expect_offense(<<-RUBY.strip_indent)
        ERB.new(str, nil, '-', '@output_buffer')
                               ^^^^^^^^^^^^^^^^ Passing eoutvar with the 4th argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, eoutvar: '@output_buffer')` instead.
                          ^^^ Passing trim_mode with the 3rd argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, trim_mode: '-')` instead.
                     ^^^ Passing safe_level with the 2nd argument of `ERB.new` is deprecated. Do not use it, and specify other arguments as keyword arguments.
      RUBY
    end

    it 'registers an offense when using `ERB.new` ' \
       'with non-keyword 2nd, 3rd and 4th arguments and' \
       'keyword 5th argument' do
      expect_offense(<<-RUBY.strip_indent)
        ERB.new(str, nil, '-', '@output_buffer', trim_mode: '-', eoutvar: '@output_buffer')
                               ^^^^^^^^^^^^^^^^ Passing eoutvar with the 4th argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, eoutvar: '@output_buffer')` instead.
                          ^^^ Passing trim_mode with the 3rd argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, trim_mode: '-')` instead.
                     ^^^ Passing safe_level with the 2nd argument of `ERB.new` is deprecated. Do not use it, and specify other arguments as keyword arguments.
      RUBY
    end

    it 'registers an offense when using `ERB.new` ' \
       'with non-keyword 2nd and 3rd arguments and' \
       'keyword 4th argument' do
      expect_offense(<<-RUBY.strip_indent)
        ERB.new(str, nil, '-', trim_mode: '-', eoutvar: '@output_buffer')
                          ^^^ Passing trim_mode with the 3rd argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, trim_mode: '-')` instead.
                     ^^^ Passing safe_level with the 2nd argument of `ERB.new` is deprecated. Do not use it, and specify other arguments as keyword arguments.
      RUBY
    end

    it 'registers an offense when using `::ERB.new` ' \
       'with non-keyword 2nd, 3rd and 4th arguments' do
      expect_offense(<<-RUBY.strip_indent)
        ::ERB.new(str, nil, '-', '@output_buffer')
                                 ^^^^^^^^^^^^^^^^ Passing eoutvar with the 4th argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, eoutvar: '@output_buffer')` instead.
                            ^^^ Passing trim_mode with the 3rd argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, trim_mode: '-')` instead.
                       ^^^ Passing safe_level with the 2nd argument of `ERB.new` is deprecated. Do not use it, and specify other arguments as keyword arguments.
      RUBY
    end

    it 'does not register an offense when using `ERB.new` ' \
       'with keyword arguments' do
      expect_no_offenses(<<-RUBY.strip_indent)
        ERB.new(str, trim_mode: '-', eoutvar: '@output_buffer')
      RUBY
    end

    it 'does not register an offense when using `ERB.new` ' \
       'without optional arguments' do
      expect_no_offenses(<<-RUBY.strip_indent)
        ERB.new(str)
      RUBY
    end
  end
end
