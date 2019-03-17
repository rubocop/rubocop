# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::RescueEnsureAlignment, :config do
  subject(:cop) { described_class.new(config) }

  it 'accepts the modifier form' do
    expect_no_offenses('test rescue nil')
  end

  context 'rescue with begin' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        begin
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `begin` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        begin
          something
        rescue
            error
        end
      RUBY
    end

    context 'as RHS of assignment' do
      it 'accepts multi-line, aligned' do
        expect_no_offenses(<<-RUBY.strip_indent)
          x ||= begin
                  1
                rescue
                  2
                end
        RUBY
      end

      it 'accepts multi-line, indented' do
        expect_no_offenses(<<-RUBY.strip_indent)
          x ||=
            begin
              1
            rescue
              2
            end
        RUBY
      end

      it 'registers offense for incorrect alignment' do
        expect_offense(<<-RUBY.strip_indent)
          x ||= begin
            1
          rescue
          ^^^^^^ `rescue` at 3, 0 is not aligned with `begin` at 1, 6.
            2
          end
        RUBY
      end
    end
  end

  context 'rescue with def' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def test
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `def test` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        def test
          something
        rescue
            error
        end
      RUBY
    end
  end

  context 'rescue with defs' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def Test.test
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `def Test.test` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        def Test.test
          something
        rescue
            error
        end
      RUBY
    end
  end

  context 'rescue with class' do
    it 'registers an offense when rescue used with class' do
      expect_offense(<<-RUBY.strip_indent)
        class C
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `class C` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        class C
          something
        rescue
            error
        end
      RUBY
    end
  end

  context 'rescue with module' do
    it 'registers an offense when rescue used with module' do
      expect_offense(<<-RUBY.strip_indent)
        module M
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `module M` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        module M
          something
        rescue
            error
        end
      RUBY
    end
  end

  context 'ensure with begin' do
    it 'registers an offense when ensure used with begin' do
      expect_offense(<<-RUBY.strip_indent)
        begin
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `begin` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        begin
          something
        ensure
            error
        end
      RUBY
    end
  end

  context 'ensure with def' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def test
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `def test` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        def test
          something
        ensure
            error
        end
      RUBY
    end
  end

  context 'ensure with defs' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def Test.test
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `def Test.test` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        def Test.test
          something
        ensure
            error
        end
      RUBY
    end
  end

  context 'ensure with class' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        class C
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `class C` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        class C
          something
        ensure
            error
        end
      RUBY
    end
  end

  context 'ensure with module' do
    it 'registers an offense when ensure used with module' do
      expect_offense(<<-RUBY.strip_indent)
        module M
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `module M` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        module M
          something
        ensure
            error
        end
      RUBY
    end
  end

  it 'accepts end being misaligned' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def method1
        'foo'
      end

      def method2
        'bar'
      rescue
        'baz' end
    RUBY
  end

  it 'accepts rescue and ensure on the same line' do
    expect_no_offenses('begin; puts 1; rescue; ensure; puts 2; end')
  end

  it 'accepts correctly aligned rescue' do
    expect_no_offenses(<<-RUBY.strip_indent)
      begin
        something
      rescue
        error
      end
    RUBY
  end

  it 'accepts correctly aligned ensure' do
    expect_no_offenses(<<-RUBY.strip_indent)
      begin
        something
      ensure
        error
      end
    RUBY
  end

  it 'accepts correctly aligned rescue in assigned begin-end block' do
    expect_no_offenses(<<-RUBY)
      foo = begin
              bar
            rescue BazError
              qux
            end
    RUBY
  end

  context '>= Ruby 2.5', :ruby25 do
    it 'accepts aligned rescue in do-end block' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [1, 2, 3].each do |el|
          el.to_s
        rescue StandardError => _exception
          next
        end
      RUBY
    end

    it 'accepts aligned rescue do-end block assigned to local variable' do
      expect_no_offenses(<<-RUBY.strip_indent)
        result = [1, 2, 3].map do |el|
          el.to_s
        rescue StandardError => _exception
          next
        end
      RUBY
    end

    it 'accepts aligned rescue in do-end block assigned to instance variable' do
      expect_no_offenses(<<-RUBY.strip_indent)
        @instance = [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end

    it 'accepts aligned rescue in do-end block assigned to class variable' do
      expect_no_offenses(<<-RUBY.strip_indent)
        @@class = [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end

    it 'accepts aligned rescue in do-end block assigned to global variable' do
      expect_no_offenses(<<-RUBY.strip_indent)
        $global = [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end

    it 'accepts aligned rescue in do-end block assigned to class' do
      expect_no_offenses(<<-RUBY.strip_indent)
        CLASS = [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end

    it 'accepts aligned rescue in do-end block on multi-assignment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a, b = [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end

    it 'accepts aligned rescue in do-end block on operation assignment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a += [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end

    it 'accepts aligned rescue in do-end block on and-assignment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a &&= [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end

    it 'accepts aligned rescue in do-end block on or-assignment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a ||= [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end

    it 'accepts aligned rescue in assigned do-end block starting on newline' do
      expect_no_offenses(<<-RUBY.strip_indent)
        valid =
          proc do |bar|
            baz
          rescue
            qux
          end
      RUBY
    end

    it 'accepts aligned rescue in do-end block in a method' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def foo
          [1, 2, 3].each do |el|
            el.to_s
          rescue StandardError => _exception
            next
          end
        end
      RUBY
    end

    context 'rescue with do-end block' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          def foo
            [1, 2, 3].each do |el|
              el.to_s
          rescue StandardError => _exception
          ^^^^^^ `rescue` at 4, 0 is not aligned with `[1, 2, 3].each do` at 2, 2.
              next
            end
          end
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          def foo
            [1, 2, 3].each do |el|
              el.to_s
            rescue StandardError => _exception
              next
            end
          end
        RUBY
      end
    end
  end

  describe 'excluded file' do
    subject(:cop) { described_class.new(config) }

    let(:config) do
      RuboCop::Config.new('Layout/RescueEnsureAlignment' =>
                          { 'Enabled' => true,
                            'Exclude' => ['**/**'] })
    end

    it 'processes excluded files with issue' do
      expect_no_offenses(<<-RUBY.strip_indent)
        begin
          foo
        rescue
          bar
        end
      RUBY
    end
  end

  context 'allows inline access modifier' do
    let(:cop_config) do
      {
        'Style/AccessModifierDeclarations' =>
          { 'EnforcedStyle' => 'inline' }
      }
    end

    context 'rescue with def' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          private def test
            'foo'
            rescue
            ^^^^^^ `rescue` at 3, 2 is not aligned with `private def test` at 1, 0.
            'baz'
          end
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          private def test
            'foo'
          rescue
            'baz'
          end
        RUBY
      end

      it 'correct alignment' do
        expect_no_offenses(<<-RUBY.strip_indent)
          private def test
            'foo'
          rescue
            'baz'
          end
        RUBY
      end
    end

    context 'rescue with defs' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          private def Test.test
            'foo'
            rescue
            ^^^^^^ `rescue` at 3, 2 is not aligned with `private def Test.test` at 1, 0.
            'baz'
          end
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          private def Test.test
            'foo'
          rescue
            'baz'
          end
        RUBY
      end

      it 'correct alignment' do
        expect_no_offenses(<<-RUBY.strip_indent)
          private def Test.test
            'foo'
          rescue
            'baz'
          end
        RUBY
      end
    end

    context 'ensure with def' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          private def test
            'foo'
            ensure
            ^^^^^^ `ensure` at 3, 2 is not aligned with `private def test` at 1, 0.
            'baz'
          end
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          private def test
            'foo'
          ensure
            'baz'
          end
        RUBY
      end

      it 'correct alignment' do
        expect_no_offenses(<<-RUBY.strip_indent)
          private def test
            'foo'
          ensure
            'baz'
          end
        RUBY
      end
    end

    context 'ensure with defs' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          private def Test.test
            'foo'
            ensure
            ^^^^^^ `ensure` at 3, 2 is not aligned with `private def Test.test` at 1, 0.
            'baz'
          end
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          private def Test.test
            'foo'
          ensure
            'baz'
          end
        RUBY
      end

      it 'correct alignment' do
        expect_no_offenses(<<-RUBY.strip_indent)
          private def Test.test
            'foo'
          ensure
            'baz'
          end
        RUBY
      end
    end
  end

  context 'allows inline expression before' do
    context 'rescue' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          def test
            'foo'; rescue; 'baz'
                   ^^^^^^ `rescue` at 2, 9 is not aligned with `def test` at 1, 0.
          end

          def test
            begin
              'foo'; rescue; 'baz'
                     ^^^^^^ `rescue` at 7, 11 is not aligned with `begin` at 6, 2.
            end
          end
        RUBY

        expect_no_corrections
      end
    end

    context 'ensure' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          def test
            'foo'; ensure; 'baz'
                   ^^^^^^ `ensure` at 2, 9 is not aligned with `def test` at 1, 0.
          end

          def test
            begin
              'foo'; ensure; 'baz'
                     ^^^^^^ `ensure` at 7, 11 is not aligned with `begin` at 6, 2.
            end
          end
        RUBY

        expect_no_corrections
      end
    end
  end
end
