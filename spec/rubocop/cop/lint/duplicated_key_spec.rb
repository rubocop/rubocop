# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DuplicatedKey do
  subject(:cop) { described_class.new }

  context 'when there is a duplicated key in the hash literal' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        hash = { 'otherkey' => 'value', 'key' => 'value', 'key' => 'hi' }
                                                          ^^^^^ Duplicated key in hash literal.
      RUBY
    end
  end

  context 'when there are two duplicated keys in a hash' do
    it 'registers two offenses' do
      expect_offense(<<-RUBY.strip_indent)
        hash = { fruit: 'apple', veg: 'kale', veg: 'cuke', fruit: 'orange' }
                                              ^^^ Duplicated key in hash literal.
                                                           ^^^^^ Duplicated key in hash literal.
      RUBY
    end
  end

  context 'When a key is duplicated three times in a hash literal' do
    it 'registers two offenses' do
      expect_offense(<<-RUBY.strip_indent)
        hash = { 1 => 2, 1 => 3, 1 => 4 }
                         ^ Duplicated key in hash literal.
                                 ^ Duplicated key in hash literal.
      RUBY
    end
  end

  context 'When there is no duplicated key in the hash' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        hash = { ['one', 'two'] => ['hello, bye'], ['two'] => ['yes, no'] }
      RUBY
    end
  end

  shared_examples 'duplicated literal key' do |key|
    it "registers an offense for duplicated `#{key}` hash keys" do
      inspect_source("hash = { #{key} => 1, #{key} => 4}")
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Duplicated key in hash literal.')
      expect(cop.highlights).to eq [key]
    end
  end

  it_behaves_like 'duplicated literal key', '!true'
  it_behaves_like 'duplicated literal key', '"#{2}"'
  it_behaves_like 'duplicated literal key', '(1)'
  it_behaves_like 'duplicated literal key', '(false && true)'
  it_behaves_like 'duplicated literal key', '(false <=> true)'
  it_behaves_like 'duplicated literal key', '(false or true)'
  it_behaves_like 'duplicated literal key', '[1, 2, 3]'
  it_behaves_like 'duplicated literal key', '{ :a => 1, :b => 2 }'
  it_behaves_like 'duplicated literal key', '{ a: 1, b: 2 }'
  it_behaves_like 'duplicated literal key', '/./'
  it_behaves_like 'duplicated literal key', '%r{abx}ixo'
  it_behaves_like 'duplicated literal key', '1.0'
  it_behaves_like 'duplicated literal key', '1'
  it_behaves_like 'duplicated literal key', 'false'
  it_behaves_like 'duplicated literal key', 'nil'
  it_behaves_like 'duplicated literal key', "'str'"

  shared_examples 'duplicated non literal key' do |key|
    it "does not register an offense for duplicated `#{key}` hash keys" do
      expect_no_offenses(<<-RUBY.strip_indent)
        hash = { #{key} => 1, #{key} => 4}
      RUBY
    end
  end

  it_behaves_like 'duplicated non literal key', '"#{some_method_call}"'
  it_behaves_like 'duplicated non literal key', '(x && false)'
  it_behaves_like 'duplicated non literal key', '(x == false)'
  it_behaves_like 'duplicated non literal key', '(x or false)'
  it_behaves_like 'duplicated non literal key', '[some_method_call]'
  it_behaves_like 'duplicated non literal key', '{ :sym => some_method_call }'
  it_behaves_like 'duplicated non literal key', '{ some_method_call => :sym }'
  it_behaves_like 'duplicated non literal key', '/.#{some_method_call}/'
  it_behaves_like 'duplicated non literal key', '%r{abx#{foo}}ixo'
  it_behaves_like 'duplicated non literal key', 'some_method_call'
  it_behaves_like 'duplicated non literal key', 'some_method_call(x, y)'
end
