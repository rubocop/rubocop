# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::AccessorGrouping, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is grouped' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'grouped' }
    end

    it 'registers an offense and corrects when using separated accessors' do
      expect_offense(<<~RUBY)
        class Foo
          attr_reader :bar1
          ^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.
          attr_reader :bar2
          ^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.
          attr_accessor :quux
          attr_reader :bar3, :bar4
          ^^^^^^^^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.
          other_macro :zoo
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          attr_reader :bar1, :bar2, :bar3, :bar4
          
          attr_accessor :quux
          
          other_macro :zoo
        end
      RUBY
    end

    it 'does not register an offense when using grouped accessors' do
      expect_no_offenses(<<~RUBY)
        class Foo
          attr_reader :bar, :baz
        end
      RUBY
    end
  end

  context 'when EnforcedStyle is separated' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'separated' }
    end

    it 'registers an offense and corrects when using grouped accessors' do
      expect_offense(<<~RUBY)
        class Foo
          attr_reader :bar, :baz
          ^^^^^^^^^^^^^^^^^^^^^^ Use one attribute per `attr_reader`.
          attr_accessor :quux
          other_macro :zoo, :woo
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          attr_reader :bar
          attr_reader :baz
          attr_accessor :quux
          other_macro :zoo, :woo
        end
      RUBY
    end

    it 'does not register an offense when using separated accessors' do
      expect_no_offenses(<<~RUBY)
        class Foo
          attr_reader :bar
          attr_reader :baz
        end
      RUBY
    end
  end
end
