# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::UnusedMethodArgument do
  subject(:cop) { described_class.new }

  describe 'inspection' do
    before do
      inspect_source(cop, source)
    end

    context 'when a method takes multiple arguments' do
      context 'and an argument is unused' do
        let(:source) { <<-END }
          def some_method(foo, bar)
            puts bar
          end
        END

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Unused method argument - `foo`. ' \
            "If it's necessary, use `_` or `_foo` " \
            "as an argument name to indicate that it won't be used."
          )
          expect(cop.offenses.first.severity.name).to eq(:warning)
          expect(cop.offenses.first.line).to eq(1)
          expect(cop.highlights).to eq(['foo'])
        end
      end

      context 'and all the arguments are unused' do
        let(:source) { <<-END }
          def some_method(foo, bar)
          end
        END

        it 'registers offenses and suggests the use of `*`' do
          expect(cop.offenses.size).to eq(2)
          expect(cop.offenses.first.message).to eq(
            'Unused method argument - `foo`. ' \
            "If it's necessary, use `_` or `_foo` " \
            "as an argument name to indicate that it won't be used. " \
            'You can also write as `some_method(*)` if you want the method ' \
            "to accept any arguments but don't care about them.")
        end
      end
    end

    context 'when a required keyword argument is unused', ruby: 2.1 do
      let(:source) { <<-END }
        def self.some_method(foo, bar:)
          puts foo
        end
      END

      it 'registers an offense but does not suggest underscore-prefix' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.highlights).to eq(['bar'])
        expect(cop.offenses.first.message)
          .to eq('Unused method argument - `bar`.')
      end
    end

    context 'when an optional keyword argument is unused', ruby: 2 do
      let(:source) { <<-END }
        def self.some_method(foo, bar: 1)
          puts foo
        end
      END

      it 'registers an offense but does not suggest underscore-prefix' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.highlights).to eq(['bar'])
        expect(cop.offenses.first.message)
          .to eq('Unused method argument - `bar`.')
      end
    end

    context 'when a singleton method argument is unused' do
      let(:source) { <<-END }
        def self.some_method(foo)
        end
      END

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.highlights).to eq(['foo'])
      end
    end

    context 'when an underscore-prefixed method argument is unused' do
      let(:source) { <<-END }
        def some_method(_foo)
        end
      END

      it 'accepts' do
        expect(cop.offenses).to be_empty
      end
    end

    context 'when a method argument is used' do
      let(:source) { <<-END }
        def some_method(foo)
          puts foo
        end
      END

      it 'accepts' do
        expect(cop.offenses).to be_empty
      end
    end

    context 'when a variable is unused' do
      let(:source) { <<-END }
        def some_method
          foo = 1
        end
      END

      it 'does not care' do
        expect(cop.offenses).to be_empty
      end
    end

    context 'when a block argument is unused' do
      let(:source) { <<-END }
        1.times do |foo|
        end
      END

      it 'does not care' do
        expect(cop.offenses).to be_empty
      end
    end

    context 'in a method calling `super` without arguments' do
      context 'when a method argument is not used explicitly' do
        let(:source) { <<-END }
          def some_method(foo)
            super
          end
        END

        it 'accepts since the arguments are guaranteed to be the same as ' \
           "superclass' ones and the user has no control on them" do
          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'in a method calling `super` with arguments' do
      context 'when a method argument is unused' do
        let(:source) { <<-END }
          def some_method(foo)
            super(:something)
          end
        END

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.line).to eq(1)
          expect(cop.highlights).to eq(['foo'])
        end
      end
    end
  end

  describe 'auto-correction' do
    let(:corrected_source) { autocorrect_source(cop, source) }

    context 'when multiple arguments are unused' do
      let(:source) { <<-END }
        def some_method(foo, bar)
        end
      END

      let(:expected_source) { <<-END }
        def some_method(_foo, _bar)
        end
      END

      it 'adds underscore-prefix to them' do
        expect(corrected_source).to eq(expected_source)
      end
    end

    context 'when only a part of arguments is unused' do
      let(:source) { <<-END }
        def some_method(foo, bar)
          puts foo
        end
      END

      let(:expected_source) { <<-END }
        def some_method(foo, _bar)
          puts foo
        end
      END

      it 'modifies only the unused one' do
        expect(corrected_source).to eq(expected_source)
      end
    end

    context 'when there are some whitespaces around the argument' do
      let(:source) { <<-END }
        def some_method(foo,
            bar)
          puts foo
        end
      END

      let(:expected_source) { <<-END }
        def some_method(foo,
            _bar)
          puts foo
        end
      END

      it 'preserves the whitespace' do
        expect(corrected_source).to eq(expected_source)
      end
    end

    context 'when a splat argument is unused' do
      let(:source) { <<-END }
        def some_method(foo, *bar)
          puts foo
        end
      END

      let(:expected_source) { <<-END }
        def some_method(foo, *_bar)
          puts foo
        end
      END

      it 'preserves the splat' do
        expect(corrected_source).to eq(expected_source)
      end
    end

    context 'when an unused argument has default value' do
      let(:source) { <<-END }
        def some_method(foo, bar = 1)
          puts foo
        end
      END

      let(:expected_source) { <<-END }
        def some_method(foo, _bar = 1)
          puts foo
        end
      END

      it 'preserves the default value' do
        expect(corrected_source).to eq(expected_source)
      end
    end

    context 'when a keyword argument is unused', ruby: 2 do
      let(:source) { <<-END }
        def some_method(foo, bar: 1)
          puts foo
        end
      END

      it 'ignores that since modifying the name changes the method interface' do
        expect(corrected_source).to eq(source)
      end
    end
  end
end
