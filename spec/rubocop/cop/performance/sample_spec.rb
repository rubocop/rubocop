# encoding: UTF-8

require 'spec_helper'

describe RuboCop::Cop::Performance::Sample do
  subject(:cop) { described_class.new }

  shared_examples 'registers offense' do |wrong, right|
    it "when using #{wrong} on a literal Array" do
      inspect_source(cop, "[1, 2, 3].#{wrong}")
      expect(cop.messages).to eq(["Use `#{right}` instead of `#{wrong}`."])
    end

    it "when using #{wrong} on a collection variable" do
      inspect_source(cop, ['coll = [1, 2, 3]', "coll.#{wrong}"].join("\n"))
      expect(cop.messages).to eq(["Use `#{right}` instead of `#{wrong}`."])
    end
  end

  shared_examples 'does not register offense' do |acceptable|
    it "when using #{acceptable} on a literal Array" do
      inspect_source(cop, "[1, 2, 3].#{acceptable}")
      expect(cop.messages).to be_empty
    end

    it "when using #{acceptable} on a collection variable" do
      inspect_source(cop, ['coll = [1, 2, 3]', "coll.#{acceptable}"].join("\n"))
      expect(cop.messages).to be_empty
    end
  end

  shared_examples 'corrects' do |wrong, right|
    it "#{wrong} to #{right}" do
      new_source = autocorrect_source(cop, "[1, 2, 3].#{wrong}")
      expect(new_source).to eq("[1, 2, 3].#{right}")
    end
  end

  shared_examples 'does not correct' do |acceptable|
    it acceptable do
      new_source = autocorrect_source(cop, "[1, 2, 3].#{acceptable}")
      expect(new_source).to eq("[1, 2, 3].#{acceptable}")
    end
  end

  fixes = {
    'shuffle.first'   => 'sample',
    'shuffle.last'    => 'sample',
    'shuffle[0]'      => 'sample',
    'shuffle[2]'      => 'sample',
    'shuffle[0, 3]'   => 'sample(3)',
    'shuffle[2, 3]'   => 'sample(3)',
    'shuffle[0..3]'   => 'sample(4)',
    'shuffle[0...3]'  => 'sample(3)',
    'shuffle[-4..-3]' => 'sample(2)',
    'shuffle.first(2)'   => 'sample(2)',
    'shuffle.last(3)'    => 'sample(3)',
    'shuffle.first(foo)' => 'sample(foo)',
    'shuffle.last(bar)'  => 'sample(bar)',
    'shuffle(random: Random.new).first'    => 'sample(random: Random.new)',
    'shuffle(random: Random.new).first(2)' => 'sample(2, random: Random.new)',
    'shuffle(random: foo).last(bar)'       => 'sample(bar, random: foo)',
    'shuffle(random: Random.new)[2]'       => 'sample(random: Random.new)',
    'shuffle(random: Random.new)[2, 3]'    => 'sample(3, random: Random.new)',
    'shuffle(random: Random.new)[0..3]'    => 'sample(4, random: Random.new)'
  }

  fixes.each do |wrong, right|
    it_behaves_like('registers offense', wrong, right)
    it_behaves_like('corrects',          wrong, right)
  end

  acceptables = [
    'sample',
    'shuffle',
    'shuffle[2..-3]',
    'shuffle[foo..bar]',
    'shuffle[foo, bar]',
    'shuffle(random: Random.new)',
    'shuffle.join([5, 6, 7])',
    'shuffle.map { |e| e }',
    'shuffle(random: Random.new).find(&:odd?)'
  ]

  acceptables.each do |acceptable|
    it_behaves_like('does not register offense', acceptable)
    it_behaves_like('does not correct',          acceptable)
  end
end
