# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::RescueEnsureAlignment, :config do
  it 'accepts the modifier form' do
    expect_no_offenses('test rescue nil')
  end

  context 'rescue with begin' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        begin
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `begin` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          something
        rescue
            error
        end
      RUBY
    end

    context 'as RHS of assignment' do
      let(:cop_config) { { 'EnforcedStyle' => 'require_parentheses' } }

      context '`Layout/BeginEndAlignment` cop is not enabled' do
        let(:other_cops) do
          {
            'Layout/BeginEndAlignment' => {
              'Enabled' => false,
              'EnforcedStyleAlignWith' => 'start_of_line'
            }
          }
        end

        it 'accepts multi-line, aligned' do
          expect_no_offenses(<<~RUBY)
            x ||= begin
                    1
                  rescue
                    2
                  end
          RUBY
        end

        it 'accepts multi-line, indented' do
          expect_no_offenses(<<~RUBY)
            x ||=
              begin
                1
              rescue
                2
              end
          RUBY
        end

        it 'registers an offense and corrects for incorrect alignment' do
          expect_offense(<<~RUBY)
            x ||= begin
              1
            rescue
            ^^^^^^ `rescue` at 3, 0 is not aligned with `begin` at 1, 6.
              2
            end
          RUBY

          # Except for `rescue`, it will be aligned by `Layout/BeginEndAlignment` autocorrection.
          expect_correction(<<~RUBY)
            x ||= begin
              1
                  rescue
              2
            end
          RUBY
        end
      end

      context 'when `EnforcedStyleAlignWith: start_of_line` of `Layout/BeginEndAlignment` cop' do
        let(:other_cops) do
          {
            'Layout/BeginEndAlignment' => { 'EnforcedStyleAlignWith' => 'start_of_line' }
          }
        end

        it 'accepts multi-line, aligned' do
          expect_no_offenses(<<~RUBY)
            x ||= begin
              1
            rescue
              2
            end
          RUBY
        end

        it 'accepts multi-line, indented' do
          expect_no_offenses(<<~RUBY)
            x ||=
              begin
                1
              rescue
                2
              end
          RUBY
        end

        it 'registers an offense and corrects for incorrect alignment' do
          expect_offense(<<~RUBY)
            x ||= begin
                    1
                  rescue
                  ^^^^^^ `rescue` at 3, 6 is not aligned with `x ||= begin` at 1, 0.
                    2
                  end
          RUBY

          # Except for `rescue`, it will be aligned by `Layout/BeginEndAlignment` autocorrection.
          expect_correction(<<~RUBY)
            x ||= begin
                    1
            rescue
                    2
                  end
          RUBY
        end
      end

      context 'when `EnforcedStyleAlignWith: begin` of `Layout/BeginEndAlignment` cop' do
        let(:other_cops) do
          {
            'Layout/BeginEndAlignment' => { 'EnforcedStyleAlignWith' => 'begin' }
          }
        end

        it 'accepts multi-line, aligned' do
          expect_no_offenses(<<~RUBY)
            x ||= begin
                    1
                  rescue
                    2
                 end
          RUBY
        end

        it 'accepts multi-line, indented' do
          expect_no_offenses(<<~RUBY)
            x ||=
              begin
                1
              rescue
                2
              end
          RUBY
        end

        it 'registers an offense and corrects for incorrect alignment' do
          expect_offense(<<~RUBY)
            x ||= begin
              1
            rescue
            ^^^^^^ `rescue` at 3, 0 is not aligned with `begin` at 1, 6.
              2
            end
          RUBY

          # Except for `rescue`, it will be aligned by `Layout/BeginEndAlignment` autocorrection.
          expect_correction(<<~RUBY)
            x ||= begin
              1
                  rescue
              2
            end
          RUBY
        end
      end
    end
  end

  context 'rescue with def' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def test
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `def test` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<~RUBY)
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
      expect_offense(<<~RUBY)
        def Test.test
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `def Test.test` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<~RUBY)
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
      expect_offense(<<~RUBY)
        class C
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `class C` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<~RUBY)
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
      expect_offense(<<~RUBY)
        module M
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `module M` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<~RUBY)
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
      expect_offense(<<~RUBY)
        begin
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `begin` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<~RUBY)
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
      expect_offense(<<~RUBY)
        def test
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `def test` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<~RUBY)
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
      expect_offense(<<~RUBY)
        def Test.test
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `def Test.test` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<~RUBY)
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
      expect_offense(<<~RUBY)
        class C
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `class C` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<~RUBY)
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
      expect_offense(<<~RUBY)
        module M
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `module M` at 1, 0.
            error
        end
      RUBY

      expect_correction(<<~RUBY)
        module M
          something
        ensure
            error
        end
      RUBY
    end
  end

  it 'accepts end being misaligned' do
    expect_no_offenses(<<~RUBY)
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
    expect_no_offenses(<<~RUBY)
      begin
        something
      rescue
        error
      end
    RUBY
  end

  it 'accepts correctly aligned ensure' do
    expect_no_offenses(<<~RUBY)
      begin
        something
      ensure
        error
      end
    RUBY
  end

  it 'accepts correctly aligned rescue/ensure with def' do
    expect_no_offenses(<<~RUBY)
      def foo
        something
      rescue StandardError
        handle_error
      ensure
        error
      end
    RUBY
  end

  it 'accepts correctly aligned rescue/ensure with def with no body' do
    expect_no_offenses(<<~RUBY)
      def foo
      rescue StandardError
        handle_error
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

  it 'accepts aligned rescue in do-end block' do
    expect_no_offenses(<<~RUBY)
      [1, 2, 3].each do |el|
        el.to_s
      rescue StandardError => _exception
        next
      end
    RUBY
  end

  it 'accepts aligned rescue in do-end block with `.()` call' do
    expect_no_offenses(<<~RUBY)
      foo.() do |el|
        el.to_s
      rescue StandardError => _exception
        next
      end
    RUBY
  end

  it 'accepts aligned rescue with do-end block that line break with leading dot for method calls' do
    expect_no_offenses(<<~RUBY)
      [1, 2, 3]
        .each do |el|
          el.to_s
        rescue StandardError => _exception
          next
        end
    RUBY
  end

  it 'accepts aligned rescue with do-end block that line break with trailing dot for method calls' do
    expect_no_offenses(<<~RUBY)
      [1, 2, 3].
        each do |el|
          el.to_s
        rescue StandardError => _exception
          next
        end
    RUBY
  end

  it 'accepts aligned rescue do-end block assigned to local variable' do
    expect_no_offenses(<<~RUBY)
      result = [1, 2, 3].map do |el|
        el.to_s
      rescue StandardError => _exception
        next
      end
    RUBY
  end

  it 'accepts aligned rescue in do-end block assigned to instance variable' do
    expect_no_offenses(<<~RUBY)
      @instance = [].map do |_|
      rescue StandardError => _
      end
    RUBY
  end

  it 'accepts aligned rescue in do-end block assigned to class variable' do
    expect_no_offenses(<<~RUBY)
      @@class = [].map do |_|
      rescue StandardError => _
      end
    RUBY
  end

  it 'accepts aligned rescue in do-end block assigned to global variable' do
    expect_no_offenses(<<~RUBY)
      $global = [].map do |_|
      rescue StandardError => _
      end
    RUBY
  end

  it 'accepts aligned rescue in do-end block assigned to class' do
    expect_no_offenses(<<~RUBY)
      CLASS = [].map do |_|
      rescue StandardError => _
      end
    RUBY
  end

  it 'accepts aligned rescue in do-end block on multi-assignment' do
    expect_no_offenses(<<~RUBY)
      a, b = [].map do |_|
      rescue StandardError => _
      end
    RUBY
  end

  it 'accepts aligned rescue in do-end block on operation assignment' do
    expect_no_offenses(<<~RUBY)
      a += [].map do |_|
      rescue StandardError => _
      end
    RUBY
  end

  it 'accepts aligned rescue in do-end block on and-assignment' do
    expect_no_offenses(<<~RUBY)
      a &&= [].map do |_|
      rescue StandardError => _
      end
    RUBY
  end

  it 'accepts aligned rescue in do-end block on or-assignment' do
    expect_no_offenses(<<~RUBY)
      a ||= [].map do |_|
      rescue StandardError => _
      end
    RUBY
  end

  it 'accepts aligned rescue in assigned do-end block starting on newline' do
    expect_no_offenses(<<~RUBY)
      valid =
        proc do |bar|
          baz
        rescue
          qux
        end
    RUBY
  end

  it 'accepts aligned rescue in do-end block in a method' do
    expect_no_offenses(<<~RUBY)
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
      expect_offense(<<~RUBY)
        def foo
          [1, 2, 3].each do |el|
            el.to_s
        rescue StandardError => _exception
        ^^^^^^ `rescue` at 4, 0 is not aligned with `[1, 2, 3].each do` at 2, 2.
            next
          end
        end
      RUBY

      expect_correction(<<~RUBY)
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

  context 'rescue in do-end block assigned to local variable' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        result = [1, 2, 3].map do |el|
          rescue StandardError => _exception
          ^^^^^^ `rescue` at 2, 2 is not aligned with `result` at 1, 0.
        end
      RUBY

      expect_correction(<<~RUBY)
        result = [1, 2, 3].map do |el|
        rescue StandardError => _exception
        end
      RUBY
    end
  end

  context 'rescue in do-end block assigned to instance variable' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        @instance = [1, 2, 3].map do |el|
          rescue StandardError => _exception
          ^^^^^^ `rescue` at 2, 2 is not aligned with `@instance` at 1, 0.
        end
      RUBY

      expect_correction(<<~RUBY)
        @instance = [1, 2, 3].map do |el|
        rescue StandardError => _exception
        end
      RUBY
    end
  end

  context 'rescue in do-end block assigned to class variable' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        @@class = [].map do |_|
          rescue StandardError => _
          ^^^^^^ `rescue` at 2, 2 is not aligned with `@@class` at 1, 0.
        end
      RUBY

      expect_correction(<<~RUBY)
        @@class = [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end
  end

  context 'rescue in do-end block assigned to global variable' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        $global = [].map do |_|
          rescue StandardError => _
          ^^^^^^ `rescue` at 2, 2 is not aligned with `$global` at 1, 0.
        end
      RUBY

      expect_correction(<<~RUBY)
        $global = [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end
  end

  context 'rescue in do-end block assigned to class' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        CLASS = [].map do |_|
          rescue StandardError => _
          ^^^^^^ `rescue` at 2, 2 is not aligned with `CLASS` at 1, 0.
        end
      RUBY

      expect_correction(<<~RUBY)
        CLASS = [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end
  end

  context 'rescue in do-end block on multi-assignment' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        a, b = [].map do |_|
          rescue StandardError => _
          ^^^^^^ `rescue` at 2, 2 is not aligned with `a, b` at 1, 0.
        end
      RUBY

      expect_correction(<<~RUBY)
        a, b = [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end
  end

  context 'rescue in do-end block on operation assignment' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        a += [].map do |_|
          rescue StandardError => _
          ^^^^^^ `rescue` at 2, 2 is not aligned with `a` at 1, 0.
        end
      RUBY

      expect_correction(<<~RUBY)
        a += [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end
  end

  context 'rescue in do-end block on and-assignment' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        a &&= [].map do |_|
          rescue StandardError => _
          ^^^^^^ `rescue` at 2, 2 is not aligned with `a` at 1, 0.
        end
      RUBY

      expect_correction(<<~RUBY)
        a &&= [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end
  end

  context 'rescue in do-end block on or-assignment' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        a ||= [].map do |_|
          rescue StandardError => _
          ^^^^^^ `rescue` at 2, 2 is not aligned with `a` at 1, 0.
        end
      RUBY

      expect_correction(<<~RUBY)
        a ||= [].map do |_|
        rescue StandardError => _
        end
      RUBY
    end
  end

  context 'rescue in assigned do-end block starting on newline' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        valid =
          proc do |bar|
            baz
            rescue
            ^^^^^^ `rescue` at 4, 4 is not aligned with `proc do` at 2, 2.
            qux
          end
      RUBY

      expect_correction(<<~RUBY)
        valid =
          proc do |bar|
            baz
          rescue
            qux
          end
      RUBY
    end
  end

  context 'when using zsuper with block' do
    it 'registers and corrects an offense and corrects when incorrect alignment' do
      expect_offense(<<~RUBY)
        super do
          nil
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `super do` at 1, 0.
          nil
        end
      RUBY

      expect_correction(<<~RUBY)
        super do
          nil
        ensure
          nil
        end
      RUBY
    end

    it 'does not register an offense when correct alignment' do
      expect_no_offenses(<<~RUBY)
        super do
          nil
        ensure
          nil
        end
      RUBY
    end
  end

  describe 'excluded file', :config do
    let(:config) do
      RuboCop::Config.new('Layout/RescueEnsureAlignment' =>
                          { 'Enabled' => true,
                            'Exclude' => ['**/**'] })
    end

    it 'processes excluded files with issue' do
      expect_no_offenses(<<~RUBY, 'foo.rb')
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

    shared_examples 'access modifier' do |modifier|
      context 'rescue with def' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            #{modifier} def test
              'foo'
              rescue
              ^^^^^^ `rescue` at 3, 2 is not aligned with `#{modifier} def test` at 1, 0.
              'baz'
            end
          RUBY

          expect_correction(<<~RUBY)
            #{modifier} def test
              'foo'
            rescue
              'baz'
            end
          RUBY
        end

        it 'correct alignment' do
          expect_no_offenses(<<~RUBY)
            #{modifier} def test
              'foo'
            rescue
              'baz'
            end
          RUBY
        end
      end

      context 'rescue with defs' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            #{modifier} def Test.test
              'foo'
              rescue
              ^^^^^^ `rescue` at 3, 2 is not aligned with `#{modifier} def Test.test` at 1, 0.
              'baz'
            end
          RUBY

          expect_correction(<<~RUBY)
            #{modifier} def Test.test
              'foo'
            rescue
              'baz'
            end
          RUBY
        end

        it 'correct alignment' do
          expect_no_offenses(<<~RUBY)
            #{modifier} def Test.test
              'foo'
            rescue
              'baz'
            end
          RUBY
        end
      end

      context 'ensure with def' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            #{modifier} def test
              'foo'
              ensure
              ^^^^^^ `ensure` at 3, 2 is not aligned with `#{modifier} def test` at 1, 0.
              'baz'
            end
          RUBY

          expect_correction(<<~RUBY)
            #{modifier} def test
              'foo'
            ensure
              'baz'
            end
          RUBY
        end

        it 'correct alignment' do
          expect_no_offenses(<<~RUBY)
            #{modifier} def test
              'foo'
            ensure
              'baz'
            end
          RUBY
        end
      end

      context 'ensure with defs' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            #{modifier} def Test.test
              'foo'
              ensure
              ^^^^^^ `ensure` at 3, 2 is not aligned with `#{modifier} def Test.test` at 1, 0.
              'baz'
            end
          RUBY

          expect_correction(<<~RUBY)
            #{modifier} def Test.test
              'foo'
            ensure
              'baz'
            end
          RUBY
        end

        it 'correct alignment' do
          expect_no_offenses(<<~RUBY)
            #{modifier} def Test.test
              'foo'
            ensure
              'baz'
            end
          RUBY
        end
      end
    end

    context 'with private modifier' do
      include_examples 'access modifier', 'private'
    end

    context 'with private_class_method modifier' do
      include_examples 'access modifier', 'private_class_method'
    end

    context 'with public_class_method modifier' do
      include_examples 'access modifier', 'public_class_method'
    end
  end

  context 'allows inline expression before' do
    context 'rescue' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
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
        expect_offense(<<~RUBY)
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
