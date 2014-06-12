# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::TernaryOperator do
  it 'registers offense for a ternary operator expression' do
    code = 'a = cond ? b : c'

    inspect_source(subject, [code])

    expect(subject).to have_at_least(1).offenses
  end

  it 'accepts a multi-line conditional' do
    code = <<-CODE
if true
  something
end
    CODE

    inspect_source(subject, [code])

    expect(subject).to have(0).offenses
  end
end
