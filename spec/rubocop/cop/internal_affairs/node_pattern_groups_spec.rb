# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::NodePatternGroups, :config do
  shared_examples 'node group' do |node_group, members|
    describe "`#{node_group}` node group" do
      let(:source) { members.join(' ') }
      let(:names) { members.join('`, `') }

      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY, source: source)
          def_node_matcher :my_matcher, '{%{source}}'
                                         ^^{source}^ Replace `#{names}` in node pattern union with `#{node_group}`.
        RUBY

        expect_correction(<<~RUBY)
          def_node_matcher :my_matcher, '#{node_group}'
        RUBY
      end

      it 'registers an offense and corrects with a heredoc' do
        expect_offense(<<~RUBY, source: source)
          def_node_matcher :my_matcher, <<~PATTERN
            {%{source}}
            ^^{source}^ Replace `#{names}` in node pattern union with `#{node_group}`.
          PATTERN
        RUBY

        expect_correction(<<~RUBY)
          def_node_matcher :my_matcher, <<~PATTERN
            #{node_group}
          PATTERN
        RUBY
      end
    end
  end

  it_behaves_like 'node group', 'any_block', %i[itblock numblock block]
  it_behaves_like 'node group', 'any_def', %i[def defs]
  it_behaves_like 'node group', 'argument',
                  %i[arg blockarg forward_arg kwarg kwoptarg kwrestarg optarg restarg shadowarg]
  it_behaves_like 'node group', 'boolean', %i[false true]
  it_behaves_like 'node group', 'call', %i[csend send]
  it_behaves_like 'node group', 'numeric', %i[complex float int rational]
  it_behaves_like 'node group', 'range', %i[erange irange]

  it 'can handle an invalid pattern' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :my_matcher, <<~PATTERN
        ({send csend
      PATTERN
    RUBY
  end

  # The following tests mostly use the `call` node group to avoid duplication,
  # but would apply to the others as well.
  it 'does not register an offense for `call`' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :my_matcher, 'call'
    RUBY
  end

  it 'does not register an offense for `(call)`' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :my_matcher, '(call)'
    RUBY
  end

  it 'does not register an offense when not called in `def_node_matcher` or `def_node_search`' do
    expect_no_offenses(<<~RUBY)
      '{send csend}'
    RUBY
  end

  it 'does not register an offense for `{send def}`' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :my_matcher, '{send def}'
    RUBY
  end

  it 'does not register an offense for `{csend def}`' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :my_matcher, '{csend def}'
    RUBY
  end

  it 'does not register an offense for `{call def}`' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :my_matcher, '{call def}'
    RUBY
  end

  it 'does not register an offense for `{send (csend)}' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :my_matcher, '{send (csend)}'
    RUBY
  end

  it 'does not register an offense for a dynamic pattern' do
    expect_no_offenses(<<~'RUBY')
      def_node_matcher :my_matcher, '{#{TYPES.join(' ')}}'
    RUBY
  end

  it 'does not register an offense for node types within an any-order node' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :my_matcher, '<true false>'
    RUBY
  end

  it 'does not register an offense for node types within an any-order node within a union' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :my_matcher, <<~PATTERN
        {
          <true ...>
          <false ...>
        }
      PATTERN
    RUBY
  end

  it 'registers an offense and corrects `{send csend}`' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '{send csend}'
                                     ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :my_matcher, 'call'
    RUBY
  end

  it 'registers an offense and corrects `{ send csend }`' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '{ send csend }'
                                     ^^^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :my_matcher, 'call'
    RUBY
  end

  it 'registers an offense and corrects `{csend send}`' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '{csend send}'
                                     ^^^^^^^^^^^^ Replace `csend`, `send` in node pattern union with `call`.
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :my_matcher, 'call'
    RUBY
  end

  it 'registers an offense and corrects `({send csend})`' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '({send csend})'
                                      ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :my_matcher, '(call)'
    RUBY
  end

  it 'registers an offense and corrects `{send csend def}`' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '{send csend def}'
                                     ^^^^^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :my_matcher, '{call def}'
    RUBY
  end

  it 'registers an offense and corrects `{ send csend def }`' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '{ send csend def }'
                                     ^^^^^^^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :my_matcher, '{ call def }'
    RUBY
  end

  it 'registers an offense and corrects `{send def csend}`' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '{send def csend}'
                                     ^^^^^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :my_matcher, '{call def}'
    RUBY
  end

  it 'registers an offense and corrects `{def send csend}`' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '{def send csend}'
                                     ^^^^^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :my_matcher, '{def call}'
    RUBY
  end

  it 'registers an offense and corrects multiple groups in a single union' do
    # Two offenses will actually be registered but in separate correction iterations because
    # RuboCop does not allow for multiple offenses of the same type on the same range.
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '{send csend true false}'
                                     ^^^^^^^^^^^^^^^^^^^^^^^ Replace `true`, `false` in node pattern union with `boolean`.
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :my_matcher, '{call boolean}'
    RUBY
  end

  it 'registers an offense and corrects `{send csend (def _ :foo)}`' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '{send csend (def _ :foo)}'
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :my_matcher, '{call (def _ :foo)}'
    RUBY
  end

  it 'registers an offense and corrects multiple unions inside a node' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, <<~PATTERN
        ({send csend} {send csend} ...)
                      ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
         ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
      PATTERN
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :my_matcher, <<~PATTERN
        (call call ...)
      PATTERN
    RUBY
  end

  it 'registers an offense and corrects a complex pattern' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '({send csend} (const {nil? cbase} :FileUtils) :cd ...)'
                                      ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :my_matcher, '(call (const {nil? cbase} :FileUtils) :cd ...)'
    RUBY
  end

  it 'registers offenses when there are multiple matchers' do
    expect_offense(<<~RUBY)
      def_node_matcher :matcher1, <<~PATTERN
        {send csend}
        ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
      PATTERN

      def_node_matcher :matcher2, <<~PATTERN
        (send nil !nil?)
      PATTERN

      def_node_matcher :matcher3, <<~PATTERN
        (send {send csend} _ :foo)
              ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
      PATTERN
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :matcher1, <<~PATTERN
        call
      PATTERN

      def_node_matcher :matcher2, <<~PATTERN
        (send nil !nil?)
      PATTERN

      def_node_matcher :matcher3, <<~PATTERN
        (send call _ :foo)
      PATTERN
    RUBY
  end

  context 'in heredoc' do
    it 'does not register an offense for `call`' do
      expect_no_offenses(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          call
        PATTERN
      RUBY
    end

    it 'does not register an offense for a dynamic pattern' do
      expect_no_offenses(<<~'RUBY')
        def_node_matcher :my_matcher, <<~PATTERN
          { #{TYPES.join(' ')} }
        PATTERN
      RUBY
    end

    it 'registers an offense and corrects `{send csend}`' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {csend send}
          ^^^^^^^^^^^^ Replace `csend`, `send` in node pattern union with `call`.
        PATTERN
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          call
        PATTERN
      RUBY
    end

    it 'registers an offense and corrects `{send csend}` on multiple lines' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {csend
          ^^^^^^ Replace `csend`, `send` in node pattern union with `call`.
          send}
        PATTERN
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          call
        PATTERN
      RUBY
    end

    it 'registers an offense and corrects `{send csend (def _ :foo)}` in a multiline heredoc' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {
          ^ Replace `send`, `csend` in node pattern union with `call`.
            send
            csend
            (def _ :foo)
          }
        PATTERN
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {
            call
            (def _ :foo)
          }
        PATTERN
      RUBY
    end

    it 'registers an offense and corrects `{(def _ :foo) send csend}` in a multiline heredoc' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {
          ^ Replace `send`, `csend` in node pattern union with `call`.
            (def _ :foo)
            send
            csend
          }
        PATTERN
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {
            (def _ :foo)
            call
          }
        PATTERN
      RUBY
    end
  end

  context 'in a % string' do
    it 'registers an offense and corrects with `%`' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, %[{send csend}]
                                        ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, %[call]
      RUBY
    end

    it 'registers an offense and corrects with `%q`' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, %q[{send csend}]
                                         ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, %q[call]
      RUBY
    end

    it 'registers an offense and corrects with `%Q`' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, %Q[{send csend}]
                                         ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, %Q[call]
      RUBY
    end
  end

  context 'with arguments' do
    it 'registers an offense and corrects when the arguments match' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {(send _ :foo) (csend _ :foo)}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace `(send _ :foo)`, `(csend _ :foo)` in node pattern union with `(call _ :foo)`.
        PATTERN
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          (call _ :foo)
        PATTERN
      RUBY
    end

    it 'does not register an offense if one node has arguments and the other does not' do
      expect_no_offenses(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {send (csend _ :foo)}
        PATTERN
      RUBY
    end

    it 'does not register an offense if when the nodes have different arguments' do
      expect_no_offenses(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {(send _ :foo) (csend _ :bar)}
        PATTERN
      RUBY
    end
  end

  context 'with nested arguments' do
    it 'registers an offense and corrects when the arguments match' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {(send (send ...) :foo) (csend (send ...) :foo)}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace `(send (send ...) :foo)`, `(csend (send ...) :foo)` in node pattern union with `(call (send ...) :foo)`.
        PATTERN
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          (call (send ...) :foo)
        PATTERN
      RUBY
    end
  end

  context 'union with pipes' do
    it 'registers an offense and corrects `{send | csend}`' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, '{send | csend}'
                                       ^^^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, 'call'
      RUBY
    end

    it 'registers an offense and corrects `{ send | csend }`' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, '{ send | csend }'
                                       ^^^^^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, 'call'
      RUBY
    end

    it 'registers an offense and corrects `{send | csend | def}`' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, '{send | csend | def}'
                                       ^^^^^^^^^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, '{call | def}'
      RUBY
    end

    it 'registers an offense and corrects `{ send | csend | def }`' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, '{ send | csend | def }'
                                       ^^^^^^^^^^^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, '{ call | def }'
      RUBY
    end

    it 'registers an offense and corrects `{send | csend | def} in a multiline heredoc`' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {
          ^ Replace `send`, `csend` in node pattern union with `call`.
            send |
            csend
            | def
          }
        PATTERN
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {
            call
            | def
          }
        PATTERN
      RUBY
    end

    it 'registers an offense and corrects `{send | def | csend}`' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, '{send | def | csend}'
                                       ^^^^^^^^^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, '{call | def}'
      RUBY
    end

    it 'registers an offense and corrects `{def | send | csend}`' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, '{def | send | csend}'
                                       ^^^^^^^^^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, '{def | call}'
      RUBY
    end

    it 'does not register an offense for `{(send ... csend) | def}`' do
      expect_no_offenses(<<~RUBY)
        def_node_matcher :my_matcher, '{(send ... csend) | def}'
      RUBY
    end

    it 'does not register an offense for `{(send ... lvar) | csend}`' do
      expect_no_offenses(<<~RUBY)
        def_node_matcher :my_matcher, '{(send ... lvar) | csend}'
      RUBY
    end

    it 'registers an offense for pipes with arguments and other elements' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, '{(send ...) | (csend ...) | def}'
                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace `(send ...)`, `(csend ...)` in node pattern union with `(call ...)`.
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, '{(call ...) | def}'
      RUBY
    end

    it 'registers an offense for pipes with arguments and no other elements' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, '{(send ...) | (csend ...)}'
                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace `(send ...)`, `(csend ...)` in node pattern union with `(call ...)`.
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, '(call ...)'
      RUBY
    end
  end

  context 'with nested unions' do
    it 'registers an offense and corrects for a union inside a union' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {lvar {send csend} def}
                ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
        PATTERN
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {lvar call def}
        PATTERN
      RUBY
    end

    it 'registers an offense and corrects for a union inside a node type' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          (send {send csend} ...)
                ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
        PATTERN
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          (send call ...)
        PATTERN
      RUBY
    end

    it 'registers an offense and corrects for a union inside a node type inside a union' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {
            (send {send csend} ...)
                  ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
            def
          }
        PATTERN
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {
            (send call ...)
            def
          }
        PATTERN
      RUBY
    end
  end

  context 'with sequences' do
    it 'registers an offense and corrects for a union inside a sequence' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          (send ({send csend} ...) ...)
                 ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
        PATTERN
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          (send (call ...) ...)
        PATTERN
      RUBY
    end

    it 'registers an offense and corrects for a union inside a sequence inside a union' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {
            (send ({send csend} ...) ...)
                   ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
            def
          }
        PATTERN
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, <<~PATTERN
          {
            (send (call ...) ...)
            def
          }
        PATTERN
      RUBY
    end

    it 'registers an offense and corrects for a union within a nested sequence' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, '(if _ {(send {true false} ...) | (csend {true false} ...)})'
                                                                               ^^^^^^^^^^^^ Replace `true`, `false` in node pattern union with `boolean`.
                                                    ^^^^^^^^^^^^ Replace `true`, `false` in node pattern union with `boolean`.
                                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace `(send {true false} ...)`, `(csend {true false} ...)` in node pattern union with `(call {true false} ...)`.
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, '(if _ (call boolean ...))'
      RUBY
    end
  end

  context 'with subsequences' do
    it 'does not register an offense for node types in separate sequences' do
      expect_no_offenses(<<~RUBY)
        def_node_matcher :my_matcher, '(if _ {(true) (false) | (false) (true)})'
      RUBY
    end

    it 'registers an offense and corrects for a union within a subsequence' do
      expect_offense(<<~RUBY)
        def_node_matcher :my_matcher, '(if _ ({send {true false} ... | csend {true false} ...}) ...)'
                                                                             ^^^^^^^^^^^^ Replace `true`, `false` in node pattern union with `boolean`.
                                                    ^^^^^^^^^^^^ Replace `true`, `false` in node pattern union with `boolean`.
                                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace `send {true false} ...`, `csend {true false} ...` in node pattern union with `call {true false} ...`.
      RUBY

      expect_correction(<<~RUBY)
        def_node_matcher :my_matcher, '(if _ (call boolean ...) ...)'
      RUBY
    end
  end

  it 'registers an offense and corrects `{(true) (false)}`' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '{(true) (false)}'
                                     ^^^^^^^^^^^^^^^^ Replace `(true)`, `(false)` in node pattern union with `(boolean)`.
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :my_matcher, '(boolean)'
    RUBY
  end

  it 'does not register an offense for types that make up a group but in different sequences' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :optional_option?, <<~PATTERN
        {
          (hash (pair (sym :optional) true))
          (hash (pair (sym :required) false))
        }
      PATTERN
    RUBY
  end

  it 'registers an offense and correct when called with `def_node_search`' do
    expect_offense(<<~RUBY)
      def_node_search :my_matcher, '{send csend}'
                                    ^^^^^^^^^^^^ Replace `send`, `csend` in node pattern union with `call`.
    RUBY

    expect_correction(<<~RUBY)
      def_node_search :my_matcher, 'call'
    RUBY
  end
end
