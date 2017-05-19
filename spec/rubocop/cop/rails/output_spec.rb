# frozen_string_literal: true

describe RuboCop::Cop::Rails::Output do
  subject(:cop) { described_class.new }

  it 'records an offense for methods without a receiver' do
    source = <<-END.strip_indent
      p "edmond dantes"
      puts "sinbad"
      print "abbe busoni"
      pp "monte cristo"
    END
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(4)
  end

  it 'records an offense when printing various types' do
    source = ['p 1',
              'puts String.new',
              'print :a, :b',
              'pp Class.new']
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(4)
  end

  it 'does not record an offense for methods with a receiver' do
    expect_no_offenses(<<-RUBY.strip_indent)
      obj.print
      something.p
      nothing.pp
    RUBY
  end

  it 'does not record an offense for methods without arguments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      print
      pp
      puts
    RUBY
  end

  it 'does not record an offense for comments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # print "test"
      # p
    RUBY
  end
end
