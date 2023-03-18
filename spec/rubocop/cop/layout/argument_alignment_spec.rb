# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ArgumentAlignment, :config do
  let(:config) do
    RuboCop::Config.new('Layout/ArgumentAlignment' => cop_config,
                        'Layout/IndentationWidth' => {
                          'Width' => indentation_width
                        })
  end
  let(:indentation_width) { 2 }

  context 'aligned with first argument' do
    let(:cop_config) { { 'EnforcedStyle' => 'with_first_argument' } }

    it 'registers an offense and corrects arguments with single indent' do
      expect_offense(<<~RUBY)
        function(a,
          if b then c else d end)
          ^^^^^^^^^^^^^^^^^^^^^^ Align the arguments of a method call if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        function(a,
                 if b then c else d end)
      RUBY
    end

    it 'registers an offense and corrects multiline missed indentation' do
      expect_offense(<<~RUBY)
        func(a,
               b,
               ^ Align the arguments of a method call if they span more than one line.
        c)
        ^ Align the arguments of a method call if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        func(a,
             b,
             c)
      RUBY
    end

    it 'registers an offense and corrects arguments with double indent' do
      expect_offense(<<~RUBY)
        function(a,
            if b then c else d end)
            ^^^^^^^^^^^^^^^^^^^^^^ Align the arguments of a method call if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        function(a,
                 if b then c else d end)
      RUBY
    end

    it 'accepts multiline []= method call' do
      expect_no_offenses(<<~RUBY)
        Test.config["something"] =
         true
      RUBY
    end

    it 'accepts correctly aligned arguments' do
      expect_no_offenses(<<~RUBY)
        function(a,
                 0, 1,
                 (x + y),
                 if b then c else d end)
      RUBY
    end

    it 'accepts correctly aligned arguments with fullwidth characters' do
      expect_no_offenses(<<~RUBY)
        f 'Ｒｕｂｙ', g(a,
                        b)
      RUBY
    end

    it 'accepts calls that only span one line' do
      expect_no_offenses('find(path, s, @special[sexp[0]])')
    end

    it "doesn't get confused by a symbol argument" do
      expect_no_offenses(<<~RUBY)
        add_offense(index,
                    MSG % kind)
      RUBY
    end

    it 'registers an offense and corrects when missed indentation kwargs' do
      expect_offense(<<~RUBY)
        func1(foo: 'foo',
          bar: 'bar',
          ^^^^^^^^^^ Align the arguments of a method call if they span more than one line.
          baz: 'baz')
          ^^^^^^^^^^ Align the arguments of a method call if they span more than one line.
        func2(do_something,
          foo: 'foo',
          ^^^^^^^^^^^ Align the arguments of a method call if they span more than one line.
          bar: 'bar',
          baz: 'baz')
      RUBY

      expect_correction(<<~RUBY)
        func1(foo: 'foo',
              bar: 'bar',
              baz: 'baz')
        func2(do_something,
              foo: 'foo',
              bar: 'bar',
              baz: 'baz')
      RUBY
    end

    it 'registers an offense and corrects splat operator' do
      expect_offense(<<~RUBY)
        func1(*a,
              *b,
              c)
        func2(a,
             *b,
             ^^ Align the arguments of a method call if they span more than one line.
              c)
        func3(*a)
      RUBY

      expect_correction(<<~RUBY)
        func1(*a,
              *b,
              c)
        func2(a,
              *b,
              c)
        func3(*a)
      RUBY
    end

    it "doesn't get confused by extra comma at the end" do
      expect_offense(<<~RUBY)
        func1(a,
             b,)
             ^ Align the arguments of a method call if they span more than one line.
      RUBY

      expect_correction(<<~RUBY)
        func1(a,
              b,)
      RUBY
    end

    it 'can handle a correctly aligned string literal as first argument' do
      expect_no_offenses(<<~RUBY)
        add_offense(x,
                    a)
      RUBY
    end

    it 'can handle a string literal as other argument' do
      expect_no_offenses(<<~RUBY)
        add_offense(
                    "", a)
      RUBY
    end

    it "doesn't get confused by a line break inside a parameter" do
      expect_no_offenses(<<~RUBY)
        read(path, { headers:    true,
                     converters: :numeric })
      RUBY
    end

    it "doesn't get confused by symbols with embedded expressions" do
      expect_no_offenses('send(:"#{name}_comments_path")')
    end

    it "doesn't get confused by regexen with embedded expressions" do
      expect_no_offenses('a(/#{name}/)')
    end

    it 'accepts braceless hashes' do
      expect_no_offenses(<<~RUBY)
        run(collection, :entry_name => label,
                        :paginator  => paginator)
      RUBY
    end

    it 'accepts the first parameter being on a new row' do
      expect_no_offenses(<<~RUBY)
        match(
          a,
          b
        )
      RUBY
    end

    it 'can handle heredoc strings' do
      expect_no_offenses(<<~'RUBY')
        class_eval(<<-EOS, __FILE__, __LINE__ + 1)
                    def run_#{name}_callbacks(*args)
                      a = 1
                      return value
                    end
                    EOS
      RUBY
    end

    it 'can handle a method call within a method call' do
      expect_no_offenses(<<~RUBY)
        a(a1,
          b(b1,
            b2),
          a2)
      RUBY
    end

    it 'can handle a call embedded in a string' do
      expect_no_offenses('model("#{index(name)}", child)')
    end

    it 'can handle do-end' do
      expect_no_offenses(<<~RUBY)
        run(lambda do |e|
          w = e['warden']
        end)
      RUBY
    end

    it 'can handle a call with a block inside another call' do
      expect_no_offenses(<<~'RUBY')
        new(table_name,
            exec_query("info('#{row['name']}')").map { |col|
              col['name']
            })
      RUBY
    end

    it 'can handle a ternary condition with a block reference' do
      expect_no_offenses('cond ? a : func(&b)')
    end

    it 'can handle parentheses used with no arguments' do
      expect_no_offenses('func()')
    end

    it 'can handle a multiline hash as second parameter' do
      expect_no_offenses(<<~RUBY)
        tag(:input, {
          :value => value
        })
      RUBY
    end

    it 'can handle method calls without parentheses' do
      expect_no_offenses('a(b c, d)')
    end

    it 'can handle other method calls without parentheses' do
      expect_no_offenses(<<~RUBY)
        chars(Unicode.apply_mapping @wrapped_string, :uppercase)
      RUBY
    end

    it "doesn't crash and burn when there are nested issues" do
      # regression test; see GH issue 2441
      expect do
        expect_offense(<<~RUBY)
          build(:house,
            :rooms => [
            ^^^^^^^^^^^ Align the arguments of a method call if they span more than one line.
              build(:bedroom,
                :bed => build(:bed,
                ^^^^^^^^^^^^^^^^^^^ Align the arguments of a method call if they span more than one line.
                  :occupants => [],
                  ^^^^^^^^^^^^^^^^^ Align the arguments of a method call if they span more than one line.
                  :size => "king"
                )
              )
            ]
          )
        RUBY
      end.not_to raise_error
    end

    context 'assigned methods' do
      it 'accepts the first parameter being on a new row' do
        expect_no_offenses(<<~RUBY)
          assigned_value = match(
            a,
            b,
            c
          )
        RUBY
      end

      it 'accepts the first parameter being on method row' do
        expect_no_offenses(<<~RUBY)
          assigned_value = match(a,
                                 b,
                                 c
                           )
        RUBY
      end
    end

    it 'registers an offense and corrects multi-line outdented parameters' do
      expect_offense(<<~RUBY)
        create :transaction, :closed,
              account:          account,
              ^^^^^^^^^^^^^^^^^^^^^^^^^^ Align the arguments of a method call if they span more than one line.
              open_price:       1.29,
              close_price:      1.30
      RUBY

      expect_correction(<<~RUBY)
        create :transaction, :closed,
               account:          account,
               open_price:       1.29,
               close_price:      1.30
      RUBY
    end

    it 'registers an offense and correct multi-line parameters indented too far' do
      expect_offense(<<~RUBY)
        create :transaction, :closed,
                 account:          account,
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^ Align the arguments of a method call if they span more than one line.
                 open_price:       1.29,
                 close_price:      1.30
      RUBY

      expect_correction(<<~RUBY)
        create :transaction, :closed,
               account:          account,
               open_price:       1.29,
               close_price:      1.30
      RUBY
    end

    it 'does not crash in autocorrect on dynamic string in parameter value' do
      expect_offense(<<~'RUBY')
        class MyModel < ActiveRecord::Base
          has_many :other_models,
            class_name: "legacy_name",
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Align the arguments of a method call if they span more than one line.
            order: "#{legacy_name.table_name}.published DESC"

        end
      RUBY

      expect_correction(<<~'RUBY')
        class MyModel < ActiveRecord::Base
          has_many :other_models,
                   class_name: "legacy_name",
                   order: "#{legacy_name.table_name}.published DESC"

        end
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers an offense and corrects arguments with single indent' do
        expect_offense(<<~RUBY)
          receiver&.function(a,
            if b then c else d end)
            ^^^^^^^^^^^^^^^^^^^^^^ Align the arguments of a method call if they span more than one line.
        RUBY

        expect_correction(<<~RUBY)
          receiver&.function(a,
                             if b then c else d end)
        RUBY
      end
    end
  end

  context 'aligned with fixed indentation' do
    let(:cop_config) { { 'EnforcedStyle' => 'with_fixed_indentation' } }

    it 'autocorrects by outdenting when indented too far' do
      expect_offense(<<~RUBY)
        create :transaction, :closed,
               account:     account,
               ^^^^^^^^^^^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
               open_price:  1.29,
               ^^^^^^^^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
               close_price: 1.30
               ^^^^^^^^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
      RUBY

      expect_correction(<<~RUBY)
        create :transaction, :closed,
          account:     account,
          open_price:  1.29,
          close_price: 1.30
      RUBY
    end

    it 'autocorrects by indenting when not indented' do
      expect_offense(<<~RUBY)
        create :transaction, :closed,
        account:     account,
        ^^^^^^^^^^^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
        open_price:  1.29,
        ^^^^^^^^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
        close_price: 1.30
        ^^^^^^^^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
      RUBY

      expect_correction(<<~RUBY)
        create :transaction, :closed,
          account:     account,
          open_price:  1.29,
          close_price: 1.30
      RUBY
    end

    it 'registers an offense and corrects when missed indentation kwargs' do
      expect_offense(<<~RUBY)
        func1(foo: 'foo',
              bar: 'bar',
              ^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
              baz: 'baz')
              ^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
        func2(do_something,
              foo: 'foo',
              ^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
              bar: 'bar',
              ^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
              baz: 'baz')
              ^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
      RUBY

      expect_correction(<<~RUBY)
        func1(foo: 'foo',
          bar: 'bar',
          baz: 'baz')
        func2(do_something,
          foo: 'foo',
          bar: 'bar',
          baz: 'baz')
      RUBY
    end

    it 'corrects indentation for kwargs starting on same line as other args' do
      expect_offense(<<~RUBY)
        func(do_something, foo: 'foo',
                           bar: 'bar',
                           ^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
                           baz: 'baz')
                           ^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
      RUBY

      expect_correction(<<~RUBY)
        func(do_something, foo: 'foo',
          bar: 'bar',
          baz: 'baz')
      RUBY
    end

    it 'autocorrects when first line is indented' do
      expect_offense(<<-RUBY.strip_margin('|'))
        |  create :transaction, :closed,
        |  account:     account,
        |  ^^^^^^^^^^^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
        |  open_price:  1.29,
        |  ^^^^^^^^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
        |  close_price: 1.30
        |  ^^^^^^^^^^^^^^^^^ Use one level of indentation for arguments following the first line of a multi-line method call.
      RUBY

      expect_correction(<<-RUBY.strip_margin('|'))
        |  create :transaction, :closed,
        |    account:     account,
        |    open_price:  1.29,
        |    close_price: 1.30
      RUBY
    end

    context 'multi-line method calls' do
      it 'can handle existing indentation from multi-line method calls' do
        expect_no_offenses(<<~RUBY)
          something
            .method_name(
              a,
              b,
              c
            )
        RUBY
      end

      it 'registers offenses and corrects double indentation from relevant method' do
        expect_offense(<<~RUBY)
          something
            .method_name(
                a,
                ^ Use one level of indentation for arguments following the first line of a multi-line method call.
                b,
                ^ Use one level of indentation for arguments following the first line of a multi-line method call.
                c
                ^ Use one level of indentation for arguments following the first line of a multi-line method call.
            )
        RUBY

        expect_correction(<<~RUBY)
          something
            .method_name(
              a,
              b,
              c
            )
        RUBY
      end

      it 'does not err on method call without a method name' do
        expect_no_offenses(<<~RUBY)
          something
            .(
              a,
              b,
              c
            )
        RUBY
      end

      it 'autocorrects relative to position of relevant method call' do
        expect_offense(<<-RUBY.strip_margin('|'))
          | something
          |   .method_name(
          |       a,
          |       ^ Use one level of indentation for arguments following the first line of a multi-line method call.
          |          b,
          |          ^ Use one level of indentation for arguments following the first line of a multi-line method call.
          |            c
          |            ^ Use one level of indentation for arguments following the first line of a multi-line method call.
          |   )
        RUBY

        expect_correction(<<-RUBY.strip_margin('|'))
          | something
          |   .method_name(
          |     a,
          |     b,
          |     c
          |   )
        RUBY
      end
    end

    context 'assigned methods' do
      context 'with IndentationWidth:Width set to 4' do
        let(:indentation_width) { 4 }

        it 'accepts the first parameter being on a new row' do
          expect_no_offenses(<<~RUBY)
            assigned_value = match(
                a,
                b,
                c
            )
          RUBY
        end

        it 'accepts the first parameter being on method row' do
          expect_no_offenses(<<~RUBY)
            assigned_value = match(a,
                b,
                c
            )
          RUBY
        end

        it 'autocorrects even when first argument is in wrong position' do
          expect_offense(<<-RUBY.strip_margin('|'))
            | assigned_value = match(
            |         a,
            |         ^ Use one level of indentation for arguments following the first line of a multi-line method call.
            |            b,
            |            ^ Use one level of indentation for arguments following the first line of a multi-line method call.
            |                    c
            |                    ^ Use one level of indentation for arguments following the first line of a multi-line method call.
            | )
          RUBY

          expect_correction(<<-RUBY.strip_margin('|'))
            | assigned_value = match(
            |     a,
            |     b,
            |     c
            | )
          RUBY
        end
      end

      context 'with ArgumentAlignment:IndentationWidth set to 4' do
        let(:config) do
          RuboCop::Config.new('Layout/ArgumentAlignment' =>
                              cop_config.merge('IndentationWidth' => 4))
        end

        it 'accepts the first parameter being on a new row' do
          expect_no_offenses(<<~RUBY)
            assigned_value = match(
                a,
                b,
                c
            )
          RUBY
        end

        it 'accepts the first parameter being on method row' do
          expect_no_offenses(<<~RUBY)
            assigned_value = match(a,
                b,
                c
            )
          RUBY
        end
      end
    end

    it 'does not register an offense when using aligned braced hash as a argument' do
      expect_no_offenses(<<~RUBY)
        do_something(
          {
            foo: 'bar',
            baz: 'qux'
          }
        )
      RUBY
    end
  end
end
