# frozen_string_literal: true

describe RuboCop::AST::KeywordSplatNode do
  let(:kwsplat_node) { parse_source(source).ast.children.last }

  describe '.new' do
    let(:source) { '{ a: 1, **foo }' }

    it { expect(kwsplat_node.is_a?(described_class)).to be(true) }
  end

  describe '#hash_rocket?' do
    let(:source) { '{ a: 1, **foo }' }

    it { expect(kwsplat_node.hash_rocket?).to be_falsey }
  end

  describe '#colon?' do
    let(:source) { '{ a: 1, **foo }' }

    it { expect(kwsplat_node.colon?).to be_falsey }
  end

  describe '#key' do
    let(:source) { '{ a: 1, **foo }' }

    it { expect(kwsplat_node.key).to eq(kwsplat_node) }
  end

  describe '#value' do
    let(:source) { '{ a: 1, **foo }' }

    it { expect(kwsplat_node.value).to eq(kwsplat_node) }
  end

  describe '#operator' do
    let(:source) { '{ a: 1, **foo }' }

    it { expect(kwsplat_node.operator).to eq('**') }
  end

  describe '#same_line?' do
    let(:first_pair) { parse_source(source).ast.children[0] }
    let(:second_pair) { parse_source(source).ast.children[1] }

    context 'when both pairs are on the same line' do
      let(:source) do
        ['{',
         '  a: 1, **foo',
         '}'].join("\n")
      end

      it { expect(first_pair.same_line?(second_pair)).to be_truthy }
    end

    context 'when a multiline pair shares the same line' do
      let(:source) do
        ['{',
         '  a: (',
         '  ), **foo',
         '}'].join("\n")
      end

      it { expect(first_pair.same_line?(second_pair)).to be_truthy }
      it { expect(second_pair.same_line?(first_pair)).to be_truthy }
    end

    context 'when pairs are on separate lines' do
      let(:source) do
        ['{',
         '  a: 1,',
         '  **foo',
         '}'].join("\n")
      end

      it { expect(first_pair.same_line?(second_pair)).to be_falsey }
    end
  end

  describe '#key_delta' do
    let(:pair_node) { parse_source(source).ast.children[0] }
    let(:kwsplat_node) { parse_source(source).ast.children[1] }

    context 'with alignment set to :left' do
      context 'when using colon delimiters' do
        context 'when keyword splat is aligned' do
          let(:source) do
            ['{',
             '  a: 1,',
             '  **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node)).to eq(0) }
        end

        context 'when keyword splat is ahead' do
          let(:source) do
            ['{',
             '  a: 1,',
             '    **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node)).to eq(2) }
        end

        context 'when keyword splat is behind' do
          let(:source) do
            ['{',
             '    a: 1,',
             '  **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node)).to eq(-2) }
        end

        context 'when keyword splat is on the same line' do
          let(:source) do
            ['{',
             '  a: 1, **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node)).to eq(0) }
        end
      end

      context 'when using hash rocket delimiters' do
        context 'when keyword splat is aligned' do
          let(:source) do
            ['{',
             '  a => 1,',
             '  **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node)).to eq(0) }
        end

        context 'when keyword splat is ahead' do
          let(:source) do
            ['{',
             '  a => 1,',
             '    **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node)).to eq(2) }
        end

        context 'when keyword splat is behind' do
          let(:source) do
            ['{',
             '    a => 1,',
             '  **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node)).to eq(-2) }
        end

        context 'when keyword splat is on the same line' do
          let(:source) do
            ['{',
             '  a => 1, **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node)).to eq(0) }
        end
      end
    end

    context 'with alignment set to :right' do
      context 'when using colon delimiters' do
        context 'when keyword splat is aligned' do
          let(:source) do
            ['{',
             '  a: 1,',
             '  **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node, :right)).to eq(0) }
        end

        context 'when keyword splat is ahead' do
          let(:source) do
            ['{',
             '  a: 1,',
             '    **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node, :right)).to eq(0) }
        end

        context 'when keyword splat is behind' do
          let(:source) do
            ['{',
             '    a: 1,',
             '  **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node, :right)).to eq(0) }
        end

        context 'when keyword splat is on the same line' do
          let(:source) do
            ['{',
             '  a: 1, **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node, :right)).to eq(0) }
        end
      end

      context 'when using hash rocket delimiters' do
        context 'when keyword splat is aligned' do
          let(:source) do
            ['{',
             '  a => 1,',
             '  **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node, :right)).to eq(0) }
        end

        context 'when keyword splat is ahead' do
          let(:source) do
            ['{',
             '  a => 1,',
             '    **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node, :right)).to eq(0) }
        end

        context 'when keyword splat is behind' do
          let(:source) do
            ['{',
             '    a => 1,',
             '  **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node, :right)).to eq(0) }
        end

        context 'when keyword splat is on the same line' do
          let(:source) do
            ['{',
             '  a => 1, **foo',
             '}'].join("\n")
          end

          it { expect(kwsplat_node.key_delta(pair_node, :right)).to eq(0) }
        end
      end
    end
  end

  describe '#value_delta' do
    let(:pair_node) { parse_source(source).ast.children[0] }
    let(:kwsplat_node) { parse_source(source).ast.children[1] }

    context 'when using colon delimiters' do
      context 'when keyword splat is left aligned' do
        let(:source) do
          ['{',
           '  a: 1,',
           '  **foo',
           '}'].join("\n")
        end

        it { expect(kwsplat_node.value_delta(pair_node)).to eq(0) }
      end

      context 'when keyword splat is ahead' do
        let(:source) do
          ['{',
           '  a: 1,',
           '       **foo',
           '}'].join("\n")
        end

        it { expect(kwsplat_node.value_delta(pair_node)).to eq(0) }
      end

      context 'when keyword splat is behind' do
        let(:source) do
          ['{',
           '  a:  1,',
           '    **foo',
           '}'].join("\n")
        end

        it { expect(kwsplat_node.value_delta(pair_node)).to eq(0) }
      end

      context 'when keyword splat is on the same line' do
        let(:source) do
          ['{',
           '  a: 1, **foo',
           '}'].join("\n")
        end

        it { expect(kwsplat_node.value_delta(pair_node)).to eq(0) }
      end
    end

    context 'when using hash rocket delimiters' do
      context 'when keyword splat is left aligned' do
        let(:source) do
          ['{',
           '  a => 1,',
           '  **foo',
           '}'].join("\n")
        end

        it { expect(kwsplat_node.value_delta(pair_node)).to eq(0) }
      end

      context 'when keyword splat is ahead' do
        let(:source) do
          ['{',
           '  a => 1,',
           '           **foo',
           '}'].join("\n")
        end

        it { expect(kwsplat_node.value_delta(pair_node)).to eq(0) }
      end

      context 'when keyword splat is behind' do
        let(:source) do
          ['{',
           '  a => 1,',
           '    **foo',
           '}'].join("\n")
        end

        it { expect(kwsplat_node.value_delta(pair_node)).to eq(0) }
      end

      context 'when keyword splat is on the same line' do
        let(:source) do
          ['{',
           '  a => 1, **foo',
           '}'].join("\n")
        end

        it { expect(kwsplat_node.value_delta(pair_node)).to eq(0) }
      end
    end
  end
end
