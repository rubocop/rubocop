# frozen_string_literal: true

RSpec.describe RuboCop::AST::StrNode do
  let(:str_node) { parse_source(source).ast }

  describe '.new' do
    context 'with a normal string' do
      let(:source) { "'foo'" }

      it { expect(str_node.is_a?(described_class)).to be(true) }
    end

    context 'with a string with interpolation' do
      let(:source) { '"#{foo}"' }

      it { expect(str_node.is_a?(described_class)).to be(true) }
    end

    context 'with a heredoc' do
      let(:source) do
        <<~RUBY
          <<-CODE
            foo
            bar
          CODE
        RUBY
      end

      it { expect(str_node.is_a?(described_class)).to be(true) }
    end
  end

  describe '#heredoc?' do
    context 'with a normal string' do
      let(:source) { "'foo'" }

      it { expect(str_node.heredoc?).to be(false) }
    end

    context 'with a string with interpolation' do
      let(:source) { '"#{foo}"' }

      it { expect(str_node.heredoc?).to be(false) }
    end

    context 'with a heredoc' do
      let(:source) do
        <<~RUBY
          <<-CODE
            foo
            bar
          CODE
        RUBY
      end

      it { expect(str_node.heredoc?).to be(true) }
    end
  end

  describe '#value' do
    context 'with a normal string' do
      let(:source) { "'foo'" }

      it { expect(str_node.value).to eq('foo') }
    end

    context 'with a string with interpolation' do
      let(:source) { '"foo #{bar} baz"' }

      it { expect(str_node.value).to eq('foo  baz') }
    end

    context 'with a heredoc' do
      let(:source) do
        <<~RUBY
          <<-CODE
            foo
            bar
          CODE
        RUBY
      end

      it { expect(str_node.value).to eq("  foo\n  bar\n") }
    end
  end
end
