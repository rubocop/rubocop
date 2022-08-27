# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CollectionMethods, :config do
  cop_config = {
    'PreferredMethods' => {
      'collect' => 'map',
      'inject' => 'reduce',
      'detect' => 'find',
      'find_all' => 'select',
      'member?' => 'include?'
    }
  }

  let(:cop_config) { cop_config }

  cop_config['PreferredMethods'].each do |method, preferred_method|
    it "registers an offense for #{method} with block" do
      expect_offense(<<~RUBY, method: method)
        [1, 2, 3].%{method} { |e| e + 1 }
                  ^{method} Prefer `#{preferred_method}` over `#{method}`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].#{preferred_method} { |e| e + 1 }
      RUBY
    end

    context 'Ruby 2.7', :ruby27 do
      it "registers an offense for #{method} with numblock" do
        expect_offense(<<~RUBY, method: method)
          [1, 2, 3].%{method} { _1 + 1 }
                    ^{method} Prefer `#{preferred_method}` over `#{method}`.
        RUBY

        expect_correction(<<~RUBY)
          [1, 2, 3].#{preferred_method} { _1 + 1 }
        RUBY
      end
    end

    it "registers an offense for #{method} with proc param" do
      expect_offense(<<~RUBY, method: method)
        [1, 2, 3].%{method}(&:test)
                  ^{method} Prefer `#{preferred_method}` over `#{method}`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].#{preferred_method}(&:test)
      RUBY
    end

    it "registers an offense for #{method} with an argument and proc param" do
      expect_offense(<<~RUBY, method: method)
        [1, 2, 3].%{method}(0, &:test)
                  ^{method} Prefer `#{preferred_method}` over `#{method}`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].#{preferred_method}(0, &:test)
      RUBY
    end

    it "accepts #{method} without a block" do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].#{method}
      RUBY
    end
  end

  context 'for methods that accept a symbol as implicit block' do
    it 'registers an offense with a final symbol param' do
      expect_offense(<<~RUBY)
        [1, 2, 3].inject(:+)
                  ^^^^^^ Prefer `reduce` over `inject`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].reduce(:+)
      RUBY
    end

    it 'registers an offense with an argument and final symbol param' do
      expect_offense(<<~RUBY)
        [1, 2, 3].inject(0, :+)
                  ^^^^^^ Prefer `reduce` over `inject`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].reduce(0, :+)
      RUBY
    end
  end

  context 'for methods that do not accept a symbol as implicit block' do
    it 'does not register an offense for a final symbol param' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].collect(:+)
      RUBY
    end

    it 'does not register an offense for a final symbol param with extra args' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].collect(0, :+)
      RUBY
    end
  end
end
