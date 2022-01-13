# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Sample, :config do
  shared_examples 'offense' do |wrong, right|
    it "registers an offense for #{wrong}" do
      expect_offense(<<~RUBY, wrong: wrong)
        [1, 2, 3].%{wrong}
                  ^{wrong} Use `#{right}` instead of `#{wrong}`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].#{right}
      RUBY
    end
  end

  shared_examples 'accepts' do |acceptable|
    it "accepts #{acceptable}" do
      expect_no_offenses("[1, 2, 3].#{acceptable}")
    end
  end

  it_behaves_like('offense', 'shuffle.first', 'sample')
  it_behaves_like('offense', 'shuffle.last', 'sample')
  it_behaves_like('offense', 'shuffle[0]', 'sample')
  it_behaves_like('offense', 'shuffle[-1]', 'sample')
  context 'Ruby >= 2.7', :ruby27 do
    it_behaves_like('offense', 'shuffle[...3]', 'sample(3)')
  end

  it_behaves_like('offense', 'shuffle[0, 3]', 'sample(3)')
  it_behaves_like('offense', 'shuffle[0..3]', 'sample(4)')
  it_behaves_like('offense', 'shuffle[0...3]', 'sample(3)')
  it_behaves_like('offense', 'shuffle.first(2)', 'sample(2)')
  it_behaves_like('offense', 'shuffle.last(3)', 'sample(3)')
  it_behaves_like('offense', 'shuffle.first(foo)', 'sample(foo)')
  it_behaves_like('offense', 'shuffle.last(bar)', 'sample(bar)')
  it_behaves_like('offense', 'shuffle.at(0)', 'sample')
  it_behaves_like('offense', 'shuffle.at(-1)', 'sample')
  it_behaves_like('offense', 'shuffle.slice(0)', 'sample')
  it_behaves_like('offense', 'shuffle.slice(-1)', 'sample')
  it_behaves_like('offense', 'shuffle.slice(0, 3)', 'sample(3)')
  it_behaves_like('offense', 'shuffle.slice(0..3)', 'sample(4)')
  it_behaves_like('offense', 'shuffle.slice(0...3)', 'sample(3)')
  it_behaves_like('offense', 'shuffle(random: Random.new).first', 'sample(random: Random.new)')
  it_behaves_like('offense', 'shuffle(random: Random.new).first(2)',
                  'sample(2, random: Random.new)')
  it_behaves_like('offense', 'shuffle(random: foo).last(bar)', 'sample(bar, random: foo)')
  it_behaves_like('offense', 'shuffle(random: Random.new)[0..3]', 'sample(4, random: Random.new)')

  it_behaves_like('accepts', 'sample')
  it_behaves_like('accepts', 'shuffle')
  it_behaves_like('accepts', 'shuffle.at(2)')           # nil if coll.size < 3
  it_behaves_like('accepts', 'shuffle.at(foo)')
  it_behaves_like('accepts', 'shuffle.slice(2)')        # nil if coll.size < 3
  it_behaves_like('accepts', 'shuffle.slice(3, 3)')     # nil if coll.size < 3
  it_behaves_like('accepts', 'shuffle.slice(2..3)')     # empty if coll.size < 3
  it_behaves_like('accepts',
                  'shuffle.slice(2..-3)')               # can't compute range size
  it_behaves_like('accepts',
                  'shuffle.slice(foo..3)')              # can't compute range size
  it_behaves_like('accepts', 'shuffle.slice(-4..-3)')   # nil if coll.size < 3
  it_behaves_like('accepts', 'shuffle.slice(foo)')      # foo could be a Range
  it_behaves_like('accepts', 'shuffle.slice(foo, 3)')   # nil if coll.size < foo
  it_behaves_like('accepts', 'shuffle.slice(foo..bar)')
  it_behaves_like('accepts', 'shuffle.slice(foo, bar)')
  it_behaves_like('accepts', 'shuffle[2]')              # nil if coll.size < 3
  it_behaves_like('accepts', 'shuffle[3, 3]')           # nil if coll.size < 3
  it_behaves_like('accepts', 'shuffle[2..3]')           # empty if coll.size < 3
  it_behaves_like('accepts', 'shuffle[2..-3]')          # can't compute range size
  it_behaves_like('accepts', 'shuffle[foo..3]')         # can't compute range size
  context 'Ruby >= 2.6', :ruby26 do
    it_behaves_like('accepts', 'shuffle[3..]')          # can't compute range size
    it_behaves_like('accepts', 'shuffle[3...]')         # can't compute range size
  end

  it_behaves_like('accepts', 'shuffle[-4..-3]')         # nil if coll.size < 3
  it_behaves_like('accepts', 'shuffle[foo]')            # foo could be a Range
  it_behaves_like('accepts', 'shuffle[foo, 3]')         # nil if coll.size < foo
  it_behaves_like('accepts', 'shuffle[foo..bar]')
  it_behaves_like('accepts', 'shuffle[foo, bar]')
  it_behaves_like('accepts', 'shuffle(random: Random.new)')
  it_behaves_like('accepts', 'shuffle.join([5, 6, 7])')
  it_behaves_like('accepts', 'shuffle.map { |e| e }')
  it_behaves_like('accepts', 'shuffle(random: Random.new)[2]')
  it_behaves_like('accepts', 'shuffle(random: Random.new)[2, 3]')
  it_behaves_like('accepts', 'shuffle(random: Random.new).find(&:odd?)')
end
