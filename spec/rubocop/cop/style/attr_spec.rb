# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Attr do
  subject(:cop) { described_class.new }

  it 'registers an offense attr' do
    expect_offense(<<~RUBY)
      class SomeClass
        attr :name
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      end
    RUBY
  end

  it 'registers offense for attr within class_eval' do
    expect_offense(<<~RUBY)
      SomeClass.class_eval do
        attr :name
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      end
    RUBY
  end

  it 'registers offense for attr within module_eval' do
    expect_offense(<<~RUBY)
      SomeClass.module_eval do
        attr :name
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      end
    RUBY
  end

  it 'accepts attr when it does not take arguments' do
    expect_no_offenses('func(attr)')
  end

  it 'accepts attr when it has a receiver' do
    expect_no_offenses('x.attr arg')
  end

  it 'does not register offense for custom `attr` method' do
    expect_no_offenses(<<~RUBY)
      class SomeClass
        def attr(*args)
          p args
        end

        def a
          attr(1)
        end
      end
    RUBY
  end

  context 'auto-corrects' do
    it 'attr to attr_reader' do
      new_source = autocorrect_source('attr :name')
      expect(new_source).to eq('attr_reader :name')
    end

    it 'attr, false to attr_reader' do
      new_source = autocorrect_source('attr :name, false')
      expect(new_source).to eq('attr_reader :name')
    end

    it 'attr :name, true to attr_accessor :name' do
      new_source = autocorrect_source('attr :name, true')
      expect(new_source).to eq('attr_accessor :name')
    end

    it 'attr with multiple names to attr_reader' do
      new_source = autocorrect_source('attr :foo, :bar')
      expect(new_source).to eq('attr_reader :foo, :bar')
    end
  end

  context 'offense message' do
    it 'for attr :name suggests to use attr_reader' do
      expect_offense(<<~RUBY)
        attr :foo
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      RUBY
    end

    it 'for attr :name, false suggests to use attr_reader' do
      expect_offense(<<~RUBY)
        attr :foo, false
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      RUBY
    end

    it 'for attr :name, true suggests to use attr_accessor' do
      expect_offense(<<~RUBY)
        attr :foo, true
        ^^^^ Do not use `attr`. Use `attr_accessor` instead.
      RUBY
    end

    it 'for attr with multiple names suggests to use attr_reader' do
      expect_offense(<<~RUBY)
        attr :foo, :bar
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      RUBY
    end
  end
end
