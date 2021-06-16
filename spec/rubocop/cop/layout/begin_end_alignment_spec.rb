# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::BeginEndAlignment, :config do
  let(:cop_config) { { 'EnforcedStyleAlignWith' => 'begin' } }

  include_examples 'aligned', 'begin', '', 'end'

  include_examples 'misaligned', <<~RUBY, false
    begin
      end
      ^^^ `end` at 2, 2 is not aligned with `begin` at 1, 0.
  RUBY

  include_examples 'aligned', 'puts 1; begin', '', '        end'

  context 'when EnforcedStyleAlignWith is start_of_line' do
    let(:cop_config) { { 'EnforcedStyleAlignWith' => 'start_of_line' } }

    include_examples 'aligned', 'puts 1; begin', '', 'end'

    include_examples 'misaligned', <<~RUBY, false
      begin
        end
        ^^^ `end` at 2, 2 is not aligned with `begin` at 1, 0.
    RUBY

    include_examples 'misaligned', <<~RUBY, :begin
      var << begin
             end
             ^^^ `end` at 2, 7 is not aligned with `var << begin` at 1, 0.
    RUBY

    include_examples 'aligned', 'var = begin', '', 'end'
  end
end
