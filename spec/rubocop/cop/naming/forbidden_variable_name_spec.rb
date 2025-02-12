# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::ForbiddenVariableName, :config do
  let(:cop_config) { { 'ForbiddenNames' => %w[require] } }

  context 'with `lvasgn`' do
    it 'registers an offense when given a forbidden identifier' do
      expect_offense(<<~RUBY)
        require = true
        ^^^^^^^ `require` is forbidden, use another name instead.
      RUBY

      expect_no_corrections
    end
  end

  context 'with `ivasgn`' do
    it 'registers an offense when given a forbidden identifier' do
      expect_offense(<<~RUBY)
        @require = true
        ^^^^^^^^ `@require` is forbidden, use another name instead.
      RUBY

      expect_no_corrections
    end
  end

  context 'with `cvasgn`' do
    it 'registers an offense when given a forbidden identifier' do
      expect_offense(<<~RUBY)
        @@require = true
        ^^^^^^^^^ `@@require` is forbidden, use another name instead.
      RUBY

      expect_no_corrections
    end
  end

  context 'with `gvasgn`' do
    it 'registers an offense when given a forbidden identifier' do
      expect_offense(<<~RUBY)
        $require = true
        ^^^^^^^^ `$require` is forbidden, use another name instead.
      RUBY

      expect_no_corrections
    end
  end

  context 'with `arg`' do
    it 'registers an offense when given a forbidden identifier' do
      expect_offense(<<~RUBY)
        def foo(require)
                ^^^^^^^ `require` is forbidden, use another name instead.
        end
      RUBY

      expect_no_corrections
    end
  end

  context 'with `optarg`' do
    it 'registers an offense when given a forbidden identifier' do
      expect_offense(<<~RUBY)
        def foo(require = false)
                ^^^^^^^ `require` is forbidden, use another name instead.
        end
      RUBY

      expect_no_corrections
    end
  end

  context 'with `restarg`' do
    it 'registers an offense when given a forbidden identifier' do
      expect_offense(<<~RUBY)
        def foo(*require)
                 ^^^^^^^ `require` is forbidden, use another name instead.
        end
      RUBY
    end
  end

  context 'with `kwarg`' do
    it 'registers an offense when given a forbidden identifier' do
      expect_offense(<<~RUBY)
        def foo(require:)
                ^^^^^^^ `require` is forbidden, use another name instead.
        end
      RUBY

      expect_no_corrections
    end
  end

  context 'with `kwargopt`' do
    it 'registers an offense when given a forbidden identifier' do
      expect_offense(<<~RUBY)
        def foo(require: true)
                ^^^^^^^ `require` is forbidden, use another name instead.
        end
      RUBY
    end
  end

  context 'with `kwrestarg`' do
    it 'registers an offense when given a forbidden identifier' do
      expect_offense(<<~RUBY)
        def foo(**require)
                  ^^^^^^^ `require` is forbidden, use another name instead.
        end
      RUBY

      expect_no_corrections
    end
  end

  context 'with `blockarg` in `def`' do
    it 'registers an offense when given a forbidden identifier' do
      expect_offense(<<~RUBY)
        def foo(&require)
                 ^^^^^^^ `require` is forbidden, use another name instead.
        end
      RUBY

      expect_no_corrections
    end
  end

  context 'with `blockarg` in `block`' do
    it 'registers an offense when given a forbidden identifier' do
      expect_offense(<<~RUBY)
        foo do |require|
                ^^^^^^^ `require` is forbidden, use another name instead.
        end
      RUBY

      expect_no_corrections
    end
  end
end
