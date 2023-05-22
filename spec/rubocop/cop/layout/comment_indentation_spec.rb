# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::CommentIndentation, :config do
  let(:config) do
    RuboCop::Config
      .new('Layout/IndentationWidth' => { 'Width' => indentation_width },
           'Layout/CommentIndentation' => { 'AllowForAlignment' => allow_for_alignment })
  end
  let(:indentation_width) { 2 }

  shared_examples 'any allow_for_alignment' do
    context 'on outer level' do
      it 'accepts a correctly indented comment' do
        expect_no_offenses('# comment')
      end

      it 'accepts a comment that follows code' do
        expect_no_offenses('hello # comment')
      end

      it 'registers an offense and corrects a documentation comment' do
        expect_offense(<<~RUBY)
          =begin
          Doc comment
          =end
            hello
           #
           ^ Incorrect indentation detected (column 1 instead of 0).
          hi
        RUBY

        expect_correction(<<~RUBY)
          =begin
          Doc comment
          =end
            hello
          #
          hi
        RUBY
      end

      it 'registers an offense and corrects an incorrectly indented (1) comment' do
        expect_offense(<<-RUBY.strip_margin('|'))
        | # comment
        | ^^^^^^^^^ Incorrect indentation detected (column 1 instead of 0).
        RUBY

        expect_correction(<<-RUBY.strip_margin('|'))
        |# comment
        RUBY
      end

      it 'registers an offense and corrects an incorrectly indented (2) comment' do
        expect_offense(<<-RUBY.strip_margin('|'))
        |  # comment
        |  ^^^^^^^^^ Incorrect indentation detected (column 2 instead of 0).
        RUBY

        expect_correction(<<-RUBY.strip_margin('|'))
        |# comment
        RUBY
      end

      it 'registers an offense for each incorrectly indented comment' do
        expect_offense(<<~RUBY)
          # a
          ^^^ Incorrect indentation detected (column 0 instead of 2).
            # b
            ^^^ Incorrect indentation detected (column 2 instead of 4).
              # c
              ^^^ Incorrect indentation detected (column 4 instead of 0).
          # d
          def test; end
        RUBY
      end
    end

    it 'registers offenses and corrects before __END__ but not after' do
      expect_offense(<<~RUBY)
         #
         ^ Incorrect indentation detected (column 1 instead of 0).
        __END__
          #
      RUBY

      expect_correction(<<~RUBY)
        #
        __END__
          #
      RUBY
    end

    context 'around program structure keywords' do
      it 'accepts correctly indented comments' do
        expect_no_offenses(<<~RUBY)
          #
          def m
            #
            if a
              #
              b
            # this is accepted
            elsif aa
              # this is accepted
            else
              #
            end
            #
            case a
            # this is accepted
            when 0
              #
              b
            end
            # this is accepted
          rescue
          # this is accepted
          ensure
            #
          end
          #
        RUBY
      end

      context 'with a blank line following the comment' do
        it 'accepts a correctly indented comment' do
          expect_no_offenses(<<~RUBY)
            def m
              # comment

            end
          RUBY
        end
      end
    end

    context 'near various kinds of brackets' do
      it 'accepts correctly indented comments' do
        expect_no_offenses(<<~RUBY)
          #
          a = {
            #
            x: [
              1
              #
            ],
            #
            y: func(
              1
              #
            )
            #
          }
          #
        RUBY
      end

      it 'is unaffected by closing bracket that does not begin a line' do
        expect_no_offenses(<<~RUBY)
          #
          result = []
        RUBY
      end
    end

    it 'registers an offense and corrects' do
      # FIXME
      expect_offense(<<~RUBY)
         # comment 1
         # comment 2
         # comment 3
         ^^^^^^^^^^^ Incorrect indentation detected (column 1 instead of 0).
        hash1 = { a: 0,
             # comment 4
             ^^^^^^^^^^^ Incorrect indentation detected (column 5 instead of 10).
                  bb: 1,
                  ccc: 2 }
          if a
          #
          ^ Incorrect indentation detected (column 2 instead of 4).
            b
          # this is accepted
          elsif aa
            # so is this
          elsif bb
        #
        ^ Incorrect indentation detected (column 0 instead of 4).
          else
           #
           ^ Incorrect indentation detected (column 3 instead of 4).
          end
          case a
          # this is accepted
          when 0
            # so is this
          when 1
             #
             ^ Incorrect indentation detected (column 5 instead of 4).
            b
          end
      RUBY

      expect_correction(<<~RUBY)
        # comment 1
        # comment 2
        # comment 3
        hash1 = { a: 0,
                  # comment 4
                  bb: 1,
                  ccc: 2 }
          if a
            #
            b
          # this is accepted
          elsif aa
            # so is this
          elsif bb
          #
          else
            #
          end
          case a
          # this is accepted
          when 0
            # so is this
          when 1
            #
            b
          end
      RUBY
    end
  end

  context 'when allow_for_alignment is false' do
    let(:allow_for_alignment) { false }

    include_examples 'any allow_for_alignment'

    it 'registers an offense for comments with extra indentation' do
      expect_offense(<<~RUBY)
        def compile_sequence(seq, seq_var)
          @seq_var = seq_var # Holds the name of the variable holding the AST::Node we are matching

          context.with_temp_variables do |cur_child, cur_index, previous_index|
            @cur_child_var = cur_child        # To hold the current child node
            @cur_index_var = cur_index        # To hold the current child index (always >= 0)
            @prev_index_var = previous_index  # To hold the child index before we enter the looping nodes
            @cur_index = :seq_head            # Can be any of:
                                              #   :seq_head : when the current child is actually the sequence head
                                              #   :variadic_mode : child index held by @cur_index_var
                                              #   >= 0 : when the current child index is known (from the beginning)
                                              #   < 0 : when the index is known from the end, where -1 is *past the end*,
                                              #         -2 is the last child, etc...
                                              #         This shift of 1 from standard Ruby indices is stored in DELTA
                                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Incorrect indentation detected (column 38 instead of 4).
            @in_sync = false                  # `true` iff `@cur_child_var` and `@cur_index_var` correspond to `@cur_index`
                                              # Must be true if `@cur_index` is `:variadic_mode`
                                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Incorrect indentation detected (column 38 instead of 4).
            compile_terms(seq)
          end
        end
      RUBY
    end
  end

  context 'when allow_for_alignment is true' do
    let(:allow_for_alignment) { true }

    include_examples 'any allow_for_alignment'

    it 'accepts comments with extra indentation if aligned with comment on previous line' do
      expect_no_offenses(<<~RUBY)
        def compile_sequence(seq, seq_var)
          @seq_var = seq_var # Holds the name of the variable holding the AST::Node we are matching

          context.with_temp_variables do |cur_child, cur_index, previous_index|
            @cur_child_var = cur_child        # To hold the current child node
            @cur_index_var = cur_index        # To hold the current child index (always >= 0)
            @prev_index_var = previous_index  # To hold the child index before we enter the looping nodes
            @cur_index = :seq_head            # Can be any of:
                                              #   :seq_head : when the current child is actually the sequence head
                                              #   :variadic_mode : child index held by @cur_index_var
                                              #   >= 0 : when the current child index is known (from the beginning)
                                              #   < 0 : when the index is known from the end, where -1 is *past the end*,
                                              #         -2 is the last child, etc...
                                              #         This shift of 1 from standard Ruby indices is stored in DELTA
            @in_sync = false                  # `true` iff `@cur_child_var` and `@cur_index_var` correspond to `@cur_index`
                                              # Must be true if `@cur_index` is `:variadic_mode`
            compile_terms(seq)
          end
        end
      RUBY
    end
  end

  context 'when `Layout/AccessModifierIndentation EnforcedStyle: outdent`' do
    let(:indentation_width) { 2 }
    let(:config) do
      RuboCop::Config.new(
        'Layout/AccessModifierIndentation' => {
          'Enabled' => true,
          'EnforcedStyle' => 'outdent'
        },
        'Layout/CommentIndentation' => {
          'Enabled' => true
        },
        'Layout/IndentationWidth' => {
          'Width' => indentation_width
        }
      )
    end

    it 'does not register an offense with indentation if aligned with code on previous line' do
      expect_no_offenses(<<~RUBY)
        class A
          # rubocop:disable
          def foo
          end
          # rubocop:enable

        private

          def bar
          end
        end
      RUBY
    end

    it 'registers an offense with indentation if aligned with access modifier on next line' do
      expect_offense(<<~RUBY)
        class A
          # rubocop:disable
          def foo
          end
        # rubocop:enable
        ^^^^^^^^^^^^^^^^ Incorrect indentation detected (column 0 instead of 2).
        private

          def bar
          end
        end
      RUBY
    end
  end
end
