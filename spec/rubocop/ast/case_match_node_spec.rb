# frozen_string_literal: true

RSpec.describe RuboCop::AST::CaseMatchNode do
  let(:case_match_node) { parse_source(source).ast }

  context 'when using Ruby 2.7 or newer', :ruby27 do
    describe '.new' do
      let(:source) do
        <<~RUBY
          case expr
          in pattern
          end
        RUBY
      end

      it { expect(case_match_node.is_a?(described_class)).to be(true) }
    end

    describe '#keyword' do
      let(:source) do
        <<~RUBY
          case expr
          in pattern
          end
        RUBY
      end

      it { expect(case_match_node.keyword).to eq('case') }
    end

    describe '#in_pattern_branches' do
      let(:source) do
        <<~RUBY
          case expr
          in pattern
          in pattern
          in pattern
          end
        RUBY
      end

      it { expect(case_match_node.in_pattern_branches.size).to eq(3) }
      it {
        expect(case_match_node.in_pattern_branches).to all(be_in_pattern_type)
      }
    end

    describe '#each_in_pattern' do
      let(:source) do
        <<~RUBY
          case expr
          in pattern
          in pattern
          in pattern
          end
        RUBY
      end

      context 'when not passed a block' do
        it {
          expect(case_match_node.each_in_pattern.is_a?(Enumerator)).to be(true)
        }
      end

      context 'when passed a block' do
        it 'yields all the conditions' do
          expect { |b| case_match_node.each_in_pattern(&b) }
            .to yield_successive_args(*case_match_node.in_pattern_branches)
        end
      end
    end

    describe '#else?' do
      context 'without an else statement' do
        let(:source) do
          <<~RUBY
            case expr
            in pattern
            end
          RUBY
        end

        it { expect(case_match_node.else?).to be(false) }
      end

      context 'with an else statement' do
        let(:source) do
          <<~RUBY
            case expr
            in pattern
            else
            end
          RUBY
        end

        it { expect(case_match_node.else?).to be(true) }
      end
    end

    describe '#else_branch' do
      describe '#else?' do
        context 'without an else statement' do
          let(:source) do
            <<~RUBY
              case expr
              in pattern
              end
            RUBY
          end

          it { expect(case_match_node.else_branch.nil?).to be(true) }
        end

        context 'with an else statement' do
          let(:source) do
            <<~RUBY
              case expr
              in pattern
              else
                :foo
              end
            RUBY
          end

          it { expect(case_match_node.else_branch.sym_type?).to be(true) }
        end
      end
    end
  end
end
