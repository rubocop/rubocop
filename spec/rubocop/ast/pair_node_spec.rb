# frozen_string_literal: true

RSpec.describe RuboCop::AST::PairNode do
  let(:pair_node) { parse_source(source).ast.children.first }

  describe '.new' do
    let(:source) { '{ a: 1 }' }

    it { expect(pair_node.is_a?(described_class)).to be(true) }
  end

  describe '#hash_rocket?' do
    context 'when using a hash rocket delimiter' do
      let(:source) { '{ a => 1 }' }

      it { expect(pair_node.hash_rocket?).to be_truthy }
    end

    context 'when using a colon delimiter' do
      let(:source) { '{ a: 1 }' }

      it { expect(pair_node.hash_rocket?).to be_falsey }
    end
  end

  describe '#colon?' do
    context 'when using a hash rocket delimiter' do
      let(:source) { '{ a => 1 }' }

      it { expect(pair_node.colon?).to be_falsey }
    end

    context 'when using a colon delimiter' do
      let(:source) { '{ a: 1 }' }

      it { expect(pair_node.colon?).to be_truthy }
    end
  end

  describe '#colon?' do
    context 'when using a hash rocket delimiter' do
      let(:source) { '{ a => 1 }' }

      it { expect(pair_node.colon?).to be_falsey }
    end

    context 'when using a colon delimiter' do
      let(:source) { '{ a: 1 }' }

      it { expect(pair_node.colon?).to be_truthy }
    end
  end

  describe '#delimiter' do
    context 'when using a hash rocket delimiter' do
      let(:source) { '{ a => 1 }' }

      it { expect(pair_node.delimiter).to eq('=>') }
      it { expect(pair_node.delimiter(true)).to eq(' => ') }
    end

    context 'when using a colon delimiter' do
      let(:source) { '{ a: 1 }' }

      it { expect(pair_node.delimiter).to eq(':') }
      it { expect(pair_node.delimiter(true)).to eq(': ') }
    end
  end

  describe '#inverse_delimiter' do
    context 'when using a hash rocket delimiter' do
      let(:source) { '{ a => 1 }' }

      it { expect(pair_node.inverse_delimiter).to eq(':') }
      it { expect(pair_node.inverse_delimiter(true)).to eq(': ') }
    end

    context 'when using a colon delimiter' do
      let(:source) { '{ a: 1 }' }

      it { expect(pair_node.inverse_delimiter).to eq('=>') }
      it { expect(pair_node.inverse_delimiter(true)).to eq(' => ') }
    end
  end

  describe '#key' do
    context 'when using a symbol key' do
      let(:source) { '{ a: 1 }' }

      it { expect(pair_node.key.sym_type?).to be(true) }
    end

    context 'when using a string key' do
      let(:source) { "{ 'a' => 1 }" }

      it { expect(pair_node.key.str_type?).to be(true) }
    end
  end

  describe '#value' do
    let(:source) { '{ a: 1 }' }

    it { expect(pair_node.value.int_type?).to be(true) }
  end

  describe '#same_line?' do
    let(:first_pair) { parse_source(source).ast.children[0] }
    let(:second_pair) { parse_source(source).ast.children[1] }

    context 'when both pairs are on the same line' do
      context 'when both pairs are explicit pairs' do
        let(:source) do
          ['{',
           '  a: 1, b: 2',
           '}'].join("\n")
        end

        it { expect(first_pair.same_line?(second_pair)).to be_truthy }
      end

      context 'when both pair is a keyword splat' do
        let(:source) do
          ['{',
           '  a: 1, **foo',
           '}'].join("\n")
        end

        it { expect(first_pair.same_line?(second_pair)).to be_truthy }
      end
    end

    context 'when a multiline pair shares the same line' do
      context 'when both pairs are explicit pairs' do
        let(:source) do
          ['{',
           '  a: (',
           '  ), b: 2',
           '}'].join("\n")
        end

        it { expect(first_pair.same_line?(second_pair)).to be_truthy }
        it { expect(second_pair.same_line?(first_pair)).to be_truthy }
      end

      context 'when last pair is a keyword splat' do
        let(:source) do
          ['{',
           '  a: (',
           '  ), **foo',
           '}'].join("\n")
        end

        it { expect(first_pair.same_line?(second_pair)).to be_truthy }
        it { expect(second_pair.same_line?(first_pair)).to be_truthy }
      end
    end

    context 'when pairs are on separate lines' do
      context 'when both pairs are explicit pairs' do
        let(:source) do
          ['{',
           '  a: 1,',
           '  b: 2',
           '}'].join("\n")
        end

        it { expect(first_pair.same_line?(second_pair)).to be_falsey }
      end

      context 'when last pair is a keyword splat' do
        let(:source) do
          ['{',
           '  a: 1,',
           '  **foo',
           '}'].join("\n")
        end

        it { expect(first_pair.same_line?(second_pair)).to be_falsey }
      end
    end
  end

  describe '#key_delta' do
    let(:first_pair) { parse_source(source).ast.children[0] }
    let(:second_pair) { parse_source(source).ast.children[1] }

    context 'with alignment set to :left' do
      context 'when using colon delimiters' do
        context 'when keys are aligned' do
          context 'when both pairs are explicit pairs' do
            let(:source) do
              ['{',
               '  a: 1,',
               '  b: 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(0) }
          end

          context 'when second pair is a keyword splat' do
            let(:source) do
              ['{',
               '  a: 1,',
               '  **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(0) }
          end
        end

        context 'when receiver key is behind' do
          context 'when both pairs are reail pairs' do
            let(:source) do
              ['{',
               '  a: 1,',
               '    b: 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(-2) }
          end

          context 'when second pair is a keyword splat' do
            let(:source) do
              ['{',
               '  a: 1,',
               '    **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(-2) }
          end
        end

        context 'when receiver key is ahead' do
          context 'when both pairs are explicit pairs' do
            let(:source) do
              ['{',
               '    a: 1,',
               '  b: 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(2) }
          end

          context 'when second pair is a keyword splat' do
            let(:source) do
              ['{',
               '    a: 1,',
               '  **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(2) }
          end
        end

        context 'when both keys are on the same line' do
          context 'when both pairs are explicit pairs' do
            let(:source) do
              ['{',
               '  a: 1, b: 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(0) }
          end

          context 'when second pair is a keyword splat' do
            let(:source) do
              ['{',
               '  a: 1, **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(0) }
          end
        end
      end

      context 'when using hash rocket delimiters' do
        context 'when keys are aligned' do
          context 'when both keys are explicit keys' do
            let(:source) do
              ['{',
               '  a => 1,',
               '  b => 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(0) }
          end

          context 'when second key is a keyword splat' do
            let(:source) do
              ['{',
               '  a => 1,',
               '  **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(0) }
          end
        end

        context 'when receiver key is behind' do
          context 'when both pairs are explicit pairs' do
            let(:source) do
              ['{',
               '  a => 1,',
               '    b => 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(-2) }
          end

          context 'when second pair is a keyword splat' do
            let(:source) do
              ['{',
               '  a => 1,',
               '    **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(-2) }
          end
        end

        context 'when receiver key is ahead' do
          context 'when both pairs are explicit pairs' do
            let(:source) do
              ['{',
               '    a => 1,',
               '  b => 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(2) }
          end

          context 'when second pair is a keyword splat' do
            let(:source) do
              ['{',
               '    a => 1,',
               '  **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(2) }
          end
        end

        context 'when both keys are on the same line' do
          context 'when both pairs are explicit pairs' do
            let(:source) do
              ['{',
               '  a => 1, b => 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(0) }
          end

          context 'when second pair is a keyword splat' do
            let(:source) do
              ['{',
               '  a => 1, **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair)).to eq(0) }
          end
        end
      end
    end

    context 'with alignment set to :right' do
      context 'when using colon delimiters' do
        context 'when keys are aligned' do
          context 'when both pairs are explicit pairs' do
            let(:source) do
              ['{',
               '  a: 1,',
               '  b: 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(0) }
          end

          context 'when second pair is a keyword splat' do
            let(:source) do
              ['{',
               '  a: 1,',
               '  **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(0) }
          end
        end

        context 'when receiver key is behind' do
          context 'when both pairs are reail pairs' do
            let(:source) do
              ['{',
               '  a: 1,',
               '    b: 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(-2) }
          end

          context 'when second pair is a keyword splat' do
            let(:source) do
              ['{',
               '  a: 1,',
               '    **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(0) }
          end
        end

        context 'when receiver key is ahead' do
          context 'when both pairs are explicit pairs' do
            let(:source) do
              ['{',
               '    a: 1,',
               '  b: 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(2) }
          end

          context 'when second pair is a keyword splat' do
            let(:source) do
              ['{',
               '    a: 1,',
               '  **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(0) }
          end
        end

        context 'when both keys are on the same line' do
          context 'when both pairs are explicit pairs' do
            let(:source) do
              ['{',
               '  a: 1, b: 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(0) }
          end

          context 'when second pair is a keyword splat' do
            let(:source) do
              ['{',
               '  a: 1, **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(0) }
          end
        end
      end

      context 'when using hash rocket delimiters' do
        context 'when keys are aligned' do
          context 'when both keys are explicit keys' do
            let(:source) do
              ['{',
               '  a => 1,',
               '  b => 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(0) }
          end

          context 'when second key is a keyword splat' do
            let(:source) do
              ['{',
               '  a => 1,',
               '  **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(0) }
          end
        end

        context 'when receiver key is behind' do
          context 'when both pairs are explicit pairs' do
            let(:source) do
              ['{',
               '  a => 1,',
               '    b => 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(-2) }
          end

          context 'when second pair is a keyword splat' do
            let(:source) do
              ['{',
               '  a => 1,',
               '    **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(0) }
          end
        end

        context 'when receiver key is ahead' do
          context 'when both pairs are explicit pairs' do
            let(:source) do
              ['{',
               '    a => 1,',
               '  b => 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(2) }
          end

          context 'when second pair is a keyword splat' do
            let(:source) do
              ['{',
               '    a => 1,',
               '  **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(0) }
          end
        end

        context 'when both keys are on the same line' do
          context 'when both pairs are explicit pairs' do
            let(:source) do
              ['{',
               '  a => 1, b => 2',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(0) }
          end

          context 'when second pair is a keyword splat' do
            let(:source) do
              ['{',
               '  a => 1, **foo',
               '}'].join("\n")
            end

            it { expect(first_pair.key_delta(second_pair, :right)).to eq(0) }
          end
        end
      end
    end
  end

  describe '#value_delta' do
    let(:first_pair) { parse_source(source).ast.children[0] }
    let(:second_pair) { parse_source(source).ast.children[1] }

    context 'when using colon delimiters' do
      context 'when values are aligned' do
        context 'when both pairs are explicit pairs' do
          let(:source) do
            ['{',
             '  a: 1,',
             '  b: 2',
             '}'].join("\n")
          end

          it { expect(first_pair.value_delta(second_pair)).to eq(0) }
        end

        context 'when second pair is a keyword splat' do
          let(:source) do
            ['{',
             '  a: 1,',
             '  **foo',
             '}'].join("\n")
          end

          it { expect(first_pair.value_delta(second_pair)).to eq(0) }
        end
      end

      context 'when receiver value is behind' do
        let(:source) do
          ['{',
           '  a: 1,',
           '  b:   2',
           '}'].join("\n")
        end

        it { expect(first_pair.value_delta(second_pair)).to eq(-2) }
      end

      context 'when receiver value is ahead' do
        let(:source) do
          ['{',
           '  a:   1,',
           '  b: 2',
           '}'].join("\n")
        end

        it { expect(first_pair.value_delta(second_pair)).to eq(2) }
      end

      context 'when both pairs are on the same line' do
        let(:source) do
          ['{',
           '  a: 1, b: 2',
           '}'].join("\n")
        end

        it { expect(first_pair.value_delta(second_pair)).to eq(0) }
      end
    end

    context 'when using hash rocket delimiters' do
      context 'when values are aligned' do
        context 'when both pairs are explicit pairs' do
          let(:source) do
            ['{',
             '  a => 1,',
             '  b => 2',
             '}'].join("\n")
          end

          it { expect(first_pair.value_delta(second_pair)).to eq(0) }
        end

        context 'when second pair is a keyword splat' do
          let(:source) do
            ['{',
             '  a => 1,',
             '  **foo',
             '}'].join("\n")
          end

          it { expect(first_pair.value_delta(second_pair)).to eq(0) }
        end
      end

      context 'when receiver value is behind' do
        let(:source) do
          ['{',
           '  a => 1,',
           '  b =>   2',
           '}'].join("\n")
        end

        it { expect(first_pair.value_delta(second_pair)).to eq(-2) }
      end

      context 'when receiver value is ahead' do
        let(:source) do
          ['{',
           '  a =>   1,',
           '  b => 2',
           '}'].join("\n")
        end

        it { expect(first_pair.value_delta(second_pair)).to eq(2) }
      end

      context 'when both pairs are on the same line' do
        let(:source) do
          ['{',
           '  a => 1, b => 2',
           '}'].join("\n")
        end

        it { expect(first_pair.value_delta(second_pair)).to eq(0) }
      end
    end
  end
end
