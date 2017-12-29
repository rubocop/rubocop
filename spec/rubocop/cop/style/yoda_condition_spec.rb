# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::YodaCondition, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'EnforcedStyle' => 'all_comparison_operators' } }
  let(:error_message) { 'Reverse the order of the operands `%s`.' }

  # needed because of usage of safe navigation operator
  let(:ruby_version) { 2.3 }

  before { inspect_source(source) }

  shared_examples 'accepts' do |code|
    let(:source) { code }

    it 'does not register an offense' do
      expect(cop.offenses.empty?).to be(true)
    end
  end

  shared_examples 'offense' do |code|
    let(:source) { code }

    it "registers an offense for #{code}" do
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message).to(
        eq(format(error_message, code))
      )
    end
  end

  shared_examples 'autocorrect' do |code, corrected|
    let(:source) { code }

    it 'autocorrects code' do
      expect(autocorrect_source(source)).to eq(corrected)
    end
  end

  it_behaves_like 'accepts', 'b.value == 2'
  it_behaves_like 'accepts', 'b&.value == 2'
  it_behaves_like 'accepts', '@value == 2'
  it_behaves_like 'accepts', '@@value == 2'
  it_behaves_like 'accepts', 'b = 1; b == 2'
  it_behaves_like 'accepts', '$var == 5'
  it_behaves_like 'accepts', 'foo == "bar"'
  it_behaves_like 'accepts', 'foo[0] > "bar" || baz != "baz"'
  it_behaves_like 'accepts', 'node = last_node.parent'
  it_behaves_like 'accepts', '(first_line - second_line) > 0'
  it_behaves_like 'accepts', '5 == 6'
  it_behaves_like 'accepts', '[1, 2, 3] <=> [4, 5, 6]'
  it_behaves_like 'accepts', '!true'
  it_behaves_like 'accepts', 'not true'
  it_behaves_like 'accepts', '0 <=> val'
  it_behaves_like 'accepts', '"foo" === bar'

  it_behaves_like 'offense', '"foo" == bar'
  it_behaves_like 'offense', 'nil == bar'
  it_behaves_like 'offense', 'false == active?'
  it_behaves_like 'offense', '15 != @foo'
  it_behaves_like 'offense', '42 < bar'

  context 'autocorrection' do
    it_behaves_like(
      'autocorrect', 'if 10 == my_var; end', 'if my_var == 10; end'
    )

    it_behaves_like(
      'autocorrect', 'if 2 < bar;end', 'if bar > 2;end'
    )

    it_behaves_like(
      'autocorrect', 'foo = 42 if 42 > bar', 'foo = 42 if bar < 42'
    )

    it_behaves_like(
      'autocorrect', '42 <= foo ? bar : baz', 'foo >= 42 ? bar : baz'
    )

    it_behaves_like(
      'autocorrect', '42 >= foo ? bar : baz', 'foo <= 42 ? bar : baz'
    )

    it_behaves_like(
      'autocorrect', 'nil != foo ? bar : baz', 'foo != nil ? bar : baz'
    )
  end

  context 'with EnforcedStyle: equality_operators_only' do
    let(:cop_config) { { 'EnforcedStyle' => 'equality_operators_only' } }

    it_behaves_like 'accepts', '42 < bar'
    it_behaves_like 'accepts', 'nil >= baz'
    it_behaves_like 'accepts', '3 < a && a < 5'
    it_behaves_like 'offense', '42 != answer'
    it_behaves_like 'offense', 'false == foo'
  end
end
