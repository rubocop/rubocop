# frozen_string_literal: true

describe RuboCop::Cop::Layout::AlignParameters do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Layout/AlignParameters' => cop_config,
                        'Layout/IndentationWidth' => {
                          'Width' => indentation_width
                        })
  end
  let(:indentation_width) { 2 }

  context 'aligned with first parameter' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'with_first_parameter'
      }
    end

    it 'registers an offense for parameters with single indent' do
      expect_offense(<<-RUBY.strip_indent)
        function(a,
          if b then c else d end)
          ^^^^^^^^^^^^^^^^^^^^^^ Align the parameters of a method call if they span more than one line.
      RUBY
    end

    it 'registers an offense for parameters with double indent' do
      expect_offense(<<-RUBY.strip_indent)
        function(a,
            if b then c else d end)
            ^^^^^^^^^^^^^^^^^^^^^^ Align the parameters of a method call if they span more than one line.
      RUBY
    end

    it 'accepts multiline []= method call' do
      expect_no_offenses(<<-END.strip_indent)
        Test.config["something"] =
         true
      END
    end

    it 'accepts correctly aligned parameters' do
      expect_no_offenses(<<-END.strip_indent)
        function(a,
                 0, 1,
                 (x + y),
                 if b then c else d end)
      END
    end

    it 'accepts correctly aligned parameters with fullwidth characters' do
      expect_no_offenses(<<-END.strip_indent)
        f 'Ｒｕｂｙ', g(a,
                        b)
      END
    end

    it 'accepts calls that only span one line' do
      expect_no_offenses('find(path, s, @special[sexp[0]])')
    end

    it "doesn't get confused by a symbol argument" do
      expect_no_offenses(<<-END.strip_indent)
        add_offense(index,
                    MSG % kind)
      END
    end

    it "doesn't get confused by splat operator" do
      expect_offense(<<-RUBY.strip_indent)
        func1(*a,
              *b,
              c)
        func2(a,
             *b,
             ^^ Align the parameters of a method call if they span more than one line.
              c)
        func3(*a)
      RUBY
    end

    it "doesn't get confused by extra comma at the end" do
      expect_offense(<<-RUBY.strip_indent)
        func1(a,
             b,)
             ^ Align the parameters of a method call if they span more than one line.
      RUBY
    end

    it 'can handle a correctly aligned string literal as first argument' do
      expect_no_offenses(<<-END.strip_indent)
        add_offense(x,
                    a)
      END
    end

    it 'can handle a string literal as other argument' do
      expect_no_offenses(<<-END.strip_indent)
        add_offense(
                    "", a)
      END
    end

    it "doesn't get confused by a line break inside a parameter" do
      expect_no_offenses(<<-END.strip_indent)
        read(path, { headers:    true,
                     converters: :numeric })
      END
    end

    it "doesn't get confused by symbols with embedded expressions" do
      expect_no_offenses('send(:"#{name}_comments_path")')
    end

    it "doesn't get confused by regexen with embedded expressions" do
      expect_no_offenses('a(/#{name}/)')
    end

    it 'accepts braceless hashes' do
      expect_no_offenses(<<-END.strip_indent)
        run(collection, :entry_name => label,
                        :paginator  => paginator)
      END
    end

    it 'accepts the first parameter being on a new row' do
      inspect_source(cop, <<-END.strip_margin('|'))
        |  match(
        |    a,
        |    b
        |  )
      END
      expect(cop.offenses).to be_empty
    end

    it 'can handle heredoc strings' do
      expect_no_offenses(<<-'END'.strip_indent)
        class_eval(<<-EOS, __FILE__, __LINE__ + 1)
                    def run_#{name}_callbacks(*args)
                      a = 1
                      return value
                    end
                    EOS
      END
    end

    it 'can handle a method call within a method call' do
      expect_no_offenses(<<-END.strip_indent)
        a(a1,
          b(b1,
            b2),
          a2)
      END
    end

    it 'can handle a call embedded in a string' do
      expect_no_offenses('model("#{index(name)}", child)')
    end

    it 'can handle do-end' do
      inspect_source(cop, <<-END.strip_margin('|'))
        |      run(lambda do |e|
        |        w = e['warden']
        |      end)
      END
      expect(cop.offenses).to be_empty
    end

    it 'can handle a call with a block inside another call' do
      src = <<-'END'.strip_indent
        new(table_name,
            exec_query("info('#{row['name']}')").map { |col|
              col['name']
            })
      END
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'can handle a ternary condition with a block reference' do
      expect_no_offenses('cond ? a : func(&b)')
    end

    it 'can handle parentheses used with no parameters' do
      expect_no_offenses('func()')
    end

    it 'can handle a multiline hash as second parameter' do
      expect_no_offenses(<<-END.strip_indent)
        tag(:input, {
          :value => value
        })
      END
    end

    it 'can handle method calls without parentheses' do
      expect_no_offenses('a(b c, d)')
    end

    it 'can handle other method calls without parentheses' do
      src = 'chars(Unicode.apply_mapping @wrapped_string, :uppercase)'
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it "doesn't crash and burn when there are nested issues" do
      # regression test; see GH issue 2441
      src = <<-END.strip_indent
        build(:house,
          :rooms => [
            build(:bedroom,
              :bed => build(:bed,
                :occupants => [],
                :size => "king"
              )
            )
          ]
        )
      END
      expect { inspect_source(cop, src) }.not_to raise_error
    end

    context 'method definitions' do
      it 'registers an offense for parameters with single indent' do
        expect_offense(<<-RUBY.strip_indent)
          def method(a,
            b)
            ^ Align the parameters of a method definition if they span more than one line.
          end
        RUBY
      end

      it 'registers an offense for parameters with double indent' do
        expect_offense(<<-RUBY.strip_indent)
          def method(a,
              b)
              ^ Align the parameters of a method definition if they span more than one line.
          end
        RUBY
      end

      it 'accepts parameter lists on a single line' do
        expect_no_offenses(<<-END.strip_indent)
          def method(a, b)
          end
        END
      end

      it 'accepts proper indentation' do
        expect_no_offenses(<<-END.strip_indent)
          def method(a,
                     b)
          end
        END
      end

      it 'accepts the first parameter being on a new row' do
        expect_no_offenses(<<-END.strip_indent)
          def method(
            a,
            b)
          end
        END
      end

      it 'accepts a method definition without parameters' do
        expect_no_offenses(<<-END.strip_indent)
          def method
          end
        END
      end

      it "doesn't get confused by splat" do
        expect_offense(<<-RUBY.strip_indent)
          def func2(a,
                   *b,
                   ^^ Align the parameters of a method definition if they span more than one line.
                    c)
          end
        RUBY
      end

      it 'auto-corrects alignment' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          def method(a,
              b)
          end
        END
        expect(new_source).to eq(<<-END.strip_indent)
          def method(a,
                     b)
          end
        END
      end

      context 'defining self.method' do
        it 'registers an offense for parameters with single indent' do
          expect_offense(<<-RUBY.strip_indent)
            def self.method(a,
              b)
              ^ Align the parameters of a method definition if they span more than one line.
            end
          RUBY
        end

        it 'accepts proper indentation' do
          expect_no_offenses(<<-END.strip_indent)
            def self.method(a,
                            b)
            end
          END
        end

        it 'auto-corrects alignment' do
          new_source = autocorrect_source(cop, <<-END.strip_indent)
            def self.method(a,
                b)
            end
          END
          expect(new_source).to eq(<<-END.strip_indent)
            def self.method(a,
                            b)
            end
          END
        end
      end
    end

    context 'assigned methods' do
      it 'accepts the first parameter being on a new row' do
        inspect_source(cop, <<-END.strip_margin('|'))
          | assigned_value = match(
          |   a,
          |   b,
          |   c
          | )
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts the first parameter being on method row' do
        inspect_source(cop, <<-END.strip_margin('|'))
          | assigned_value = match(a,
          |                        b,
          |                        c
          |                  )
        END
        expect(cop.offenses).to be_empty
      end
    end

    it 'auto-corrects alignment' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        func(a,
               b,
        c)
      END
      expect(new_source).to eq(<<-END.strip_indent)
        func(a,
             b,
             c)
      END
    end

    it 'auto-corrects each line of a multi-line parameter to the right' do
      new_source =
        autocorrect_source(cop, <<-END.strip_indent)
          create :transaction, :closed,
                account:          account,
                open_price:       1.29,
                close_price:      1.30
        END
      expect(new_source)
        .to eq(<<-END.strip_indent)
          create :transaction, :closed,
                 account:          account,
                 open_price:       1.29,
                 close_price:      1.30
        END
    end

    it 'auto-corrects each line of a multi-line parameter to the left' do
      new_source =
        autocorrect_source(cop, <<-END.strip_indent)
          create :transaction, :closed,
                   account:          account,
                   open_price:       1.29,
                   close_price:      1.30
        END
      expect(new_source)
        .to eq(<<-END.strip_indent)
          create :transaction, :closed,
                 account:          account,
                 open_price:       1.29,
                 close_price:      1.30
        END
    end

    it 'auto-corrects only parameters that begin a line' do
      original_source = <<-END.strip_indent
        foo(:bar, {
            whiz: 2, bang: 3 }, option: 3)
      END
      new_source = autocorrect_source(cop, original_source)
      expect(new_source).to eq(original_source)
    end

    it 'does not crash in autocorrect on dynamic string in parameter value' do
      src = <<-'END'.strip_indent
        class MyModel < ActiveRecord::Base
          has_many :other_models,
            class_name: "legacy_name",
            order: "#{legacy_name.table_name}.published DESC"

        end
      END
      new_source = autocorrect_source(cop, src)
      expect(new_source)
        .to eq <<-'END'.strip_indent
          class MyModel < ActiveRecord::Base
            has_many :other_models,
                     class_name: "legacy_name",
                     order: "#{legacy_name.table_name}.published DESC"

          end
        END
    end
  end

  context 'aligned with fixed indentation' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'with_fixed_indentation'
      }
    end

    let(:correct_source) do
      <<-END.strip_indent
        create :transaction, :closed,
          account:     account,
          open_price:  1.29,
          close_price: 1.30
      END
    end

    it 'does not autocorrect correct source' do
      expect(autocorrect_source(cop, correct_source))
        .to eq(correct_source)
    end

    it 'autocorrects by outdenting when indented too far' do
      original_source = <<-END.strip_indent
        create :transaction, :closed,
               account:     account,
               open_price:  1.29,
               close_price: 1.30
      END

      expect(autocorrect_source(cop, original_source))
        .to eq(correct_source)
    end

    it 'autocorrects by indenting when not indented' do
      original_source = <<-END.strip_indent
        create :transaction, :closed,
        account:     account,
        open_price:  1.29,
        close_price: 1.30
      END

      expect(autocorrect_source(cop, original_source))
        .to eq(correct_source)
    end

    it 'autocorrects when first line is indented' do
      original_source = <<-END.strip_margin('|')
        |  create :transaction, :closed,
        |  account:     account,
        |  open_price:  1.29,
        |  close_price: 1.30
      END

      correct_source = <<-END.strip_margin('|')
        |  create :transaction, :closed,
        |    account:     account,
        |    open_price:  1.29,
        |    close_price: 1.30
      END

      expect(autocorrect_source(cop, original_source))
        .to eq(correct_source)
    end

    context 'multi-line method calls' do
      it 'can handle existing indentation from multi-line method calls' do
        inspect_source(cop, <<-END.strip_margin('|'))
          | something
          |   .method_name(
          |     a,
          |     b,
          |     c
          |   )
        END
        expect(cop.offenses).to be_empty
      end

      it 'registers offenses for double indentation from relevant method' do
        expect_offense(<<-RUBY.strip_indent)
           something
             .method_name(
                 a,
                 ^ Use one level of indentation for parameters following the first line of a multi-line method call.
                 b,
                 ^ Use one level of indentation for parameters following the first line of a multi-line method call.
                 c
                 ^ Use one level of indentation for parameters following the first line of a multi-line method call.
             )
        RUBY
      end

      it 'does not err on method call without a method name' do
        inspect_source(cop, <<-END.strip_margin('|'))
          | something
          |   .(
          |     a,
          |     b,
          |     c
          |   )
        END
        expect(cop.offenses).to be_empty
      end

      it 'autocorrects relative to position of relevant method call' do
        original_source = <<-END.strip_margin('|')
          | something
          |   .method_name(
          |       a,
          |          b,
          |            c
          |   )
        END
        correct_source = <<-END.strip_margin('|')
          | something
          |   .method_name(
          |     a,
          |     b,
          |     c
          |   )
        END
        expect(autocorrect_source(cop, original_source))
          .to eq(correct_source)
      end
    end

    context 'method definitions' do
      it 'registers an offense for parameters aligned to first param' do
        expect_offense(<<-RUBY.strip_indent)
          def method(a,
                     b)
                     ^ Use one level of indentation for parameters following the first line of a multi-line method definition.
          end
        RUBY
      end

      it 'registers an offense for parameters with double indent' do
        expect_offense(<<-RUBY.strip_indent)
          def method(a,
              b)
              ^ Use one level of indentation for parameters following the first line of a multi-line method definition.
          end
        RUBY
      end

      it 'accepts parameter lists on a single line' do
        expect_no_offenses(<<-END.strip_indent)
          def method(a, b)
          end
        END
      end

      it 'accepts proper indentation' do
        expect_no_offenses(<<-END.strip_indent)
          def method(a,
            b)
          end
        END
      end

      it 'accepts the first parameter being on a new row' do
        expect_no_offenses(<<-END.strip_indent)
          def method(
            a,
            b)
          end
        END
      end

      it 'accepts a method definition without parameters' do
        expect_no_offenses(<<-END.strip_indent)
          def method
          end
        END
      end

      it "doesn't get confused by splat" do
        expect_offense(<<-RUBY.strip_indent)
          def func2(a,
                   *b,
                   ^^ Use one level of indentation for parameters following the first line of a multi-line method definition.
                    c)
                    ^ Use one level of indentation for parameters following the first line of a multi-line method definition.
          end
        RUBY
      end

      it 'auto-corrects alignment' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          def method(a,
              b)
          end
        END
        expect(new_source).to eq(<<-END.strip_indent)
          def method(a,
            b)
          end
        END
      end

      context 'defining self.method' do
        it 'registers an offense for parameters aligned to first param' do
          expect_offense(<<-RUBY.strip_indent)
            def self.method(a,
                            b)
                            ^ Use one level of indentation for parameters following the first line of a multi-line method definition.
            end
          RUBY
        end

        it 'accepts proper indentation' do
          expect_no_offenses(<<-END.strip_indent)
            def self.method(a,
              b)
            end
          END
        end

        it 'auto-corrects alignment' do
          new_source = autocorrect_source(cop, <<-END.strip_indent)
            def self.method(a,
                b)
            end
          END
          expect(new_source).to eq(<<-END.strip_indent)
            def self.method(a,
              b)
            end
          END
        end
      end
    end

    context 'assigned methods' do
      context 'with IndentationWidth:Width set to 4' do
        let(:indentation_width) { 4 }

        it 'accepts the first parameter being on a new row' do
          inspect_source(cop, <<-END.strip_margin('|'))
            | assigned_value = match(
            |     a,
            |     b,
            |     c
            | )
          END
          expect(cop.offenses).to be_empty
        end

        it 'accepts the first parameter being on method row' do
          inspect_source(cop, <<-END.strip_margin('|'))
            | assigned_value = match(a,
            |     b,
            |     c
            | )
          END
          expect(cop.offenses).to be_empty
        end

        it 'autocorrects even when first argument is in wrong position' do
          original_source = <<-END.strip_margin('|')
            | assigned_value = match(
            |         a,
            |            b,
            |                    c
            | )
          END

          correct_source = <<-END.strip_margin('|')
            | assigned_value = match(
            |     a,
            |     b,
            |     c
            | )
          END

          expect(autocorrect_source(cop, original_source))
            .to eq(correct_source)
        end
      end

      context 'with AlignParameters:IndentationWidth set to 4' do
        let(:config) do
          RuboCop::Config.new('Layout/AlignParameters' =>
                              cop_config.merge('IndentationWidth' => 4))
        end

        it 'accepts the first parameter being on a new row' do
          inspect_source(cop, <<-END.strip_margin('|'))
            | assigned_value = match(
            |     a,
            |     b,
            |     c
            | )
          END
          expect(cop.offenses).to be_empty
        end

        it 'accepts the first parameter being on method row' do
          inspect_source(cop, <<-END.strip_margin('|'))
            | assigned_value = match(a,
            |     b,
            |     c
            | )
          END
          expect(cop.offenses).to be_empty
        end
      end
    end
  end
end
