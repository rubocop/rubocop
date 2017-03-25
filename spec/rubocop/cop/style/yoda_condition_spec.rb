# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::YodaCondition do
  subject(:cop) { described_class.new }
  subject(:error_message) { described_class::MSG }

  before { inspect_source(cop, source) }

  shared_examples 'accepts' do |code|
    let(:source) { code }

    it 'does not register an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  shared_examples 'offense' do |code, conditional|
    let(:source) { code }

    it "registers an offense for #{conditional}" do
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message).to(
        eq(format(error_message, conditional))
      )
    end
  end

  shared_examples 'autocorrected' do |code, corrected|
    let(:source) { code }
    it 'autocorrects code' do
      expect(autocorrect_source(cop, source)).to eq(corrected)
    end
  end

  it_behaves_like 'accepts', ['if foo == "bar"', 'end']
  it_behaves_like 'accepts', ['if foo[0] > "bar" || baz != "baz"', 'end']
  it_behaves_like 'accepts', ['while (node = last_node.parent)', '"foo"', 'end']
  it_behaves_like(
    'accepts', ['FOO = "const"', 'if (FOO <= 10 && bar >= 20)', 'end']
  )
  it_behaves_like(
    'accepts', ['@foo = "test"', 'if @foo != "bar" && baz <= "baz"', 'end']
  )
  it_behaves_like(
    'accepts', ['if (Foo::BAR != 10 && bar <= 1) && (z >= 1 || b != 2)', 'end']
  )
  it_behaves_like(
    'accepts', ['if (sprintf?(n) || format?(n)) && !heredoc?(n)', 'end']
  )
  it_behaves_like 'accepts', 'z = foo if foo === "bar"'
  it_behaves_like 'accepts', 'z = foo if File.exists?(foo)'
  it_behaves_like 'accepts', 'return if (chain & bad_days).empty?'
  it_behaves_like 'accepts', 'return false unless param'
  it_behaves_like 'accepts', 'return unless self[cop] && self[cop].key?(param)'
  it_behaves_like 'accepts', 'foo.remove(range, 1) if /^:/ =~ range.source'
  it_behaves_like 'accepts', 'return if %i(kwarg kwoptarg).include?(node.type)'
  it_behaves_like 'accepts', '(first_line - second_line) > 0'

  it_behaves_like 'offense', ['if "foo" == bar', 'end'], '"foo" == bar'
  it_behaves_like 'offense', ['if x == bar && nil == bar', 'end'], 'nil == bar'
  it_behaves_like 'offense', ['if false == active?', 'end'], 'false == active?'
  it_behaves_like 'offense', ['@foo = 10', 'if 15 != @foo', 'end'], '15 != @foo'
  it_behaves_like 'offense', 'foo = 42 if 42 < bar', '42 < bar'
  it_behaves_like 'offense', '42 < foo ? bar : baz', '42 < foo'

  context 'autocorrection' do
    it_behaves_like(
      'autocorrected', 'if 10 == my_var; end', 'if my_var == 10; end'
    )

    it_behaves_like(
      'autocorrected', 'if 2 < bar;end', 'if bar > 2;end'
    )

    it_behaves_like(
      'autocorrected', 'foo = 42 if 42 > bar', 'foo = 42 if bar < 42'
    )

    it_behaves_like(
      'autocorrected', '42 <= foo ? bar : baz', 'foo >= 42 ? bar : baz'
    )

    it_behaves_like(
      'autocorrected', '42 >= foo ? bar : baz', 'foo <= 42 ? bar : baz'
    )

    it_behaves_like(
      'autocorrected', 'nil != foo ? bar : baz', 'foo != nil ? bar : baz'
    )

    it_behaves_like(
      'autocorrected', 'false === foo ? bar : baz', 'foo === false ? bar : baz'
    )
  end
end
