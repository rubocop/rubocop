# frozen_string_literal: true

describe RuboCop::Cop::Performance::HashEachMethods do
  subject(:cop) { described_class.new }

  context 'when node matches a plain `#each` ' \
  'with unused key or value' do
    context 'when receiver is a send' do
      it 'registers an offense for foo#each with unused value' do
        expect_offense(<<-RUBY.strip_indent)
          foo.each { |k, _v| p k }
              ^^^^ Use `each_key` instead of `each`.
        RUBY
      end

      it 'does not register an offense for foo#each' \
      ' if both key/value are used' do
        expect_no_offenses("foo.each { |k, v| p \"\#{k}_\#{v}\" }")
      end

      it 'does not register an offense when #each follows #to_a' do
        expect_no_offenses('foo.to_a.each { |k, _v| bar(k) }')
      end

      it 'does not register an offense when using braces around arguments' do
        expect_no_offenses('foo.each { |(k, _v)| bar(k) }')
      end

      it 'does not register an offense for foo#each ' \
      ' if block takes only one arg' do
        expect_no_offenses('foo.each { |kv| p kv }')
      end

      it 'registers an offense for foo#each with unused key' do
        expect_offense(<<-RUBY.strip_indent)
          foo.each { |_k, v| p v }
              ^^^^ Use `each_value` instead of `each`.
        RUBY
      end

      it 'auto-corrects foo#each with unused value argument' \
      ' with foo#each_key' do
        new_source = autocorrect_source('foo.each { |k, _v| p k }')
        expect(new_source).to eq('foo.each_key { |k| p k }')
      end
    end

    context 'when receiver is a hash literal' do
      it 'registers an offense for {}#each with unused value' do
        expect_offense(<<-RUBY.strip_indent)
          {}.each { |k, _v| p k }
             ^^^^ Use `each_key` instead of `each`.
        RUBY
      end

      it 'registers an offense for {}#each with unused key' do
        expect_offense(<<-RUBY.strip_indent)
          {}.each { |_k, v| p v }
             ^^^^ Use `each_value` instead of `each`.
        RUBY
      end

      it 'does not register an offense for {}#each' \
      ' if both key/value are used' do
        expect_no_offenses("{}.each { |k, v| p \"\#{k}_\#{v}\" }")
      end

      it 'does not register an offense for {}#each ' \
      ' if block takes only one arg' do
        expect_no_offenses('{}.each { |kv| p kv }')
      end

      it 'does not register an offense when #each follows #to_a' do
        expect_no_offenses('{}.to_a.each { |k, _v| bar(k) }')
      end

      it 'does not register an offense when using braces around arguments' do
        expect_no_offenses('{}.each { |(k, _v)| bar(k) }')
      end

      it 'auto-corrects {}#each with unused value argument' \
      ' with {}#each_key' do
        new_source = autocorrect_source('{}.each { |k, _v| p k }')
        expect(new_source).to eq('{}.each_key { |k| p k }')
      end

      it 'auto-corrects {}#each with unused key argument' \
      ' with {}#each_value' do
        new_source = autocorrect_source('{}.each { |_k, v| p v }')
        expect(new_source).to eq('{}.each_value { |v| p v }')
      end
    end

    context 'when receiver is implicit' do
      it 'registers an offense for each with unused value' do
        expect_offense(<<-RUBY.strip_indent)
          each { |k, _v| p k }
          ^^^^ Use `each_key` instead of `each`.
        RUBY
      end

      it 'registers an offense for each with unused key' do
        expect_offense(<<-RUBY.strip_indent)
          each { |_k, v| p v }
          ^^^^ Use `each_value` instead of `each`.
        RUBY
      end

      it 'does not register an offense for each' \
      ' if both key/value are used' do
        expect_no_offenses("each { |k, v| p \"\#{k}_\#{v}\" }")
      end

      it 'does not register an offense for each ' \
      ' if block takes only one arg' do
        expect_no_offenses('each { |kv| p kv }')
      end

      it 'auto-corrects each with unused value argument' \
      ' with each_key' do
        new_source = autocorrect_source('each { |k, _v| p k }')
        expect(new_source).to eq('each_key { |k| p k }')
      end

      it 'auto-corrects each with unused key argument' \
      ' with each_value' do
        new_source = autocorrect_source('each { |_k, v| p v }')
        expect(new_source).to eq('each_value { |v| p v }')
      end
    end
  end

  context 'when node matches a keys#each or values#each' do
    context 'when receiver is a send' do
      it 'registers an offense for foo#keys.each' do
        expect_offense(<<-RUBY.strip_indent)
          foo.keys.each { |k| p k }
              ^^^^^^^^^ Use `each_key` instead of `keys.each`.
        RUBY
      end

      it 'registers an offense for foo#values.each' do
        expect_offense(<<-RUBY.strip_indent)
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
        expect_offense(<<-RUBY.strip_indent)
          {}.keys.each { |k| p k }
             ^^^^^^^^^ Use `each_key` instead of `keys.each`.
        RUBY
      end

      it 'registers an offense for {}#values.each' do
        expect_offense(<<-RUBY.strip_indent)
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
        expect_offense(<<-RUBY.strip_indent)
          keys.each { |k| p k }
          ^^^^^^^^^ Use `each_key` instead of `keys.each`.
        RUBY
      end

      it 'registers an offense for values.each' do
        expect_offense(<<-RUBY.strip_indent)
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
