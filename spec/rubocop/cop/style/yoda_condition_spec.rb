# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::YodaCondition, :config do
  subject(:cop) { described_class.new(config) }

  let(:error_message) { 'Reverse the order of the operands `%s`.' }

  # needed because of usage of safe navigation operator
  let(:ruby_version) { 2.3 }

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

  before { inspect_source(source) }

  context 'enforce not yoda' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'forbid_for_all_comparison_operators' }
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

    context 'with EnforcedStyle: forbid_for_equality_operators_only' do
      let(:cop_config) do
        { 'EnforcedStyle' => 'forbid_for_equality_operators_only' }
      end

      it_behaves_like 'accepts', '42 < bar'
      it_behaves_like 'accepts', 'nil >= baz'
      it_behaves_like 'accepts', '3 < a && a < 5'
      it_behaves_like 'offense', '42 != answer'
      it_behaves_like 'offense', 'false == foo'
    end
  end

  context 'enforce yoda' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'require_for_all_comparison_operators' }
    end

    it_behaves_like 'accepts', '2 == b.value'
    it_behaves_like 'accepts', '2 == b&.value'
    it_behaves_like 'accepts', '2 == @value'
    it_behaves_like 'accepts', '2 == @@value'
    it_behaves_like 'accepts', 'b = 1; 2 == b'
    it_behaves_like 'accepts', '5 == $var'
    it_behaves_like 'accepts', '"bar" == foo'
    it_behaves_like 'accepts', '"bar" > foo[0] || "bar" != baz'
    it_behaves_like 'accepts', 'node = last_node.parent'
    it_behaves_like 'accepts', '0 < (first_line - second_line)'
    it_behaves_like 'accepts', '5 == 6'
    it_behaves_like 'accepts', '[1, 2, 3] <=> [4, 5, 6]'
    it_behaves_like 'accepts', '!true'
    it_behaves_like 'accepts', 'not true'
    it_behaves_like 'accepts', '0 <=> val'
    it_behaves_like 'accepts', 'bar === "foo"'

    it_behaves_like 'offense', 'bar == "foo"'
    it_behaves_like 'offense', 'bar == nil'
    it_behaves_like 'offense', 'active? == false'
    it_behaves_like 'offense', '@foo != 15'
    it_behaves_like 'offense', 'bar > 42'

    context 'autocorrection' do
      it_behaves_like(
        'autocorrect', 'if my_var == 10; end', 'if 10 == my_var; end'
      )

      it_behaves_like(
        'autocorrect', 'if bar > 2;end', 'if 2 < bar;end'
      )

      it_behaves_like(
        'autocorrect', 'foo = 42 if bar < 42', 'foo = 42 if 42 > bar'
      )

      it_behaves_like(
        'autocorrect', 'foo >= 42 ? bar : baz', '42 <= foo ? bar : baz'
      )

      it_behaves_like(
        'autocorrect', 'foo <= 42 ? bar : baz', '42 >= foo ? bar : baz'
      )

      it_behaves_like(
        'autocorrect', 'foo != nil ? bar : baz', 'nil != foo ? bar : baz'
      )
    end

    context 'with EnforcedStyle: require_for_equality_operators_only' do
      let(:cop_config) do
        { 'EnforcedStyle' => 'require_for_equality_operators_only' }
      end

      it_behaves_like 'accepts', 'bar > 42'
      it_behaves_like 'accepts', 'bar <= nil'
      it_behaves_like 'accepts', 'a > 3 && 5 > a'
      it_behaves_like 'offense', 'answer != 42'
      it_behaves_like 'offense', 'foo == false'
    end
  end
end
