# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashEachMethods, :config do
  context 'when node matches a keys#each or values#each' do
    context 'when receiver is a send' do
      it 'registers offense, autocorrects foo#keys.each to foo#each_key' do
        expect_offense(<<~RUBY)
          foo.keys.each { |k| p k }
              ^^^^^^^^^ Use `each_key` instead of `keys.each`.
        RUBY

        expect_correction(<<~RUBY)
          foo.each_key { |k| p k }
        RUBY
      end

      it 'registers offense, autocorrects foo#values.each to foo#each_value' do
        expect_offense(<<~RUBY)
          foo.values.each { |v| p v }
              ^^^^^^^^^^^ Use `each_value` instead of `values.each`.
        RUBY

        expect_correction(<<~RUBY)
          foo.each_value { |v| p v }
        RUBY
      end

      it 'registers offense, autocorrects foo#keys.each to foo#each_key with a symbol proc argument' do
        expect_offense(<<~RUBY)
          foo.keys.each(&:bar)
              ^^^^^^^^^ Use `each_key` instead of `keys.each`.
        RUBY

        expect_correction(<<~RUBY)
          foo.each_key(&:bar)
        RUBY
      end

      it 'registers offense, autocorrects foo#values.each to foo#each_value with a symbol proc argument' do
        expect_offense(<<~RUBY)
          foo.values.each(&:bar)
              ^^^^^^^^^^^ Use `each_value` instead of `values.each`.
        RUBY

        expect_correction(<<~RUBY)
          foo.each_value(&:bar)
        RUBY
      end

      it 'does not register an offense for foo#each_key' do
        expect_no_offenses('foo.each_key { |k| p k }')
      end

      it 'does not register an offense for Hash#each_value' do
        expect_no_offenses('foo.each_value { |v| p v }')
      end

      context 'Ruby 2.7' do
        it 'registers offense, autocorrects foo#keys.each to foo#each_key with numblock' do
          expect_offense(<<~RUBY)
            foo.keys.each { p _1 }
                ^^^^^^^^^ Use `each_key` instead of `keys.each`.
          RUBY

          expect_correction(<<~RUBY)
            foo.each_key { p _1 }
          RUBY
        end
      end
    end

    context 'when receiver is a hash literal' do
      it 'registers offense, autocorrects {}#keys.each with {}#each_key' do
        expect_offense(<<~RUBY)
          {}.keys.each { |k| p k }
             ^^^^^^^^^ Use `each_key` instead of `keys.each`.
        RUBY

        expect_correction(<<~RUBY)
          {}.each_key { |k| p k }
        RUBY
      end

      it 'registers offense, autocorrects {}#values.each with {}#each_value' do
        expect_offense(<<~RUBY)
          {}.values.each { |k| p k }
             ^^^^^^^^^^^ Use `each_value` instead of `values.each`.
        RUBY

        expect_correction(<<~RUBY)
          {}.each_value { |k| p k }
        RUBY
      end

      it 'registers offense, autocorrects {}#keys.each to {}#each_key with a symbol proc argument' do
        expect_offense(<<~RUBY)
          {}.keys.each(&:bar)
             ^^^^^^^^^ Use `each_key` instead of `keys.each`.
        RUBY

        expect_correction(<<~RUBY)
          {}.each_key(&:bar)
        RUBY
      end

      it 'registers offense, autocorrects {}#values.each to {}#each_value with a symbol proc argument' do
        expect_offense(<<~RUBY)
          {}.values.each(&:bar)
             ^^^^^^^^^^^ Use `each_value` instead of `values.each`.
        RUBY

        expect_correction(<<~RUBY)
          {}.each_value(&:bar)
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
      it 'does not register an offense for `keys.each`' do
        expect_no_offenses(<<~RUBY)
          keys.each { |k| p k }
        RUBY
      end

      it 'does not register an offense for `values.each`' do
        expect_no_offenses(<<~RUBY)
          values.each { |v| p v }
        RUBY
      end

      it 'does not register an offense for `keys.each` with a symbol proc argument' do
        expect_no_offenses(<<~RUBY)
          keys.each(&:bar)
        RUBY
      end

      it 'does not register an offense for `values.each` with a symbol proc argument' do
        expect_no_offenses(<<~RUBY)
          values.each(&:bar)
        RUBY
      end

      it 'does not register an offense for each_key' do
        expect_no_offenses('each_key { |k| p k }')
      end

      it 'does not register an offense for each_value' do
        expect_no_offenses('each_value { |v| p v }')
      end
    end

    context "when `AllowedReceivers: ['execute']`" do
      let(:cop_config) { { 'AllowedReceivers' => ['execute'] } }

      it 'does not register an offense when receiver is `execute` method' do
        expect_no_offenses(<<~RUBY)
          execute(sql).values.each { |v| p v }
        RUBY
      end

      it 'does not register an offense when receiver is `execute` variable' do
        expect_no_offenses(<<~RUBY)
          execute = do_something(argument)
          execute.values.each { |v| p v }
        RUBY
      end

      it 'does not register an offense when receiver is `execute` method with a symbol proc argument' do
        expect_no_offenses(<<~RUBY)
          execute(sql).values.each(&:bar)
        RUBY
      end

      it 'registers an offense when receiver is not allowed name' do
        expect_offense(<<~RUBY)
          do_something(arg).values.each { |v| p v }
                            ^^^^^^^^^^^ Use `each_value` instead of `values.each`.
        RUBY
      end
    end

    context "when `AllowedReceivers: ['Thread.current']`" do
      let(:cop_config) { { 'AllowedReceivers' => ['Thread.current'] } }

      it 'does not register an offense when receiver is `Thread.current` method' do
        expect_no_offenses(<<~RUBY)
          Thread.current.keys.each { |k| p k }
        RUBY
      end
    end
  end
end
