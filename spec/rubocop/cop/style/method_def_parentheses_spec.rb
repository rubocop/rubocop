# frozen_string_literal: true

describe RuboCop::Cop::Style::MethodDefParentheses, :config do
  subject(:cop) { described_class.new(config) }

  context 'require_parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_parentheses' } }

    it 'reports an offense for def with parameters but no parens' do
      src = <<-END.strip_indent
        def func a, b
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' =>
                                                 'require_no_parentheses')
    end

    it 'reports an offense for correct + opposite' do
      src = <<-END.strip_indent
        def func(a, b)
        end
        def func a, b
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'reports an offense for class def with parameters but no parens' do
      src = <<-END.strip_indent
        def Test.func a, b
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts def with no args and no parens' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def func
        end
      RUBY
    end

    it 'auto-adds required parens for a def' do
      new_source = autocorrect_source(cop, 'def test param; end')
      expect(new_source).to eq('def test(param); end')
    end

    it 'auto-adds required parens for a defs' do
      new_source = autocorrect_source(cop, 'def self.test param; end')
      expect(new_source).to eq('def self.test(param); end')
    end

    it 'auto-adds required parens to argument lists on multiple lines' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        def test one,
        two
        end
      END

      expect(new_source).to eq(<<-END.strip_indent)
        def test(one,
        two)
        end
      END
    end
  end

  shared_examples :no_parentheses do
    # common to require_no_parentheses and
    # require_no_parentheses_except_multiline
    it 'reports an offense for def with parameters with parens' do
      src = <<-END.strip_indent
        def func(a, b)
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' =>
                                                 'require_parentheses')
    end

    it 'accepts a def with parameters but no parens' do
      src = <<-END.strip_indent
        def func a, b
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'reports an offense for opposite + correct' do
      src = <<-END.strip_indent
        def func(a, b)
        end
        def func a, b
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'reports an offense for class def with parameters with parens' do
      src = <<-END.strip_indent
        def Test.func(a, b)
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts a class def with parameters with parens' do
      src = <<-END.strip_indent
        def Test.func a, b
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'reports an offense for def with no args and parens' do
      src = <<-END.strip_indent
        def func()
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts def with no args and no parens' do
      src = <<-END.strip_indent
        def func
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'auto-removes the parens' do
      new_source = autocorrect_source(cop, 'def test(param); end')
      expect(new_source).to eq('def test param; end')
    end

    it 'auto-removes the parens for defs' do
      new_source = autocorrect_source(cop, 'def self.test(param); end')
      expect(new_source).to eq('def self.test param; end')
    end
  end

  context 'require_no_parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_no_parentheses' } }

    it_behaves_like :no_parentheses
  end

  context 'require_no_parentheses_except_multiline' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'require_no_parentheses_except_multiline' }
    end

    context 'when args are all on a single line' do
      it_behaves_like :no_parentheses
    end

    context 'when args span multiple lines' do
      it 'reports an offense for correct + opposite' do
        src = <<-END.strip_indent
          def func(a,
                   b)
          end
          def func a,
                   b
          end
        END
        inspect_source(cop, src)
        expect(cop.offenses.size).to eq(1)
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'auto-adds required parens to argument lists on multiple lines' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          def test one,
          two
          end
        END

        expect(new_source).to eq(<<-END.strip_indent)
          def test(one,
          two)
          end
        END
      end
    end
  end
end
