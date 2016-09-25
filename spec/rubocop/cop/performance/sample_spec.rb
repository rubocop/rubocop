# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::Sample do
  subject(:cop) { described_class.new }

  shared_examples 'registers offense' do |wrong, right|
    it "when using #{wrong}" do
      inspect_source(cop, "[1, 2, 3].#{wrong}")
      expect(cop.messages).to eq(["Use `#{right}` instead of `#{wrong}`."])
    end
  end

  shared_examples 'accepts' do |acceptable|
    it acceptable do
      inspect_source(cop, "[1, 2, 3].#{acceptable}")
      expect(cop.messages).to be_empty
    end
  end

  shared_examples 'corrects' do |wrong, right|
    it "#{wrong} to #{right}" do
      new_source = autocorrect_source(cop, "[1, 2, 3].#{wrong}")
      expect(new_source).to eq("[1, 2, 3].#{right}")
    end
  end

  fixes = {
    'shuffle.first'      => 'sample',
    'shuffle.last'       => 'sample',
    'shuffle[0]'         => 'sample',
    'shuffle[0, 3]'      => 'sample(3)',
    'shuffle[0..3]'      => 'sample(4)',
    'shuffle[0...3]'     => 'sample(3)',
    'shuffle.first(2)'   => 'sample(2)',
    'shuffle.last(3)'    => 'sample(3)',
    'shuffle.first(foo)' => 'sample(foo)',
    'shuffle.last(bar)'  => 'sample(bar)',
    'shuffle(random: Random.new).first'    => 'sample(random: Random.new)',
    'shuffle(random: Random.new).first(2)' => 'sample(2, random: Random.new)',
    'shuffle(random: foo).last(bar)'       => 'sample(bar, random: foo)',
    'shuffle(random: Random.new)[0..3]'    => 'sample(4, random: Random.new)'
  }

  fixes.each do |wrong, right|
    it_behaves_like('registers offense', wrong, right)
    it_behaves_like('corrects',          wrong, right)
  end

  it_behaves_like('accepts', 'sample')
  it_behaves_like('accepts', 'shuffle')
  it_behaves_like('accepts', 'shuffle[2]')            # nil if coll.size < 3
  it_behaves_like('accepts', 'shuffle[3, 3]')         # nil if coll.size < 3
  it_behaves_like('accepts', 'shuffle[2..3]')         # empty if coll.size < 3
  it_behaves_like('accepts', 'shuffle[2..-3]')        # can't compute range size
  it_behaves_like('accepts', 'shuffle[foo..3]')       # can't compute range size
  it_behaves_like('accepts', 'shuffle[-4..-3]')       # nil if coll.size < 3
  it_behaves_like('accepts', 'shuffle[foo]')          # foo could be a Range
  it_behaves_like('accepts', 'shuffle[foo, 3]')       # nil if coll.size < foo
  it_behaves_like('accepts', 'shuffle[foo..bar]')
  it_behaves_like('accepts', 'shuffle[foo, bar]')
  it_behaves_like('accepts', 'shuffle(random: Random.new)')
  it_behaves_like('accepts', 'shuffle.join([5, 6, 7])')
  it_behaves_like('accepts', 'shuffle.map { |e| e }')
  it_behaves_like('accepts', 'shuffle(random: Random.new)[2]')
  it_behaves_like('accepts', 'shuffle(random: Random.new)[2, 3]')
  it_behaves_like('accepts', 'shuffle(random: Random.new).find(&:odd?)')
end
