# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashEachMethods do
  subject(:cop) { described_class.new }

  context 'when node matches a keys#each or values#each' do
    context 'when receiver is a send' do
      it 'registers offense, auto-corrects foo#keys.each to foo#each_key' do
        expect_offense(<<~RUBY)
        foo.keys.each { |k| p k }
            ^^^^^^^^^ Use `each_key` instead of `keys.each`.
        RUBY

        expect_correction(<<~RUBY)
        foo.each_key { |k| p k }
        RUBY
      end

      it 'registers offense, auto-corrects foo#values.each to foo#each_value' do
        expect_offense(<<~RUBY)
        foo.values.each { |v| p v }
            ^^^^^^^^^^^ Use `each_value` instead of `values.each`.
        RUBY

        expect_correction(<<~RUBY)
        foo.each_value { |v| p v }
        RUBY
      end

      it 'does not register an offense for foo#each_key' do
        expect_no_offenses('foo.each_key { |k| p k }')
      end

      it 'does not register an offense for Hash#each_value' do
        expect_no_offenses('foo.each_value { |v| p v }')
      end
    end

    context 'when receiver is a hash literal' do
      it 'registers offense, auto-corrects {}#keys.each with {}#each_key' do
        expect_offense(<<~RUBY)
        {}.keys.each { |k| p k }
           ^^^^^^^^^ Use `each_key` instead of `keys.each`.
        RUBY

        expect_correction(<<~RUBY)
        {}.each_key { |k| p k }
        RUBY
      end

      it 'registers offense, auto-corrects {}#values.each with {}#each_value' do
        expect_offense(<<~RUBY)
        {}.values.each { |k| p k }
           ^^^^^^^^^^^ Use `each_value` instead of `values.each`.
        RUBY

        expect_correction(<<~RUBY)
        {}.each_value { |k| p k }
        RUBY
      end

      it 'does not register an offense for {}#each_key' do
        expect_no_offenses('{}.each_key { |k| p k }')
      end

      it 'does not register an offense for {}#each_value' do
        expect_no_offenses('{}.each_value { |v| p v }')
      end
    end

    context 'when receiver is implicit' do
      it 'registers an offense and auto-corrects keys.each with each_key' do
        expect_offense(<<~RUBY)
          keys.each { |k| p k }
          ^^^^^^^^^ Use `each_key` instead of `keys.each`.
        RUBY

        expect_correction(<<~RUBY)
        each_key { |k| p k }
        RUBY
      end

      it 'registers an offense and auto-corrects values.each with each_value' do
        expect_offense(<<~RUBY)
        values.each { |v| p v }
        ^^^^^^^^^^^ Use `each_value` instead of `values.each`.
        RUBY

        expect_correction(<<~RUBY)
        each_value { |v| p v }
        RUBY
      end

      it 'does not register an offense for each_key' do
        expect_no_offenses('each_key { |k| p k }')
      end

      it 'does not register an offense for each_value' do
        expect_no_offenses('each_value { |v| p v }')
      end
    end
  end
end
