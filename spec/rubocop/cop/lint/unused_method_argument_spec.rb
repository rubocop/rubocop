# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::UnusedMethodArgument do
  subject(:cop) { described_class.new }

  context 'inspection' do
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

  context 'auto-correct' do
    it 'fixes single' do
      expect(autocorrect_source(cop, <<-SOURCE
      def some_method(foo)
        super(:something)
      end
      SOURCE
      )).to eq(<<-CORRECTED_SOURCE
      def some_method(_foo)
        super(:something)
      end
      CORRECTED_SOURCE
      )
    end

    it 'fixes multiple' do
      expect(autocorrect_source(cop, <<-SOURCE
      def some_method(foo, bar)
        super(:something)
      end
      SOURCE
      )).to eq(<<-CORRECTED_SOURCE
      def some_method(_foo, _bar)
        super(:something)
      end
      CORRECTED_SOURCE
      )
    end

    it 'preserves whitespace' do
      expect(autocorrect_source(cop, <<-SOURCE
      def some_method(foo,
          bar)
        super(:something)
      end
      SOURCE
      )).to eq(<<-CORRECTED_SOURCE
      def some_method(_foo,
          _bar)
        super(:something)
      end
      CORRECTED_SOURCE
      )
    end

    it 'preserves splat' do
      expect(autocorrect_source(cop, <<-SOURCE
      def some_method(foo, *bars, baz)
        stuff(foo, baz)
      end
      SOURCE
      )).to eq(<<-CORRECTED_SOURCE
      def some_method(foo, *_bars, baz)
        stuff(foo, baz)
      end
      CORRECTED_SOURCE
      )
    end

    it 'preserves default' do
      expect(autocorrect_source(cop, <<-SOURCE
      def some_method(foo, bar = baz)
        stuff(foo)
      end
      SOURCE
      )).to eq(<<-CORRECTED_SOURCE
      def some_method(foo, _bar = baz)
        stuff(foo)
      end
      CORRECTED_SOURCE
      )
    end

    it 'preserves block reference' do
      expect(autocorrect_source(cop, <<-SOURCE
      def some_method(foo, &baz)
        stuff(foo)
      end
      SOURCE
      )).to eq(<<-CORRECTED_SOURCE
      def some_method(foo, &_baz)
        stuff(foo)
      end
      CORRECTED_SOURCE
      )
    end

    it 'ignores used' do
      original_source = <<-SOURCE
      def some_method(foo, bar)
        other_method(foo, bar)
      end
      SOURCE

      expect(autocorrect_source(cop, original_source)).to eq(original_source)
    end

    it 'ignores implicit super' do
      original_source = <<-SOURCE
      def some_method(foo, bar)
        super
      end
      SOURCE

      expect(autocorrect_source(cop, original_source)).to eq(original_source)
    end
  end
end
