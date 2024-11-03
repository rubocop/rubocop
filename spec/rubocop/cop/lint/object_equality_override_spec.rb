# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ObjectEqualityOverride, :config do
  let(:msg) { 'Check the class of `%<parameter_name>s` in `eql?`.' }

  it 'does not register an offense when classes are checked with `==` method' do
    expect_no_offenses(<<~RUBY)
      def eql?(other)
        self.class == other.class && self.title == other.title
      end
    RUBY
  end

  context 'when classes are check with `<=` method' do
    it 'registers an offense when arguments are in unexpected order' do
      expect_offense(<<~RUBY)
        def eql?(other)
        ^^^^^^^^^^^^^^^ #{format(msg, parameter_name: 'other')}
          self.class <= other.class && self.title == other.title
        end
      RUBY
    end

    it 'does not register an offense when arguments are in expected order' do
      expect_no_offenses(<<~RUBY)
        def eql?(other)
          other.class <= self.class && self.title == other.title
        end
      RUBY
    end
  end

  context 'when classes are check with `<` method' do
    it 'registers an offense when arguments are in unexpected order' do
      expect_offense(<<~RUBY)
        def eql?(other)
        ^^^^^^^^^^^^^^^ #{format(msg, parameter_name: 'other')}
          self.class < other.class && self.title == other.title
        end
      RUBY
    end

    it 'does not register an offense when arguments are in expected order' do
      expect_no_offenses(<<~RUBY)
        def eql?(other)
          other.class < self.class && self.title == other.title
        end
      RUBY
    end
  end

  it 'does not register an offense when classes are checked with `is_a?` method' do
    expect_no_offenses(<<~RUBY)
      def eql?(other)
        other.is_a?(self.class) && self.title == other.title
      end
    RUBY
  end

  it 'does not register an offense when classes are checked with `kind_of?` method' do
    expect_no_offenses(<<~RUBY)
      def eql?(other)
        other.kind_of?(self.class) && self.title == other.title
      end
    RUBY
  end

  it 'does not register an offense when classes are checked with `instance_of?` method' do
    expect_no_offenses(<<~RUBY)
      def eql?(other)
        other.instance_of?(self.class) && self.title == other.title
      end
    RUBY

    expect_no_offenses(<<~RUBY)
      def eql?(other)
        instance_of?(other.class) && self.title == other.title
      end
    RUBY

    expect_no_offenses(<<~RUBY)
      def eql?(other)
        self.instance_of?(other.class) && self.title == other.title
      end
    RUBY
  end

  context 'when implementation delegates to `hash`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def eql?(other)
          hash == other.hash
        end
      RUBY

      expect_no_offenses(<<~RUBY)
        def eql?(other)
          other.hash == hash
        end
      RUBY
    end
  end

  context 'with method which is not an equality difintion' do
    it 'does not register an offense when method has unexpected name' do
      expect_no_offenses(<<~RUBY)
        def custom_eql?(other)
          to_s == other.to_s
        end
      RUBY
    end

    it 'does not register an offense when method has multiple parameters' do
      expect_no_offenses(<<~RUBY)
        def eql?(other, context)
          other == self && context == nil
        end
      RUBY
    end

    it 'does not register an offense when method has no parameters' do
      expect_no_offenses(<<~RUBY)
        def eql?
          other == self && context == nil
        end
      RUBY
    end
  end

  context 'with missing class check' do
    it 'registers an offense with `eql?` method' do
      expect_offense(<<~RUBY)
        def eql?(other)
        ^^^^^^^^^^^^^^^ #{format(msg, parameter_name: 'other')}
          self.title == other.title
        end
      RUBY
    end

    it 'does not register an offense for `==` method' do
      expect_no_offenses(<<~RUBY)
        def ==(other)
          to_s == other.to_s
        end
      RUBY
    end
  end
end
