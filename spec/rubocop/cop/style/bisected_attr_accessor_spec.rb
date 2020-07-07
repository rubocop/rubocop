# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::BisectedAttrAccessor do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects when both accessors of the name exists' do
    expect_offense(<<~RUBY)
      class Foo
        attr_reader :bar
                    ^^^^ Combine both accessors into `attr_accessor :bar`.
        attr_writer :bar
                    ^^^^ Combine both accessors into `attr_accessor :bar`.
        other_macro :something
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_accessor :bar
        
        other_macro :something
      end
    RUBY
  end

  it 'registers an offense and corrects when attr and attr_writer exists' do
    expect_offense(<<~RUBY)
      class Foo
        attr :bar
             ^^^^ Combine both accessors into `attr_accessor :bar`.
        attr_writer :bar
                    ^^^^ Combine both accessors into `attr_accessor :bar`.
        other_macro :something
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_accessor :bar
        
        other_macro :something
      end
    RUBY
  end

  it 'registers an offense and corrects when both accessors of the splat exists' do
    expect_offense(<<~RUBY)
      class Foo
        ATTRIBUTES = %i[foo bar]
        attr_reader *ATTRIBUTES
                    ^^^^^^^^^^^ Combine both accessors into `attr_accessor *ATTRIBUTES`.
        attr_writer *ATTRIBUTES
                    ^^^^^^^^^^^ Combine both accessors into `attr_accessor *ATTRIBUTES`.
        other_macro :something
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        ATTRIBUTES = %i[foo bar]
        attr_accessor *ATTRIBUTES
        
        other_macro :something
      end
    RUBY
  end

  it 'registers an offense and corrects when both accessors of the name exists and accessor contains multiple names' do
    expect_offense(<<~RUBY)
      class Foo
        attr_reader :baz, :bar, :quux
                          ^^^^ Combine both accessors into `attr_accessor :bar`.
        attr_writer :bar, :zoo
                    ^^^^ Combine both accessors into `attr_accessor :bar`.
        other_macro :something
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_accessor :bar
        attr_reader :baz, :quux
        attr_writer :zoo
        other_macro :something
      end
    RUBY
  end

  it 'does not register an offense when only one accessor of the name exists' do
    expect_no_offenses(<<~RUBY)
      class Foo
        attr_reader :bar
        attr_writer :baz
      end
    RUBY
  end

  it 'does not register an offense when using `attr_accessor`' do
    expect_no_offenses(<<~RUBY)
      class Foo
        attr_accessor :bar
      end
    RUBY
  end
end
