# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::VariableNumber, :config do
  shared_examples 'offense' do |style, variable, style_to_allow_offenses|
    it "registers an offense for #{variable} in #{style}" do
      expect_offense(<<~RUBY, variable: variable)
        #{variable} = 1
        ^{variable} Use #{style} for variable numbers.
      RUBY

      expect(cop.config_to_allow_offenses).to eq(
        { 'EnforcedStyle' => style_to_allow_offenses.to_s }
      )
    end
  end

  shared_examples 'offense_array' do |style, variables|
    it "registers an offense for #{variables} in #{style}" do
      lines = variables.map { |v| "#{v} = 1" }
      lines.insert(1, "^{first_variable} Use #{style} for variable numbers.")

      expect_offense(lines.join("\n"), first_variable: variables.first)

      expect(cop.config_to_allow_offenses).to eq({ 'Enabled' => false })
    end
  end

  shared_examples 'accepts' do |style, variable|
    it "accepts #{variable} in #{style}" do
      expect_no_offenses("#{variable} = 1")
    end
  end

  shared_examples 'accepts integer symbols' do
    it 'accepts integer symbol' do
      expect_no_offenses(':"42"')
    end

    it 'accepts integer symbol array literal' do
      expect_no_offenses('%i[1 2 3]')
    end
  end

  context 'when configured for snake_case' do
    let(:cop_config) { { 'EnforcedStyle' => 'snake_case' } }

    it_behaves_like 'offense', 'snake_case', 'local1', :normalcase
    it_behaves_like 'offense', 'snake_case', '@local1', :normalcase
    it_behaves_like 'offense', 'snake_case', '@@local1', :normalcase
    it_behaves_like 'offense', 'snake_case', 'camelCase1', :normalcase
    it_behaves_like 'offense', 'snake_case', '@camelCase1', :normalcase
    it_behaves_like 'offense', 'snake_case', '_unused1', :normalcase
    it_behaves_like 'offense', 'snake_case', 'aB1', :normalcase
    it_behaves_like 'offense_array', 'snake_case', %w[a1 a_2]

    it_behaves_like 'accepts', 'snake_case', 'local_1'
    it_behaves_like 'accepts', 'snake_case', 'local_12'
    it_behaves_like 'accepts', 'snake_case', 'local_123'
    it_behaves_like 'accepts', 'snake_case', 'local_'
    it_behaves_like 'accepts', 'snake_case', 'aB_1'
    it_behaves_like 'accepts', 'snake_case', 'a_1_b'
    it_behaves_like 'accepts', 'snake_case', 'a_1_b_1'
    it_behaves_like 'accepts', 'snake_case', '_'
    it_behaves_like 'accepts', 'snake_case', '_foo'
    it_behaves_like 'accepts', 'snake_case', '@foo'
    it_behaves_like 'accepts', 'snake_case', '@__foo__'
    it_behaves_like 'accepts', 'snake_case', 'emparejó'
    it_behaves_like 'accepts', 'snake_case', '_1'

    it_behaves_like 'accepts integer symbols'

    it 'registers an offense for normal case numbering in symbol' do
      expect_offense(<<~RUBY)
        :sym1
        ^^^^^ Use snake_case for symbol numbers.
      RUBY
    end

    it 'does not register an offense for snake case numbering in symbol' do
      expect_no_offenses(<<~RUBY)
        :sym_1
      RUBY
    end

    it 'registers an offense for normal case numbering in method parameter' do
      expect_offense(<<~RUBY)
        def method(arg1); end
                   ^^^^ Use snake_case for variable numbers.
      RUBY
    end

    it 'registers an offense for normal case numbering in method camel case parameter' do
      expect_offense(<<~RUBY)
        def method(funnyArg1); end
                   ^^^^^^^^^ Use snake_case for variable numbers.
      RUBY
    end

    it 'registers an offense for normal case numbering in method name' do
      expect_offense(<<~RUBY)
        def method1; end
            ^^^^^^^ Use snake_case for method name numbers.
      RUBY
    end

    it 'registers an offense for normal case numbering in a global variable name' do
      expect_offense(<<~RUBY)
        $arg1 = :foo
        ^^^^^ Use snake_case for variable numbers.
      RUBY
    end
  end

  context 'when configured for normal' do
    let(:cop_config) { { 'EnforcedStyle' => 'normalcase' } }

    it_behaves_like 'offense', 'normalcase', 'local_1', :snake_case
    it_behaves_like 'offense', 'normalcase', 'sha_256', :snake_case
    it_behaves_like 'offense', 'normalcase', '@local_1', :snake_case
    it_behaves_like 'offense', 'normalcase', '@@local_1', :snake_case
    it_behaves_like 'offense', 'normalcase', 'myAttribute_1', :snake_case
    it_behaves_like 'offense', 'normalcase', '@myAttribute_1', :snake_case
    it_behaves_like 'offense', 'normalcase', '_myLocal_1', :snake_case
    it_behaves_like 'offense', 'normalcase', 'localFOO_1', :snake_case
    it_behaves_like 'offense', 'normalcase', 'local_FOO_1', :snake_case
    it_behaves_like 'offense_array', 'normalcase', %w[a_1 a2]

    it_behaves_like 'accepts', 'normalcase', 'local1'
    it_behaves_like 'accepts', 'normalcase', 'local_'
    it_behaves_like 'accepts', 'normalcase', 'user1_id'
    it_behaves_like 'accepts', 'normalcase', 'sha256'
    it_behaves_like 'accepts', 'normalcase', 'foo10_bar'
    it_behaves_like 'accepts', 'normalcase', 'target_u2f_device'
    it_behaves_like 'accepts', 'normalcase', 'localFOO1'
    it_behaves_like 'accepts', 'normalcase', 'snake_case'
    it_behaves_like 'accepts', 'normalcase', 'user_1_id'
    it_behaves_like 'accepts', 'normalcase', '_'
    it_behaves_like 'accepts', 'normalcase', '_foo'
    it_behaves_like 'accepts', 'normalcase', '@foo'
    it_behaves_like 'accepts', 'normalcase', '@__foo__'
    it_behaves_like 'accepts', 'normalcase', 'emparejó'
    it_behaves_like 'accepts', 'normalcase', '_1'

    it_behaves_like 'accepts integer symbols'

    it 'registers an offense for snake case numbering in symbol' do
      expect_offense(<<~RUBY)
        :sym_1
        ^^^^^^ Use normalcase for symbol numbers.
      RUBY
    end

    it 'does not register an offense for normal case numbering in symbol' do
      expect_no_offenses(':sym1')
    end

    it 'registers an offense for snake case numbering in method parameter' do
      expect_offense(<<~RUBY)
        def method(arg_1); end
                   ^^^^^ Use normalcase for variable numbers.
      RUBY
    end

    it 'registers an offense for snake case numbering in method camel case parameter' do
      expect_offense(<<~RUBY)
        def method(funnyArg_1); end
                   ^^^^^^^^^^ Use normalcase for variable numbers.
      RUBY
    end

    it 'registers an offense for snake case numbering in method name' do
      expect_offense(<<~RUBY)
        def method_1; end
            ^^^^^^^^ Use normalcase for method name numbers.
      RUBY
    end

    it 'registers an offense for snake case numbering in a global variable name' do
      expect_offense(<<~RUBY)
        $arg_1 = :foo
        ^^^^^^ Use normalcase for variable numbers.
      RUBY
    end
  end

  context 'when configured for non integer' do
    let(:cop_config) { { 'EnforcedStyle' => 'non_integer' } }

    it_behaves_like 'offense', 'non_integer', 'local_1', :snake_case
    it_behaves_like 'offense', 'non_integer', 'local1', :normalcase
    it_behaves_like 'offense', 'non_integer', '@local_1', :snake_case
    it_behaves_like 'offense', 'non_integer', '@local1', :normalcase
    it_behaves_like 'offense', 'non_integer', 'myAttribute_1', :snake_case
    it_behaves_like 'offense', 'non_integer', 'myAttribute1', :normalcase
    it_behaves_like 'offense', 'non_integer', '@myAttribute_1', :snake_case
    it_behaves_like 'offense', 'non_integer', '@myAttribute1', :normalcase
    it_behaves_like 'offense', 'non_integer', '_myLocal_1', :snake_case
    it_behaves_like 'offense', 'non_integer', '_myLocal1', :normalcase
    it_behaves_like 'offense_array', 'non_integer', %w[a_1 aone]

    it_behaves_like 'accepts', 'non_integer', 'localone'
    it_behaves_like 'accepts', 'non_integer', 'local_one'
    it_behaves_like 'accepts', 'non_integer', 'local_'
    it_behaves_like 'accepts', 'non_integer', '@foo'
    it_behaves_like 'accepts', 'non_integer', '@@foo'
    it_behaves_like 'accepts', 'non_integer', 'fooBar'
    it_behaves_like 'accepts', 'non_integer', '_'
    it_behaves_like 'accepts', 'non_integer', '_foo'
    it_behaves_like 'accepts', 'non_integer', '@__foo__'
    it_behaves_like 'accepts', 'non_integer', 'emparejó'
    it_behaves_like 'accepts', 'non_integer', '_1'

    it_behaves_like 'accepts integer symbols'

    it 'registers an offense for snake case numbering in symbol' do
      expect_offense(<<~RUBY)
        :sym_1
        ^^^^^^ Use non_integer for symbol numbers.
      RUBY
    end

    it 'registers an offense for normal case numbering in symbol' do
      expect_offense(<<~RUBY)
        :sym1
        ^^^^^ Use non_integer for symbol numbers.
      RUBY
    end

    it 'registers an offense for snake case numbering in method parameter' do
      expect_offense(<<~RUBY)
        def method(arg_1); end
                   ^^^^^ Use non_integer for variable numbers.
      RUBY
    end

    it 'registers an offense for normal case numbering in method parameter' do
      expect_offense(<<~RUBY)
        def method(arg1); end
                   ^^^^ Use non_integer for variable numbers.
      RUBY
    end

    it 'registers an offense for snake case numbering in method camel case parameter' do
      expect_offense(<<~RUBY)
        def method(myArg_1); end
                   ^^^^^^^ Use non_integer for variable numbers.
      RUBY
    end

    it 'registers an offense for normal case numbering in method camel case parameter' do
      expect_offense(<<~RUBY)
        def method(myArg1); end
                   ^^^^^^ Use non_integer for variable numbers.
      RUBY
    end

    it 'registers an offense for snake case numbering in method name' do
      expect_offense(<<~RUBY)
        def method_1; end
            ^^^^^^^^ Use non_integer for method name numbers.
      RUBY
    end

    it 'registers an offense for normal case numbering in method name' do
      expect_offense(<<~RUBY)
        def method1; end
            ^^^^^^^ Use non_integer for method name numbers.
      RUBY
    end
  end

  context 'when CheckMethodNames is false' do
    let(:cop_config) { { 'CheckMethodNames' => false, 'EnforcedStyle' => 'normalcase' } }

    it 'does not register an offense for snake case numbering in method name' do
      expect_no_offenses('def method_1; end')
    end
  end

  context 'when CheckSymbols is false' do
    let(:cop_config) { { 'CheckSymbols' => false, 'EnforcedStyle' => 'normalcase' } }

    it 'does not register an offense for snake case numbering in symbol' do
      expect_no_offenses(':sym_1')
    end
  end

  context 'when AllowedIdentifiers is set' do
    let(:cop_config) do
      {
        'AllowedIdentifiers' => %w[capture3],
        'CheckSymbols' => true,
        'CheckMethodNames' => true,
        'EnforcedStyle' => 'snake_case'
      }
    end

    it 'does not register an offense for a local variable name that is allowed' do
      expect_no_offenses(<<~RUBY)
        capture3 = :foo
      RUBY
    end

    it 'does not register an offense for a instance variable name that is allowed' do
      expect_no_offenses(<<~RUBY)
        @capture3 = :foo
      RUBY
    end

    it 'does not register an offense for a class variable name that is allowed' do
      expect_no_offenses(<<~RUBY)
        @@capture3 = :foo
      RUBY
    end

    it 'does not register an offense for a global variable name that is allowed' do
      expect_no_offenses(<<~RUBY)
        $capture3 = :foo
      RUBY
    end

    it 'does not register an offense for a method name that is allowed' do
      expect_no_offenses(<<~RUBY)
        def capture3
        end
      RUBY
    end

    it 'does not register an offense for a symbol that is allowed' do
      expect_no_offenses(':capture3')
    end
  end

  context 'when AllowedPatterns is set' do
    let(:cop_config) do
      {
        'AllowedIdentifiers' => [],
        'AllowedPatterns' => [
          '_v\d+\z',
          'allow_me'
        ],
        'CheckSymbols' => true,
        'CheckMethodNames' => true,
        'EnforcedStyle' => 'snake_case'
      }
    end

    it 'registers an offense for a local variable name that does not match an allowed pattern' do
      expect_offense(<<~RUBY)
        foo_a1 = :foo
        ^^^^^^ Use snake_case for variable numbers.
      RUBY
    end

    it 'does not register an offense for a local variable name that matches an allowed pattern' do
      expect_no_offenses(<<~RUBY)
        foo_v1 = :foo
        foo_allow_me_a1 = :allowed
      RUBY
    end

    it 'registers an offense for a instance variable name that does not match an allowed pattern' do
      expect_offense(<<~RUBY)
        @foo_a1 = :foo
        ^^^^^^^ Use snake_case for variable numbers.
      RUBY
    end

    it 'does not register an offense for a instance variable name that matches an allowed pattern' do
      expect_no_offenses(<<~RUBY)
        @foo_v1 = :foo
        @foo_allow_me_a1 = :allowed
      RUBY
    end

    it 'registers an offense for a class variable name that does not match an allowed pattern' do
      expect_offense(<<~RUBY)
        @@foo_a1 = :foo
        ^^^^^^^^ Use snake_case for variable numbers.
      RUBY
    end

    it 'does not register an offense for a class variable name that matches an allowed pattern' do
      expect_no_offenses(<<~RUBY)
        @@foo_v1 = :foo
        @@foo_allow_me_a1 = :allowed
      RUBY
    end

    it 'registers an offense for a global variable name that does not match an allowed pattern' do
      expect_offense(<<~RUBY)
        $foo_a1 = :foo
        ^^^^^^^ Use snake_case for variable numbers.
      RUBY
    end

    it 'does not register an offense for a global variable name that matches an allowed pattern' do
      expect_no_offenses(<<~RUBY)
        $foo_v1 = :foo
        $foo_allow_me_a1 = :allowed
      RUBY
    end

    it 'registers an offense for a method name that does not match an allowed pattern' do
      expect_offense(<<~RUBY)
        def foo_a1
            ^^^^^^ Use snake_case for method name numbers.
        end
      RUBY
    end

    it 'does not register an offense for a method name that matches an allowed pattern' do
      expect_no_offenses(<<~RUBY)
        def foo_v1
        end

        def foo_allow_me_a1
        end
      RUBY
    end

    it 'registers an offense for a symbol that does not match an allowed pattern' do
      expect_offense(<<~RUBY)
        :foo_a1
        ^^^^^^^ Use snake_case for symbol numbers.
      RUBY
    end

    it 'does not register an offense for a symbol that matches an allowed pattern' do
      expect_no_offenses(':foo_v1')
      expect_no_offenses(':foo_allow_me_a1')
    end
  end
end
