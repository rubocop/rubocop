# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Output do
  subject(:cop) { described_class.new }

  it 'records an offense for methods without a receiver' do
    source = <<-RUBY.strip_indent
      p "edmond dantes"
      puts "sinbad"
      print "abbe busoni"
      pp "monte cristo"
      $stdout.write "lord wilmore"
      $stderr.syswrite "faria"
      STDOUT.write "bertuccio"
    RUBY
    inspect_source(source)
    expect(cop.offenses.size).to eq(7)
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
      $stdout.write
      STDERR.write
    RUBY
  end

  it 'does not record an offense for comments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # print "test"
      # p
      # $stdout.write
      # STDERR.binwrite
    RUBY
  end
end
