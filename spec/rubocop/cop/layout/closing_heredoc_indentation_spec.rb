# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ClosingHeredocIndentation, :config do
  let(:config) { RuboCop::Config.new('Layout/ClosingHeredocIndentation' => cop_config) }
  let(:cop_config) { { 'Enabled' => true } }

  it 'accepts correctly indented closing heredoc' do
    expect_no_offenses(<<~RUBY)
      class Test
        def foo
          <<-SQL
            bar
          SQL
        end
      end
    RUBY
  end

  it 'accepts correctly indented closing heredoc when heredoc contents is after closing heredoc' do
    expect_no_offenses(<<~RUBY)
      include_examples :offense,
                       <<-EOS
                         foo
                           bar
                       EOS
    RUBY
  end

  it 'accepts correctly indented closing heredoc when heredoc contents with blank line' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :eval_without_location?, <<~PATTERN
        {
          (send $(send _ $:sort ...) ${:[] :at :slice} {(int 0) (int -1)})

          (send $(send _ $:sort_by _) ${:last :first})
        }
      PATTERN
    RUBY
  end

  it 'accepts correctly indented closing heredoc when aligned at ' \
     'the beginning of method definition' do
    expect_no_offenses(<<~RUBY)
      include_examples :offense,
                       <<-EOS
        bar
      EOS
    RUBY
  end

  it 'accepts correctly indented closing heredoc when aligned at ' \
     'the beginning of method definition and using `strip_indent`' do
    expect_no_offenses(<<~RUBY)
      include_examples :offense,
                       <<-EOS.strip_indent
        bar
      EOS
    RUBY
  end

  it 'accepts correctly indented closing heredoc when aligned at ' \
     'the beginning of method definition and content is empty' do
    expect_no_offenses(<<~RUBY)
      let(:source) { <<~EOS }
      EOS
    RUBY
  end

  it 'accepts correctly indented closing heredoc when heredoc contents is before closing heredoc' do
    expect_no_offenses(<<~RUBY)
      include_examples :offense,
                       <<-EOS
                         foo
        bar
                         baz
                       EOS
    RUBY
  end

  it 'registers an offense for bad indentation of a closing heredoc' do
    expect_offense(<<~RUBY)
      class Test
        def foo
          <<-SQL
            bar
        SQL
      ^^^^^ `SQL` is not aligned with `<<-SQL`.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Test
        def foo
          <<-SQL
            bar
          SQL
        end
      end
    RUBY
  end

  it 'registers an offense for incorrectly indented empty heredocs' do
    expect_offense(<<~RUBY)
      def foo
        <<-NIL

          NIL
      ^^^^^^^ `NIL` is not aligned with `<<-NIL`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        <<-NIL

        NIL
      end
    RUBY
  end

  it 'does not register an offense for correctly indented empty heredocs' do
    expect_no_offenses(<<~RUBY)
      def foo
        <<-NIL

        NIL
      end
    RUBY
  end

  it 'does not register an offense for a << heredoc' do
    expect_no_offenses(<<~RUBY)
      def foo
        <<NIL

      NIL
      end
    RUBY
  end
end
