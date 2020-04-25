# frozen_string_literal: true
RSpec.describe RuboCop::Cop::Lint::ExplicitOperatorPrecedence, :config do
  subject(:cop) { described_class.new(config) }

  before do
    inspect_source(source)
  end

  shared_examples 'code with offense' do |code, expected = nil, offense_count = 1|
    context "when checking #{code}" do
      let(:source) { code }

      let(:offense_count) { offense_count }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(offense_count)
        expect(cop.messages).to eq(offense_count.times.map { |_| message })
      end

      if expected
        it 'auto-corrects' do
          expect(autocorrect_source(code)).to eq(expected)
        end
      else
        it 'does not auto-correct' do
          expect(autocorrect_source(code)).to eq(code)
        end
      end
    end
  end

  shared_examples 'code without offense' do |code|
    let(:source) { code }

    it 'does not register an offense' do
      expect(cop.offenses.empty?).to be(true)
    end
  end

  let(:message) { 'Operators with varied precedents used in a single statement.' }

  context 'when `&&` is used with `||` without parenthesis' do
    it_behaves_like 'code with offense', 'foo && baz || bar', '(foo && baz) || bar'
  end

  context 'when `&&` is used with `||` with parenthesis' do
    it_behaves_like 'code without offense', '(foo && baz) || bar'
  end

  context "when operators with different precedents are used without parenthesis" do
    it_behaves_like 'code with offense', 'a ** b * c / d % e + f - g << h >> i & j | k ^ l',
                    '(((((a**b) * c / d % e) + f - g) << h >> i) & j) | k ^ l', 5
  end

  context "when operators with different precedents are used with parenthesis" do
    it_behaves_like 'code without offense', '(((((a**b) * c / d % e) + f - g) << h >> i) & j) | k ^ l'
  end
end
