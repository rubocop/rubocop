# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RescueModifier, :config do
  let(:config) { RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 2 }) }

  it 'registers an offense for modifier rescue' do
    expect_offense(<<~RUBY)
      method rescue handle
      ^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
    RUBY

    expect_correction(<<~RUBY)
      begin
        method
      rescue
        handle
      end
    RUBY
  end

  it 'registers an offense when using modifier rescue for method call with heredoc argument' do
    expect_offense(<<~RUBY)
      method(<<~EOS) rescue handle
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
        str
      EOS
    RUBY

    expect_correction(<<~RUBY)
      begin
        method(<<~EOS)
        str
      EOS
      rescue
        handle
      end
    RUBY
  end

  it 'registers an offense when using modifier rescue for safe navigation method call with heredoc argument' do
    expect_offense(<<~RUBY)
      obj&.method(<<~EOS) rescue handle
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
        str
      EOS
    RUBY

    expect_correction(<<~RUBY)
      begin
        obj&.method(<<~EOS)
        str
      EOS
      rescue
        handle
      end
    RUBY
  end

  it 'registers an offense when using modifier rescue for method call with heredoc argument and variable' do
    expect_offense(<<~RUBY)
      method(<<~EOS, var) rescue handle
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
        str
      EOS
    RUBY

    expect_correction(<<~RUBY)
      begin
        method(<<~EOS, var)
        str
      EOS
      rescue
        handle
      end
    RUBY
  end

  it 'registers an offense when using modifier rescue for method call with multiple heredoc arguments' do
    expect_offense(<<~RUBY)
      method(<<~EOS1, <<~EOS2) rescue handle
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
        str1
      EOS1
        str2
      EOS2
    RUBY

    expect_correction(<<~RUBY)
      begin
        method(<<~EOS1, <<~EOS2)
        str1
      EOS1
        str2
      EOS2
      rescue
        handle
      end
    RUBY
  end

  it 'registers an offense for modifier rescue around parallel assignment', :ruby26, unsupported_on: :prism do
    expect_offense(<<~RUBY)
      a, b = 1, 2 rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
    RUBY

    expect_correction(<<~RUBY)
      begin
        a, b = 1, 2
      rescue
        nil
      end
    RUBY
  end

  it 'registers an offense for modifier rescue around parallel assignment', :ruby27 do
    expect_offense(<<~RUBY)
      a, b = 1, 2 rescue nil
             ^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
    RUBY

    expect_correction(<<~RUBY)
      a, b = begin
               [1, 2]
             rescue
               nil
             end
    RUBY
  end

  it 'handles more complex expression with modifier rescue' do
    expect_offense(<<~RUBY)
      method1 or method2 rescue handle
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
    RUBY
  end

  it 'handles modifier rescue in normal rescue' do
    expect_offense(<<~RUBY)
      begin
        test rescue modifier_handle
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
      rescue
        normal_handle
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        begin
          test
        rescue
          modifier_handle
        end
      rescue
        normal_handle
      end
    RUBY
  end

  it 'handles modifier rescue in a method' do
    expect_offense(<<~RUBY)
      def a_method
        test rescue nil
        ^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
      end
    RUBY

    expect_correction(<<~RUBY)
      def a_method
        begin
          test
        rescue
          nil
        end
      end
    RUBY
  end

  it 'handles parentheses around a rescue modifier' do
    expect_offense(<<~RUBY)
      (foo rescue nil)
       ^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
    RUBY

    expect_correction(<<~RUBY)
      begin
        foo
      rescue
        nil
      end
    RUBY
  end

  it 'does not register an offense for normal rescue' do
    expect_no_offenses(<<~RUBY)
      begin
        test
      rescue
        handle
      end
    RUBY
  end

  it 'does not register an offense for normal rescue with ensure' do
    expect_no_offenses(<<~RUBY)
      begin
        test
      rescue
        handle
      ensure
        cleanup
      end
    RUBY
  end

  it 'does not register an offense for nested normal rescue' do
    expect_no_offenses(<<~RUBY)
      begin
        begin
          test
        rescue
          handle_inner
        end
      rescue
        handle_outer
      end
    RUBY
  end

  context 'when an instance method has implicit begin' do
    it 'accepts normal rescue' do
      expect_no_offenses(<<~RUBY)
        def some_method
          test
        rescue
          handle
        end
      RUBY
    end

    it 'handles modifier rescue in body of implicit begin' do
      expect_offense(<<~RUBY)
        def some_method
          test rescue modifier_handle
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
        rescue
          normal_handle
        end
      RUBY
    end
  end

  context 'when a singleton method has implicit begin' do
    it 'accepts normal rescue' do
      expect_no_offenses(<<~RUBY)
        def self.some_method
          test
        rescue
          handle
        end
      RUBY
    end

    it 'handles modifier rescue in body of implicit begin' do
      expect_offense(<<~RUBY)
        def self.some_method
          test rescue modifier_handle
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
        rescue
          normal_handle
        end
      RUBY
    end
  end

  context 'autocorrect' do
    it 'corrects complex rescue modifier' do
      expect_offense(<<~RUBY)
        foo || bar rescue bar
        ^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
      RUBY

      expect_correction(<<~RUBY)
        begin
          foo || bar
        rescue
          bar
        end
      RUBY
    end

    it 'corrects doubled rescue modifiers' do
      expect_offense(<<~RUBY)
        blah rescue 1 rescue 2
        ^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
        ^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
      RUBY

      expect_correction(<<~RUBY)
        begin
          begin
          blah
        rescue
          1
        end
        rescue
          2
        end
      RUBY
    end
  end

  describe 'excluded file', :config do
    let(:config) do
      RuboCop::Config.new('Style/RescueModifier' => { 'Enabled' => true, 'Exclude' => ['**/**'] })
    end

    it 'processes excluded files with issue' do
      expect_no_offenses('foo rescue bar', 'foo.rb')
    end
  end
end
