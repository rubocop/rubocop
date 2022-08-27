# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::RedundantLineBreak, :config do
  let(:config) do
    RuboCop::Config.new('Layout/LineLength' => { 'Max' => max_line_length },
                        'Layout/RedundantLineBreak' => { 'InspectBlocks' => inspect_blocks },
                        'Layout/SingleLineBlockChain' => {
                          'Enabled' => single_line_block_chain_enabled
                        })
  end
  let(:max_line_length) { 31 }
  let(:single_line_block_chain_enabled) { true }

  shared_examples 'common behavior' do
    context 'when Layout/SingleLineBlockChain is disabled' do
      let(:single_line_block_chain_enabled) { false }
      let(:max_line_length) { 90 }

      it 'reports an offense for a method call chained onto a single line block' do
        expect_offense(<<~RUBY)
          e.select { |i| i.cond? }
          ^^^^^^^^^^^^^^^^^^^^^^^^ Redundant line break detected.
            .join
          a = e.select { |i| i.cond? }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant line break detected.
            .join
          e.select { |i| i.cond? }
          ^^^^^^^^^^^^^^^^^^^^^^^^ Redundant line break detected.
           .join + []
        RUBY
      end
    end

    context 'when Layout/SingleLineBlockChain is enabled' do
      let(:single_line_block_chain_enabled) { true }
      let(:max_line_length) { 90 }

      it 'accepts a method call chained onto a single line block' do
        expect_no_offenses(<<~RUBY)
          e.select { |i| i.cond? }
           .join
          a = e.select { |i| i.cond? }
               .join
          e.select { |i| i.cond? }
           .join + []
        RUBY
      end
    end

    context 'for an expression that fits on a single line' do
      it 'accepts an assignment containing an if expression' do
        expect_no_offenses(<<~RUBY)
          a =
            if x
              1
            else
              2
            end
        RUBY
      end

      it 'accepts an assignment containing a case expression' do
        expect_no_offenses(<<~RUBY)
          a =
            case x
            when :a
              1
            else
              2
            end
        RUBY
      end

      it 'accepts a binary expression containing an if expression' do
        expect_no_offenses(<<~RUBY)
          a +
            if x
              1
            else
              2
            end
        RUBY
      end

      it 'accepts a method call with a block' do
        expect_no_offenses(<<~RUBY)
          a do
            x
            y
          end
        RUBY
      end

      it 'accepts an assignment containing a begin-end expression' do
        expect_no_offenses(<<~RUBY)
          a ||= begin
            x
            y
          end
        RUBY
      end

      it 'accepts a method call on a single line' do
        expect_no_offenses(<<~RUBY)
          my_method(1, 2, "x")
        RUBY
      end

      it 'registers an offense for a method call on multiple lines with backslash' do
        expect_offense(<<~RUBY)
          my_method(1) \\
          ^^^^^^^^^^^^^^ Redundant line break detected.
            [:a]
        RUBY

        expect_correction(<<~RUBY)
          my_method(1) [:a]
        RUBY
      end

      context 'with LineLength Max 100' do
        let(:max_line_length) { 100 }

        it 'registers an offense for a method without parentheses on multiple lines' do
          expect_offense(<<~RUBY)
            def resolve_inheritance_from_gems(hash)
              gems = hash.delete('inherit_gem')
              (gems || {}).each_pair do |gem_name, config_path|
                if gem_name == 'rubocop'
                  raise ArgumentError,
                  ^^^^^^^^^^^^^^^^^^^^ Redundant line break detected.
                        "can't inherit configuration from the rubocop gem"
                end

                hash['inherit_from'] = Array(hash['inherit_from'])
                Array(config_path).reverse_each do |path|
                  # Put gem configuration first so local configuration overrides it.
                  hash['inherit_from'].unshift gem_config_path(gem_name, path)
                end
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            def resolve_inheritance_from_gems(hash)
              gems = hash.delete('inherit_gem')
              (gems || {}).each_pair do |gem_name, config_path|
                if gem_name == 'rubocop'
                  raise ArgumentError, "can't inherit configuration from the rubocop gem"
                end

                hash['inherit_from'] = Array(hash['inherit_from'])
                Array(config_path).reverse_each do |path|
                  # Put gem configuration first so local configuration overrides it.
                  hash['inherit_from'].unshift gem_config_path(gem_name, path)
                end
              end
            end
          RUBY
        end
      end

      it 'registers an offense for a method call on multiple lines' do
        expect_offense(<<~RUBY)
          my_method(1,
          ^^^^^^^^^^^^ Redundant line break detected.
                    2,
                    "x")
        RUBY

        expect_correction(<<~RUBY)
          my_method(1, 2, "x")
        RUBY
      end

      it 'registers an offense for a method call on multiple lines inside a block' do
        expect_offense(<<~RUBY)
          some_array.map do |something|
            my_method(
            ^^^^^^^^^^ Redundant line break detected.
              something,
            )
          end
        RUBY

        expect_correction(<<~RUBY)
          some_array.map do |something|
            my_method( something, )
          end
        RUBY
      end

      it 'accepts a method call on multiple lines if there are comments on them' do
        expect_no_offenses(<<~RUBY)
          my_method(1,
                    2,
                    "x") # X
        RUBY
      end

      it 'registers an offense for a method call with a double quoted split string in parentheses' do
        expect_offense(<<~RUBY)
          my_method("a" \\
          ^^^^^^^^^^^^^^^ Redundant line break detected.
                    "b")
        RUBY

        expect_correction(<<~RUBY)
          my_method("ab")
        RUBY
      end

      it 'registers an offense for a method call with a double quoted split string without parentheses' do
        expect_offense(<<~RUBY)
          puts "(\#{pl(i)}, " \\
          ^^^^^^^^^^^^^^^^^^^^ Redundant line break detected.
               "\#{pl(f)})"
        RUBY

        expect_correction(<<~RUBY)
          puts "(\#{pl(i)}, \#{pl(f)})"
        RUBY
      end

      it 'registers an offense for a method call with a single quoted split string' do
        expect_offense(<<~RUBY)
          my_method('a'\\
          ^^^^^^^^^^^^^^ Redundant line break detected.
                    'b')
        RUBY

        expect_correction(<<~RUBY)
          my_method('ab')
        RUBY
      end

      it 'registers an offense for a method call with a double and single quoted split string' do
        expect_offense(<<~RUBY)
          my_method("a" \\
          ^^^^^^^^^^^^^^^ Redundant line break detected.
                    'b')
          my_method('a' \\
          ^^^^^^^^^^^^^^^ Redundant line break detected.
                    "b")
        RUBY

        expect_correction(<<~RUBY)
          my_method("a" + 'b')
          my_method('a' + "b")
        RUBY
      end

      it 'registers an offense for a method call with a split operation' do
        expect_offense(<<~RUBY)
          my_method(1 +
          ^^^^^^^^^^^^^ Redundant line break detected.
                    2 +
                    3)
        RUBY

        expect_correction(<<~RUBY)
          my_method(1 + 2 + 3)
        RUBY
      end

      it 'registers an offense for a method call as right hand side of an assignment' do
        expect_offense(<<~RUBY)
          a =
          ^^^ Redundant line break detected.
            m(1 +
              2 +
              3)
          b = m(4 +
          ^^^^^^^^^ Redundant line break detected.
                5 +
                6)
          long_variable_name =
            m(7 +
            ^^^^^ Redundant line break detected.
              8 +
              9)
        RUBY

        expect_correction(<<~RUBY)
          a = m(1 + 2 + 3)
          b = m(4 + 5 + 6)
          long_variable_name =
            m(7 + 8 + 9)
        RUBY
      end

      context 'method chains' do
        it 'properly corrects a method chain on multiple lines' do
          expect_offense(<<~RUBY)
            foo(' .x')
            ^^^^^^^^^^ Redundant line break detected.
              .bar
              .baz
          RUBY

          expect_correction(<<~RUBY)
            foo(' .x').bar.baz
          RUBY
        end

        it 'registers an offense and corrects with a arguments on multiple lines' do
          expect_offense(<<~RUBY)
            foo(x,
            ^^^^^^ Redundant line break detected.
                y,
                z)
              .bar
              .baz
          RUBY

          expect_correction(<<~RUBY)
            foo(x, y, z).bar.baz
          RUBY
        end

        it 'registers an offense and corrects with a string argument on multiple lines' do
          expect_offense(<<~RUBY)
            foo('....' \\
            ^^^^^^^^^^^^ Redundant line break detected.
                '....')
              .bar
              .baz
          RUBY

          expect_correction(<<~RUBY)
            foo('........').bar.baz
          RUBY
        end

        it 'does not register an offense with a heredoc argument' do
          expect_no_offenses(<<~RUBY)
            foo(<<~EOS)
              xyz
            EOS
              .bar
              .baz
          RUBY
        end
      end
    end

    context 'for an expression that does not fit on a single line' do
      it 'accepts a method call on a multiple lines' do
        expect_no_offenses(<<~RUBY)
          my_method(11111,
                    22222,
                    "abcxyz")
          my_method(111111 +
                    222222 +
                    333333)
        RUBY
      end

      context 'with a longer max line length' do
        let(:max_line_length) { 82 }

        it 'accepts an assignment containing a method definition' do
          expect_no_offenses(<<~RUBY)
            VariableReference = Struct.new(:name) do
              def assignment?
                false
              end
            end
          RUBY
        end

        it 'accepts a method call followed by binary operations that are too long taken together' do
          expect_no_offenses(<<~RUBY)
            File.fnmatch?(
              pattern, path,
              File::FNM_PATHNAME | File::FNM_EXTGLOB
            ) && a && File.basename(path).start_with?('.') && !hidden_dir?(path)
          RUBY
          expect_no_offenses(<<~RUBY)
            File.fnmatch?(
              pattern, path,
              File::FNM_PATHNAME | File::FNM_EXTGLOB
            ) + a + File.basename(path).start_with?('.') + !hidden_dir?(path)
          RUBY
        end

        it 'accepts an assignment containing a heredoc' do
          expect_no_offenses(<<~RUBY)
            correct = lambda do
              expect_no_offenses(<<~EOT1)
                <<-EOT2
                foo
                EOT2
              EOT1
            end
          RUBY
        end

        it 'accepts a complex method call on a multiple lines' do
          expect_no_offenses(<<~RUBY)
            node.each_node(:dstr)
                .select(&:heredoc?)
                .map { |n| n.loc.heredoc_body }
                .flat_map { |b| (b.line...b.last_line).to_a }
          RUBY
        end

        it 'accepts method call with a do keyword that would just surpass the max line length' do
          expect_no_offenses(<<~RUBY)
            context 'when the configuration includes ' \\
                    'an unsafe cop that is 123456789012345678' do
            end
          RUBY
        end

        it 'registers an offense for a method call with a do keyword that is just under the max line length' do
          expect_offense(<<~RUBY)
            context 'when the configuration includes ' \\
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant line break detected.
                    'an unsafe cop that is 123456789012345' do
            end
          RUBY

          expect_correction(<<~RUBY)
            context 'when the configuration includes an unsafe cop that is 123456789012345' do
            end
          RUBY
        end

        context 'for a block' do
          it 'accepts when it is difficult to convert to single line' do
            expect_no_offenses(<<~RUBY)
              RSpec.shared_context 'ruby 2.4', :ruby24 do
                let(:ruby_version) { 2.4 }
              end
            RUBY
          end
        end
      end
    end
  end

  context 'when InspectBlocks is true' do
    let(:inspect_blocks) { true }

    include_examples 'common behavior'

    context 'for a block' do
      let(:max_line_length) { 82 }

      it 'registers an offense when the method call has parentheses' do
        expect_offense(<<~RUBY)
          RSpec.shared_context('ruby 2.4', :ruby24) do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant line break detected.
            let(:ruby_version) { 2.4 }
          end
        RUBY
      end

      it 'registers an offense when the method call has no arguments' do
        expect_offense(<<~RUBY)
          RSpec.shared_context do
          ^^^^^^^^^^^^^^^^^^^^^^^ Redundant line break detected.
            let(:ruby_version) { 2.4 }
          end
        RUBY
      end

      context 'when Layout/SingleLineBlockChain is enabled' do
        let(:single_line_block_chain_enabled) { true }

        it 'reports an offense for a multiline block without a chained method call' do
          expect_offense(<<~RUBY)
            f do
            ^^^^ Redundant line break detected.
            end
          RUBY
        end
      end

      context 'when Layout/SingleLineBlockChain is disabled' do
        let(:single_line_block_chain_enabled) { false }

        it 'reports an offense for a multiline block without a chained method call' do
          expect_offense(<<~RUBY)
            f do
            ^^^^ Redundant line break detected.
            end
          RUBY
        end

        it 'reports an offense for a method call chained onto a multiline block' do
          expect_offense(<<~RUBY)
            e.select do |i|
            ^^^^^^^^^^^^^^^ Redundant line break detected.
              i.cond?
            end.join
          RUBY
          expect_offense(<<~RUBY)
            a = e.select do |i|
            ^^^^^^^^^^^^^^^^^^^ Redundant line break detected.
              i.cond?
            end.join
          RUBY
          expect_offense(<<~RUBY)
            e.select do |i|
            ^^^^^^^^^^^^^^^ Redundant line break detected.
              i.cond?
            end.join + []
          RUBY
        end
      end
    end
  end

  context 'when InspectBlocks is false' do
    let(:inspect_blocks) { false }

    include_examples 'common behavior'

    context 'for a block' do
      let(:max_line_length) { 100 }

      it 'accepts when the method call has parentheses' do
        expect_no_offenses(<<~RUBY)
          a = RSpec.shared_context('ruby 2.4', :ruby24) do
            let(:ruby_version) { 2.4 }
          end
        RUBY
      end

      it 'accepts when the method call has no arguments' do
        expect_no_offenses(<<~RUBY)
          RSpec.shared_context do
            let(:ruby_version) { 2.4 }
          end
        RUBY
      end

      context 'when Layout/SingleLineBlockChain is enabled' do
        let(:single_line_block_chain_enabled) { true }

        it 'accepts a multiline block without a chained method call' do
          expect_no_offenses(<<~RUBY)
            f do
            end
          RUBY
        end
      end

      context 'when Layout/SingleLineBlockChain is disabled' do
        let(:single_line_block_chain_enabled) { false }

        it 'accepts a multiline block without a chained method call' do
          expect_no_offenses(<<~RUBY)
            f do
            end
          RUBY
        end

        it 'accepts a method call chained onto a multiline block' do
          expect_no_offenses(<<~RUBY)
            e.select do |i|
              i.cond?
            end.join
            a = e.select do |i|
              i.cond?
            end.join
            e.select do |i|
              i.cond?
            end.join + []
          RUBY
        end
      end
    end
  end
end
