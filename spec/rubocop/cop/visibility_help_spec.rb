# frozen_string_literal: true

RSpec.describe RuboCop::Cop::VisibilityHelp do
  describe '#node_visibility' do
    subject do
      instance.__send__(:node_visibility, node)
    end

    let(:instance) do
      klass.new
    end

    let(:klass) do
      mod = described_class
      Class.new do
        include mod
      end
    end

    let(:node) do
      processed_source.ast.each_node(:def).first
    end

    let(:processed_source) do
      parse_source(source)
    end

    context 'without visibility block' do
      let(:source) do
        <<~RUBY
          class A
            def x; end
          end
        RUBY
      end

      it { is_expected.to eq(:public) }
    end

    context 'with visibility block public' do
      let(:source) do
        <<~RUBY
          class A
            public

            def x; end
          end
        RUBY
      end

      it { is_expected.to eq(:public) }
    end

    context 'with visibility block private' do
      let(:source) do
        <<~RUBY
          class A
            private

            def x; end
          end
        RUBY
      end

      it { is_expected.to eq(:private) }
    end

    context 'with visibility block private after public' do
      let(:source) do
        <<~RUBY
          class A
            public

            private

            def x; end
          end
        RUBY
      end

      it { is_expected.to eq(:private) }
    end

    context 'with inline public' do
      let(:source) do
        <<~RUBY
          class A
            public def x; end
          end
        RUBY
      end

      it { is_expected.to eq(:public) }
    end

    context 'with inline private' do
      let(:source) do
        <<~RUBY
          class A
            private def x; end
          end
        RUBY
      end

      it { is_expected.to eq(:private) }
    end

    context 'with inline private with symbol' do
      let(:source) do
        <<~RUBY
          class A
            def x; end
            private :x
          end
        RUBY
      end

      it { is_expected.to eq(:private) }
    end
  end
end
