# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NextWithoutAccumulator, :config do
  shared_examples 'reduce/inject' do |reduce_alias|
    context "given a #{reduce_alias} block" do
      it 'registers an offense for a bare next' do
        expect_offense(<<~RUBY)
          (1..4).#{reduce_alias}(0) do |acc, i|
            next if i.odd?
            ^^^^ Use `next` with an accumulator argument in a `reduce`.
            acc + i
          end
        RUBY
      end

      it 'accepts next with a value' do
        expect_no_offenses(<<~RUBY)
          (1..4).#{reduce_alias}(0) do |acc, i|
            next acc if i.odd?
            acc + i
          end
        RUBY
      end

      it 'accepts next within a nested block' do
        expect_no_offenses(<<~RUBY)
          [(1..3), (4..6)].#{reduce_alias}(0) do |acc, elems|
            elems.each_with_index do |elem, i|
              next if i == 1
              acc << elem
            end
            acc
          end
        RUBY
      end

      context 'Ruby 2.7', :ruby27 do
        it 'registers an offense for a bare next' do
          expect_offense(<<~RUBY)
            (1..4).#{reduce_alias}(0) do
              next if _2.odd?
              ^^^^ Use `next` with an accumulator argument in a `reduce`.
              _1 + i
            end
          RUBY
        end
      end
    end
  end

  it_behaves_like 'reduce/inject', :reduce
  it_behaves_like 'reduce/inject', :inject

  context 'given an unrelated block' do
    it 'accepts a bare next' do
      expect_no_offenses(<<~RUBY)
        (1..4).foo(0) do |acc, i|
          next if i.odd?
          acc + i
        end
      RUBY
    end

    it 'accepts next with a value' do
      expect_no_offenses(<<~RUBY)
        (1..4).foo(0) do |acc, i|
          next acc if i.odd?
          acc + i
        end
      RUBY
    end
  end
end
