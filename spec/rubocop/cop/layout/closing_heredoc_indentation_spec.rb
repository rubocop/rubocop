# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ClosingHeredocIndentation do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Layout/ClosingHeredocIndentation' => cop_config)
  end
  let(:cop_config) { { 'Enabled' => true } }

  it 'accepts correctly indented closing heredoc' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Test
        def foo
          <<-SQL
            bar
          SQL
        end
      end
    RUBY
  end

  it 'accepts correctly indented closing heredoc when ' \
     'heredoc contents is after closing heredoc' do
    expect_no_offenses(<<-RUBY.strip_indent)
      include_examples :offense,
                       <<-EOS
                         foo
                           bar
                       EOS
    RUBY
  end

  it 'accepts correctly indented closing heredoc when ' \
     'heredoc contents with blank line' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def_node_matcher :eval_without_location?, <<-PATTERN
        {
          (send $(send _ $:sort ...) ${:[] :at :slice} {(int 0) (int -1)})

          (send $(send _ $:sort_by _) ${:last :first})
        }
      PATTERN
    RUBY
  end

  it 'accepts correctly indented closing heredoc when aligned at ' \
     'the beginning of method definition' do
    expect_no_offenses(<<-RUBY.strip_indent)
      include_examples :offense,
                       <<-EOS
        bar
      EOS
    RUBY
  end

  it 'accepts correctly indented closing heredoc when aligned at ' \
     'the beginning of method definition and using `strip_indent`' do
    expect_no_offenses(<<-RUBY.strip_indent)
      include_examples :offense,
                       <<-EOS.strip_indent
        bar
      EOS
    RUBY
  end

  it 'accepts correctly indented closing heredoc when aligned at ' \
     'the beginning of method definition and content is empty' do
    expect_no_offenses(<<-RUBY.strip_indent)
      let(:source) { <<-EOS.strip_indent }
      EOS
    RUBY
  end

  it 'accepts correctly indented closing heredoc when ' \
     'heredoc contents is before closing heredoc' do
    expect_no_offenses(<<-RUBY.strip_indent)
      include_examples :offense,
                       <<-EOS
                         foo
        bar
                         baz
                       EOS
    RUBY
  end

  it 'registers an offense for bad indentation of a closing heredoc' do
    expect_offense(<<-RUBY.strip_indent)
      class Test
        def foo
          <<-SQL
            bar
        SQL
      ^^^^^ `SQL` is not aligned with `<<-SQL`.
        end
      end
    RUBY
  end

  it 'registers an offense for incorrectly indented empty heredocs' do
    expect_offense(<<-RUBY.strip_indent)
      def foo
        <<-NIL

          NIL
      ^^^^^^^ `NIL` is not aligned with `<<-NIL`.
      end
    RUBY
  end

  it 'does not register an offense for correctly indented empty heredocs' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo
        <<-NIL

        NIL
      end
    RUBY
  end

  it 'does not register an offense for a << heredoc' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo
        <<NIL

      NIL
      end
    RUBY
  end

  describe '#autocorrect' do
    it 'corrects bad indentation' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        class Test
          def foo
            <<-SQL
              bar
          SQL
          end
        end
      RUBY
      expect(corrected).to eq <<-RUBY.strip_indent
        class Test
          def foo
            <<-SQL
              bar
            SQL
          end
        end
      RUBY
    end
  end
end
