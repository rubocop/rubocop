# frozen_string_literal: true

describe RuboCop::Cop::Style::ClassAndModuleChildren, :config do
  subject(:cop) { described_class.new(config) }

  context 'nested style' do
    let(:cop_config) { { 'EnforcedStyle' => 'nested' } }

    it 'registers an offense for not nested classes' do
      inspect_source(cop, <<-END.strip_indent)
        class FooClass::BarClass
        end
      END

      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq [
        'Use nested module/class definitions instead of compact style.'
      ]
      expect(cop.highlights).to eq ['FooClass::BarClass']
    end

    it 'registers an offense for not nested classes with explicit superclass' do
      inspect_source(cop, <<-END.strip_indent)
        class FooClass::BarClass < Super
        end
      END

      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq [
        'Use nested module/class definitions instead of compact style.'
      ]
      expect(cop.highlights).to eq ['FooClass::BarClass']
    end

    it 'registers an offense for not nested modules' do
      inspect_source(cop, <<-END.strip_indent)
        module FooModule::BarModule
        end
      END

      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq [
        'Use nested module/class definitions instead of compact style.'
      ]
      expect(cop.highlights).to eq ['FooModule::BarModule']
    end

    it 'accepts nested children' do
      expect_no_offenses(<<-END.strip_indent)
        class FooClass
          class BarClass
          end
        end

        module FooModule
          module BarModule
          end
        end
      END
    end

    it 'accepts :: in parent class on inheritance' do
      expect_no_offenses(<<-END.strip_indent)
        class FooClass
          class BarClass
          end
        end

        class BazClass < FooClass::BarClass
        end
      END
    end
  end

  context 'compact style' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    it 'registers a offense for classes with nested children' do
      inspect_source(cop, <<-END.strip_indent)
        class FooClass
          class BarClass
          end
        end
      END
      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq [
        'Use compact module/class definition instead of nested style.'
      ]
      expect(cop.highlights).to eq ['FooClass']
    end

    it 'registers a offense for modules with nested children' do
      inspect_source(cop, <<-END.strip_indent)
        module FooModule
          module BarModule
          end
        end
      END
      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq [
        'Use compact module/class definition instead of nested style.'
      ]
      expect(cop.highlights).to eq ['FooModule']
    end

    it 'accepts compact style for classes/modules' do
      expect_no_offenses(<<-END.strip_indent)
        class FooClass::BarClass
        end

        module FooClass::BarModule
        end
      END
    end

    it 'accepts nesting for classes/modules with more than one child' do
      expect_no_offenses(<<-END.strip_indent)
        class FooClass
          class BarClass
          end
          class BazClass
          end
        end

        module FooModule
          module BarModule
          end
          class BazModule
          end
        end
      END
    end

    it 'accepts class/module with single method' do
      expect_no_offenses(<<-END.strip_indent)
        class FooClass
          def bar_method
          end
        end
      END
    end

    it 'accepts nesting for classes with an explicit superclass' do
      expect_no_offenses(<<-END.strip_indent)
        class FooClass < Super
          class BarClass
          end
        end
      END
    end
  end
end
