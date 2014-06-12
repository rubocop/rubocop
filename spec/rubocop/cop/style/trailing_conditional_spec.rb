# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::TrailingConditional do
  it 'registers offense for a trailing if' do
    code = 'a if b'

    inspect_source(subject, [code])

    expect(subject).to have_at_least(1).offenses
  end

  it 'registers offense for a trailing unless' do
    code = 'a unless b'

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

  it 'accepts an expression without trailing conditional' do
    code = <<-CODE
if true then something end
    CODE

    inspect_source(subject, [code])

    expect(subject).to have(0).offenses
  end
end
