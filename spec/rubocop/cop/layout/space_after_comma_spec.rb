# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceAfterComma, :config do
  let(:config) { RuboCop::Config.new('Layout/SpaceInsideHashLiteralBraces' => brace_config) }
  let(:brace_config) { {} }

  shared_examples 'ends with an item' do |items, annotation_start, correct_items|
    it 'registers an offense and does autocorrection' do
      expect_offense(<<~RUBY)
        #{source.call(items)}
        #{' ' * annotation_start}^ Space missing after comma.
      RUBY

      expect_correction(<<~RUBY)
        #{source.call(correct_items)}
      RUBY
    end
  end

  shared_examples 'trailing comma' do |items|
    it 'accepts the last comma' do
      expect_no_offenses(source.call(items))
    end
  end

  context 'block argument commas without space' do
    let(:source) { ->(items) { "each { |#{items}| }" } }

    it_behaves_like 'ends with an item', 's,t', 9, 's, t'
    it_behaves_like 'trailing comma', 's, t,'
  end

  context 'array index commas without space' do
    let(:source) { ->(items) { "formats[#{items}]" } }

    it_behaves_like 'ends with an item', '0,1', 9, '0, 1'
    it_behaves_like 'trailing comma', '0,'
  end

  context 'method call arg commas without space' do
    let(:source) { ->(args) { "a(#{args})" } }

    it_behaves_like 'ends with an item', '1,2', 3, '1, 2'
  end

  context 'inside hash braces' do
    shared_examples 'common behavior' do
      it 'accepts a space between a comma and a closing brace' do
        expect_no_offenses('{ foo:bar, }')
      end
    end

    context 'when EnforcedStyle for SpaceInsideBlockBraces is space' do
      let(:brace_config) { { 'Enabled' => true, 'EnforcedStyle' => 'space' } }

      it_behaves_like 'common behavior'

      it 'registers an offense for no space between a comma and a closing brace' do
        expect_offense(<<~RUBY)
          { foo:bar,}
                   ^ Space missing after comma.
        RUBY
      end
    end

    context 'when EnforcedStyle for SpaceInsideBlockBraces is no_space' do
      let(:brace_config) { { 'Enabled' => true, 'EnforcedStyle' => 'no_space' } }

      it_behaves_like 'common behavior'

      it 'accepts no space between a comma and a closing brace' do
        expect_no_offenses('{foo:bar,}')
      end
    end
  end
end
