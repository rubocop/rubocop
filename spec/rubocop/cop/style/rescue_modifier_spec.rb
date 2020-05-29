# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RescueModifier do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Layout/IndentationWidth' => {
                          'Width' => 2
                        })
  end

  it 'registers an offense for modifier rescue' do
    expect_offense(<<~RUBY)
      method rescue handle
      ^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
    RUBY
  end

  it 'registers an offense for modifier rescue around parallel assignment' do
    expect_offense(<<~RUBY)
      a, b = 1, 2 rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
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
  end

  it 'handles modifier rescue in a method' do
    expect_offense(<<~RUBY)
      def a_method
        test rescue nil
        ^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
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
    it 'corrects basic rescue modifier' do
      new_source = autocorrect_source(<<~RUBY)
        foo rescue bar
      RUBY

      expect(new_source).to eq(<<~RUBY)
        begin
          foo
        rescue
          bar
        end
      RUBY
    end

    it 'corrects complex rescue modifier' do
      new_source = autocorrect_source(<<~RUBY)
        foo || bar rescue bar
      RUBY

      expect(new_source).to eq(<<~RUBY)
        begin
          foo || bar
        rescue
          bar
        end
      RUBY
    end

    it 'corrects rescue modifier nested inside of def' do
      source = <<~RUBY
        def foo
          test rescue modifier_handle
        end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<~RUBY)
        def foo
          begin
            test
          rescue
            modifier_handle
          end
        end
      RUBY
    end

    it 'corrects nested rescue modifier' do
      source = <<~RUBY
        begin
          test rescue modifier_handle
        rescue
          normal_handle
        end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<~RUBY)
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

    it 'corrects doubled rescue modifiers' do
      expect_offense(<<~RUBY)
        blah rescue 1 rescue 2
        ^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
        ^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
      RUBY

      expect_correction(<<~RUBY, loop: true)
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

  describe 'excluded file' do
    subject(:cop) { described_class.new(config) }

    let(:config) do
      RuboCop::Config.new('Style/RescueModifier' =>
                          { 'Enabled' => true,
                            'Exclude' => ['**/**'] })
    end

    it 'processes excluded files with issue' do
      expect_no_offenses('foo rescue bar', 'foo.rb')
    end
  end
end
