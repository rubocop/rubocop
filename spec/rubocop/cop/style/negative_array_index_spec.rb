# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NegativeArrayIndex, :config do
  shared_examples 'registers an offense for simple index' do |array_receiver, index_receiver, method_name, n|
    offense_text = "#{index_receiver}.#{method_name} - #{n}"
    offense_length = offense_text.length
    carets = '^' * offense_length
    prefix_length = "#{array_receiver}[".length
    indent = ' ' * prefix_length
    code = "#{array_receiver}[#{index_receiver}.#{method_name} - #{n}]"

    it "registers an offense for #{code}" do
      expect_offense(<<~RUBY)
        #{code}
        #{indent}#{carets} Use `#{array_receiver}[-#{n}]` instead of `#{code}`.
      RUBY

      expect_correction(<<~RUBY)
        #{array_receiver}[-#{n}]
      RUBY
    end
  end

  shared_examples 'registers an offense for bracket method call' do |code, method_name, n|
    receiver = code.match(/^([^&.]+)/)[1]
    offense_text = "#{receiver}.#{method_name} - #{n}"
    offense_length = offense_text.length
    carets = '^' * offense_length
    indent_length = code.index('(') + 1
    indent = ' ' * indent_length

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        #{code}
        #{indent}#{carets} Use `#{receiver}[-#{n}]` instead of `#{receiver}[#{receiver}.#{method_name} - #{n}]`.
      RUBY

      expect_correction(<<~RUBY)
        #{code.gsub("#{receiver}.#{method_name} - #{n}", "-#{n}")}
      RUBY
    end
  end

  shared_examples 'registers an offense for range with parentheses' do |receiver, method_name, start_val, range_op, n|
    offense_text = "(#{receiver}.#{method_name} - #{n})"
    offense_length = offense_text.length
    carets = '^' * offense_length
    prefix = "#{receiver}[(#{start_val}#{range_op}"
    indent = ' ' * prefix.length
    correction = "#{receiver}[(#{start_val}#{range_op}-#{n})]"
    code = "#{receiver}[(#{start_val}#{range_op}(#{receiver}.#{method_name} - #{n}))]"

    it "registers an offense for #{code}" do
      expect_offense(<<~RUBY)
        #{code}
        #{indent}#{carets} Use `#{correction}` instead of `#{code}`.
      RUBY

      expect_correction(<<~RUBY)
        #{correction}
      RUBY
    end
  end

  shared_examples 'registers an offense for range with parentheses but without expression parentheses' do |receiver, method_name, start_val, range_op, n|
    offense_text = "#{receiver}.#{method_name} - #{n}"
    offense_length = offense_text.length
    carets = '^' * offense_length
    prefix = "#{receiver}[(#{start_val}#{range_op}"
    indent = ' ' * prefix.length
    correction = "#{receiver}[(#{start_val}#{range_op}-#{n})]"
    code = "#{receiver}[(#{start_val}#{range_op}#{receiver}.#{method_name} - #{n})]"

    it "registers an offense for #{code}" do
      expect_offense(<<~RUBY)
        #{code}
        #{indent}#{carets} Use `#{correction}` instead of `#{code}`.
      RUBY

      expect_correction(<<~RUBY)
        #{correction}
      RUBY
    end
  end

  shared_examples 'does not register an offense' do |code|
    it "does not register an offense when using `#{code}`" do
      expect_no_offenses(<<~RUBY)
        #{code}
      RUBY
    end
  end

  it_behaves_like 'does not register an offense', 'arr[]'
  it_behaves_like 'does not register an offense', 'arr[index]'
  it_behaves_like 'does not register an offense', 'arr[1]'
  it_behaves_like 'does not register an offense', 'arr[-2]'
  it_behaves_like 'does not register an offense', 'arr[..-2]'
  it_behaves_like 'does not register an offense', "arr['_id'][1..]"

  described_class::LENGTH_METHODS.each do |method|
    method_name = method.to_s

    it_behaves_like 'does not register an offense', "arr.uniq[arr.uniq.compact.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.flatten[arr.flatten.map(&:to_s).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[other.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "@arr[@other.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "CONST[OTHER.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.compact[arr.compact.uniq.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[0..(other.#{method_name} - 2)]"
    it_behaves_like 'does not register an offense', "arr[0, other.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[arr.#{method_name} - 0]"
    it_behaves_like 'does not register an offense', "arr[arr.#{method_name} - n]"
    it_behaves_like 'does not register an offense', "arr[0, 1, arr.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[0..(arr.#{method_name} - n)]"
    it_behaves_like 'does not register an offense', "arr[0, arr.#{method_name} - n]"
    it_behaves_like 'does not register an offense', "arr[arr.method.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[arr.sort.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[0..(arr.method.#{method_name} - 2)]"
    it_behaves_like 'does not register an offense', "arr[0, arr.method.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[arr.reverse.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[arr.map(&:to_s).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[arr.#{method_name} - 2] = value"
    it_behaves_like 'does not register an offense', "arr[arr.select(&:even?).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[arr.filter_map(&:to_i).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[0..(arr.reverse.#{method_name} - 2)]"
    it_behaves_like 'does not register an offense', "arr[0...(arr.map(&:to_s).#{method_name} - 2)]"
    it_behaves_like 'does not register an offense', "arr[0, arr.reverse.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[0, arr.map(&:to_s).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.sort[0, arr.method.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[arr.chained.method.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[arr.deeply.nested.method.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[arr.#{method_name} + 2]"
    it_behaves_like 'does not register an offense', "arr[2 - arr.#{method_name}]"
    it_behaves_like 'does not register an offense', "arr[arr.#{method_name} * 2]"
    it_behaves_like 'does not register an offense', "arr[arr.#{method_name} / 2]"
    it_behaves_like 'does not register an offense', "arr[0, arr.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.map(&:to_s)[0, arr.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.select(&:even?)[0, arr.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.filter_map(&:to_i)[0, arr.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[2, arr.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[0, arr.#{method_name} - 0]"
    it_behaves_like 'does not register an offense', "arr[0..(arr.#{method_name} - 0)]"
    it_behaves_like 'does not register an offense', "arr.sort.reverse[arr.sort.map(&:to_s).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.sort.uniq[arr.sort.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.reject(&:nil?).compact[arr.reject(&:nil?).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.compact.uniq[arr.compact.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.uniq.compact[arr.uniq.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.map(&:to_s)[arr.select(&:even?).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.sort[arr.method.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.select(&:even?)[arr.reject(&:even?).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.map(&:to_i).select(&:even?)[arr.map(&:to_i).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.map(&:to_s)[arr.map(&:to_i).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.select(&:even?).reject(&:nil?)[arr.select(&:even?).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.select(&:even?).map(&:to_s)[arr.select(&:even?).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.uniq[0..(arr.uniq.#{method_name} - 2)]"
    it_behaves_like 'does not register an offense', "arr.flatten[arr.flatten.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.slice(1)[arr.slice(1).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.take(3)[arr.take(3).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.drop(2)[arr.drop(2).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.sort.flatten[arr.sort.flatten.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.reverse.slice(1)[arr.reverse.slice(1).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.shuffle.take(3)[arr.shuffle.take(3).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr.rotate.drop(2)[arr.rotate.drop(2).#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[rand(arr.#{method_name} - 2)]"
    it_behaves_like 'does not register an offense', "arr[arr.#{method_name} - 4..-1]"
    it_behaves_like 'does not register an offense', "arr.map[(0..(arr.map.#{method_name} - 2))]"
    it_behaves_like 'does not register an offense', "arr.sort[(0..(other.#{method_name} - 2))]"
    it_behaves_like 'does not register an offense', "arr[(0..(arr.#{method_name} - 0))]"
    it_behaves_like 'does not register an offense', "arr[(0..(arr.#{method_name} - (-2)))]"
    it_behaves_like 'does not register an offense', "arr[(0..(arr.#{method_name} - n))]"
    it_behaves_like 'does not register an offense', "arr.sort[(0..(arr.reverse.#{method_name} - 2))]"
    it_behaves_like 'does not register an offense', "arr[arr.#{method_name} - 2 + 1]"
    it_behaves_like 'does not register an offense', "arr[arr.#{method_name} - 2 - 1]"
    it_behaves_like 'does not register an offense', "arr[arr.#{method_name} * 2 - 2]"
    it_behaves_like 'does not register an offense', "arr[(arr.#{method_name} - 2) / 2]"
    it_behaves_like 'does not register an offense', "arr[arr.#{method_name}(1) - 2]"
    it_behaves_like 'does not register an offense', "arr[arr.select { |x| x > 0 }.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[arr[0].#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[hash[:key].#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[CONST.#{method_name} - 2]"
    it_behaves_like 'does not register an offense', "arr[(0..(arr.#{method_name} - n))]"
    it_behaves_like 'does not register an offense', "arr[(arr.method..(arr.#{method_name} - 2))]"
    it_behaves_like 'does not register an offense', "arr[(arr.map(&:to_s)..(arr.#{method_name} - 2))]"
    it_behaves_like 'does not register an offense', "arr[(arr.select(&:even?).compact..(arr.#{method_name} - 2))]"
    it_behaves_like 'does not register an offense', "arr.sort[(0..(arr.map.#{method_name} - 2))]"
    it_behaves_like 'does not register an offense', "arr.sort[(0..(other.#{method_name} - 2))]"

    it_behaves_like 'registers an offense for simple index', 'CONST', 'CONST', method_name, 2
    it_behaves_like 'registers an offense for simple index', '@arr', '@arr', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr', 'arr', method_name, 2
    it_behaves_like 'registers an offense for simple index', '@@arr.sort', '@@arr', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.sort', 'arr', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.sort', 'arr.sort', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.sort', 'arr.reverse', method_name, 2
    it_behaves_like 'registers an offense for simple index', '@arr.reverse', '@arr.reverse', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.reverse', 'arr.sort', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.shuffle', 'arr.sort', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.rotate', 'arr.reverse', method_name, 2
    it_behaves_like 'registers an offense for simple index', '@arr.reverse', '@arr.sort', method_name, 2
    it_behaves_like 'registers an offense for simple index', '@arr.reverse', '@arr', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.reverse', 'arr.reverse', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.sort', 'arr.sort', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.shuffle', 'arr.shuffle', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.rotate', 'arr.rotate', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.sort.reverse', 'arr.sort.reverse', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.sort.shuffle', 'arr.sort.shuffle', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.reverse.rotate', 'arr.reverse.rotate', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.sort.reverse', 'arr.sort', method_name, 2
    it_behaves_like 'registers an offense for simple index', 'arr.sort.reverse', 'arr.sort.reverse', method_name, 2

    it_behaves_like 'registers an offense for bracket method call', "arr.[](arr.#{method_name} - 2)", method_name, 2
    it_behaves_like 'registers an offense for bracket method call', "arr&.[](arr.#{method_name} - 2)", method_name, 2

    it_behaves_like 'registers an offense for range with parentheses', 'arr', method_name, 0, '..', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr', method_name, -5, '..', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr', method_name, 1, '...', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr', method_name, 0, '..', 100
    it_behaves_like 'registers an offense for range with parentheses', 'arr', method_name, 0, '...', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr', method_name, 2, '..', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr', method_name, 2, '...', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr', method_name, 'n', '..', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr', method_name, 'arr.sort', '..', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr', method_name, 'arr.sort.reverse', '..', 2
    it_behaves_like 'registers an offense for range with parentheses', 'CONST', method_name, 0, '..', 2
    it_behaves_like 'registers an offense for range with parentheses', '@arr', method_name, 0, '..', 2
    it_behaves_like 'registers an offense for range with parentheses', '$arr', method_name, 0, '..', 2
    it_behaves_like 'registers an offense for range with parentheses', '@@arr', method_name, 0, '..', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr.reverse', method_name, 0, '..', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr.reverse', method_name, 2, '..', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr.sort', method_name, 0, '..', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr.sort', method_name, 2, '...', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr.shuffle', method_name, 0, '..', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr.shuffle', method_name, 1, '..', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr.rotate', method_name, 0, '..', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr.rotate', method_name, 3, '...', 2
    it_behaves_like 'registers an offense for range with parentheses', 'arr.sort.reverse', method_name, 0, '..', 2

    it_behaves_like 'registers an offense for range with parentheses but without expression parentheses', 'arr', method_name, 0, '..', 2
    it_behaves_like 'registers an offense for range with parentheses but without expression parentheses', 'arr', method_name, 0, '...', 2
    it_behaves_like 'registers an offense for range with parentheses but without expression parentheses', 'arr', method_name, 2, '..', 2
    it_behaves_like 'registers an offense for range with parentheses but without expression parentheses', 'arr.sort', method_name, 0, '..', 2
    it_behaves_like 'registers an offense for range with parentheses but without expression parentheses', 'arr.reverse', method_name, 0, '..', 2
  end
end
