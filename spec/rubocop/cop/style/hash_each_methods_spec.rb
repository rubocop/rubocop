# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashEachMethods do
  subject(:cop) { described_class.new }

  context 'when node matches a keys#each or values#each' do
    context 'when receiver is a send' do
      it 'registers an offense for foo#keys.each' do
        expect_offense(<<-RUBY)
          foo.keys.each { |k| p k }
              ^^^^^^^^^ Use `each_key` instead of `keys.each`.
        RUBY
      end

      it 'registers an offense for foo#values.each' do
        expect_offense(<<-RUBY)
          foo.values.each { |v| p v }
              ^^^^^^^^^^^ Use `each_value` instead of `values.each`.
        RUBY
      end

      it 'does not register an offense for foo#each_key' do
        expect_no_offenses('foo.each_key { |k| p k }')
      end

      it 'does not register an offense for Hash#each_value' do
        expect_no_offenses('foo.each_value { |v| p v }')
      end

      it 'auto-corrects foo#keys.each with foo#each_key' do
        new_source = autocorrect_source('foo.keys.each { |k| p k }')
        expect(new_source).to eq('foo.each_key { |k| p k }')
      end

      it 'auto-corrects foo#values.each with foo#each_value' do
        new_source = autocorrect_source('foo.values.each { |v| p v }')
        expect(new_source).to eq('foo.each_value { |v| p v }')
      end
    end

    context 'when receiver is a hash literal' do
      it 'registers an offense for {}#keys.each' do
        expect_offense(<<-RUBY)
          {}.keys.each { |k| p k }
             ^^^^^^^^^ Use `each_key` instead of `keys.each`.
        RUBY
      end

      it 'registers an offense for {}#values.each' do
        expect_offense(<<-RUBY)
          {}.values.each { |v| p v }
             ^^^^^^^^^^^ Use `each_value` instead of `values.each`.
        RUBY
      end

      it 'does not register an offense for {}#each_key' do
        expect_no_offenses('{}.each_key { |k| p k }')
      end

      it 'does not register an offense for {}#each_value' do
        expect_no_offenses('{}.each_value { |v| p v }')
      end

      it 'auto-corrects {}#keys.each with {}#each_key' do
        new_source = autocorrect_source('{}.keys.each { |k| p k }')
        expect(new_source).to eq('{}.each_key { |k| p k }')
      end

      it 'auto-corrects {}#values.each with {}#each_value' do
        new_source = autocorrect_source('{}.values.each { |v| p v }')
        expect(new_source).to eq('{}.each_value { |v| p v }')
      end
    end

    context 'when receiver is implicit' do
      it 'registers an offense for keys.each' do
        expect_offense(<<-RUBY)
          keys.each { |k| p k }
          ^^^^^^^^^ Use `each_key` instead of `keys.each`.
        RUBY
      end

      it 'registers an offense for values.each' do
        expect_offense(<<-RUBY)
          values.each { |v| p v }
          ^^^^^^^^^^^ Use `each_value` instead of `values.each`.
        RUBY
      end

      it 'does not register an offense for each_key' do
        expect_no_offenses('each_key { |k| p k }')
      end

      it 'does not register an offense for each_value' do
        expect_no_offenses('each_value { |v| p v }')
      end

      it 'auto-corrects keys.each with each_key' do
        new_source = autocorrect_source('keys.each { |k| p k }')
        expect(new_source).to eq('each_key { |k| p k }')
      end

      it 'auto-corrects values.each with each_value' do
        new_source = autocorrect_source('values.each { |v| p v }')
        expect(new_source).to eq('each_value { |v| p v }')
      end
    end
  end
end
