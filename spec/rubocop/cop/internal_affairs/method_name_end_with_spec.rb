# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::MethodNameEndWith, :config do
  it 'registers an offense if there is potentially usage of `assignment_method?`' do
    expect_offense(<<~RUBY)
      node.method_name.to_s.end_with?('=')
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `assignment_method?` instead of `method_name.to_s.end_with?('=')`.
    RUBY
  end

  it 'registers an offense if `method_name` is a variable and there is potentially usage of `assignment_method?`' do
    expect_offense(<<~RUBY)
      def assignment_method?(method_name)
        method_name.to_s.end_with?('=')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `assignment_method?` instead of `method_name.to_s.end_with?('=')`.
      end
    RUBY
  end

  it 'registers offense if there is potentially usage of `predicate_method?`' do
    expect_offense(<<~RUBY)
      node.method_name.to_s.end_with?('?')
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `predicate_method?` instead of `method_name.to_s.end_with?('?')`.
    RUBY
  end

  it 'registers offense if there is potentially usage of `bang_method?`' do
    expect_offense(<<~RUBY)
      node.method_name.to_s.end_with?('!')
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `bang_method?` instead of `method_name.to_s.end_with?('!')`.
    RUBY
  end

  it 'registers offense if there is potentially usage of `bang_method?` with safe navigation operator' do
    expect_offense(<<~RUBY)
      node.method_name&.to_s&.end_with?('!')
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `bang_method?` instead of `method_name&.to_s&.end_with?('!')`.
    RUBY
  end

  it 'does not register offense if argument for end_with? is some other string' do
    expect_no_offenses(<<~RUBY)
      node.method_name.to_s.end_with?('_foo')
    RUBY
  end

  context 'Ruby >= 2.7', :ruby27 do
    it 'registers an offense if method_name is symbol' do
      expect_offense(<<~RUBY)
        node.method_name.end_with?('=')
             ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `assignment_method?` instead of `method_name.end_with?('=')`.
      RUBY
    end

    it 'registers an offense if method_name is symbol with safe navigation operator' do
      expect_offense(<<~RUBY)
        node&.method_name&.end_with?('=')
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `assignment_method?` instead of `method_name&.end_with?('=')`.
      RUBY
    end

    it 'registers offense if argument for Symbol#end_with? is \'?\'' do
      expect_offense(<<~RUBY)
        node.method_name.end_with?('?')
             ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `predicate_method?` instead of `method_name.end_with?('?')`.
      RUBY
    end

    it 'registers offense if argument for Symbol#end_with? is \'?\' with safe navigation operator' do
      expect_offense(<<~RUBY)
        node.method_name&.end_with?('?')
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `predicate_method?` instead of `method_name&.end_with?('?')`.
      RUBY
    end

    it 'registers offense if argument for Symbol#end_with? is \'!\'' do
      expect_offense(<<~RUBY)
        node.method_name.end_with?('!')
             ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `bang_method?` instead of `method_name.end_with?('!')`.
      RUBY
    end

    it 'registers offense if argument for Symbol#end_with? is \'!\' with safe navigation operator' do
      expect_offense(<<~RUBY)
        node.method_name&.end_with?('!')
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `bang_method?` instead of `method_name&.end_with?('!')`.
      RUBY
    end

    it 'does not register offense if argument for Symbol#end_with? is some other string' do
      expect_no_offenses(<<~RUBY)
        node.method_name.end_with?('_foo')
      RUBY
    end
  end
end
