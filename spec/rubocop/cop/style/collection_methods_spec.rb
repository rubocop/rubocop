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

  subject(:cop) { described_class.new(config) }

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

    it "registers an offense for #{method} with proc param" do
      expect_offense(<<~RUBY, method: method)
        [1, 2, 3].%{method}(&:test)
                  ^{method} Prefer `#{preferred_method}` over `#{method}`.
      RUBY
      expect_correction(<<~RUBY)
        [1, 2, 3].#{preferred_method}(&:test)
      RUBY
    end

    it "accepts #{method} with more than 1 param" do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].#{method}(other, &:test)
      RUBY
    end

    it "accepts #{method} without a block" do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].#{method}
      RUBY
    end
  end
end
