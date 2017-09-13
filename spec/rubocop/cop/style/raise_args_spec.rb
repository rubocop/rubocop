# frozen_string_literal: true

describe RuboCop::Cop::Style::RaiseArgs, :config do
  subject(:cop) { described_class.new(config) }

  context 'when enforced style is compact' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    context 'with a raise with 2 args' do
      it 'reports an offense' do
        inspect_source('raise RuntimeError, msg')
        expect(cop.offenses.size).to eq(1)
        expect(cop.config_to_allow_offenses)
          .to eq('EnforcedStyle' => 'exploded')
      end

      it 'auto-corrects to compact style' do
        new_source = autocorrect_source('raise RuntimeError, msg')
        expect(new_source).to eq('raise RuntimeError.new(msg)')
      end
    end

    context 'with correct + opposite' do
      it 'reports an offense' do
        inspect_source(<<-RUBY.strip_indent)
          if a
            raise RuntimeError, msg
          else
            raise Ex.new(msg)
          end
        RUBY
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages)
          .to eq(['Provide an exception object as an argument to `raise`.'])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'auto-corrects to compact style' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          if a
            raise RuntimeError, msg
          else
            raise Ex.new(msg)
          end
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          if a
            raise RuntimeError.new(msg)
          else
            raise Ex.new(msg)
          end
        RUBY
      end
    end

    context 'with a raise with 3 args' do
      it 'reports an offense' do
        expect_offense(<<-RUBY.strip_indent)
          raise RuntimeError, msg, caller
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
        RUBY
      end

      it 'does not auto-correct to compact style' do
        initial_source = 'raise RuntimeError, msg, caller'

        new_source = autocorrect_source([initial_source])
        expect(new_source).to eq(initial_source)
      end
    end

    it 'accepts a raise with msg argument' do
      expect_no_offenses('raise msg')
    end

    it 'accepts a raise with an exception argument' do
      expect_no_offenses('raise Ex.new(msg)')
    end
  end

  context 'when enforced style is exploded' do
    let(:cop_config) { { 'EnforcedStyle' => 'exploded' } }

    context 'with a raise with exception object' do
      context 'with one argument' do
        it 'reports an offense' do
          inspect_source('raise Ex.new(msg)')
          expect(cop.offenses.size).to eq(1)
          expect(cop.messages)
            .to eq(['Provide an exception class and message ' \
                    'as arguments to `raise`.'])
          expect(cop.config_to_allow_offenses)
            .to eq('EnforcedStyle' => 'compact')
        end

        it 'auto-corrects to exploded style' do
          new_source = autocorrect_source(['raise Ex.new(msg)'])
          expect(new_source).to eq('raise Ex, msg')
        end
      end

      context 'with no arguments' do
        it 'reports an offense' do
          inspect_source('raise Ex.new')
          expect(cop.offenses.size).to eq(1)
          expect(cop.messages)
            .to eq(['Provide an exception class and message ' \
                    'as arguments to `raise`.'])
          expect(cop.config_to_allow_offenses)
            .to eq('EnforcedStyle' => 'compact')
        end

        it 'auto-corrects to exploded style' do
          new_source = autocorrect_source(['raise Ex.new'])
          expect(new_source).to eq('raise Ex')
        end
      end
    end

    context 'with opposite + correct' do
      it 'reports an offense for opposite + correct' do
        inspect_source(<<-RUBY.strip_indent)
          if a
            raise RuntimeError, msg
          else
            raise Ex.new(msg)
          end
        RUBY
        expect(cop.offenses.size).to eq(1)
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'auto-corrects to exploded style' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          if a
            raise RuntimeError, msg
          else
            raise Ex.new(msg)
          end
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          if a
            raise RuntimeError, msg
          else
            raise Ex, msg
          end
        RUBY
      end
    end

    it 'accepts exception constructor with more than 1 argument' do
      expect_no_offenses('raise MyCustomError.new(a1, a2, a3)')
    end

    it 'accepts exception constructor with keyword arguments' do
      expect_no_offenses('raise MyKwArgError.new(a: 1, b: 2)')
    end

    it 'accepts a raise with splatted arguments' do
      expect_no_offenses('raise MyCustomError.new(*args)')
    end

    it 'accepts a raise with 3 args' do
      expect_no_offenses('raise RuntimeError, msg, caller')
    end

    it 'accepts a raise with 2 args' do
      expect_no_offenses('raise RuntimeError, msg')
    end

    it 'accepts a raise with msg argument' do
      expect_no_offenses('raise msg')
    end
  end
end
