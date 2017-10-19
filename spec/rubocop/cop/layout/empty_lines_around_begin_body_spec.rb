# frozen_string_literal: true

describe RuboCop::Cop::Layout::EmptyLinesAroundBeginBody do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  shared_examples :offense do |name, message, code, correction|
    it "registers an offense for #{name} with a blank" do
      inspect_source(code.strip_indent)
      message = "Extra empty line detected at `begin` body #{message}."
      expect(cop.messages).to eq([message])
    end

    it "autocorrects for #{name} with a blank" do
      corrected = autocorrect_source(code.strip_indent)
      expect(corrected).to eq(correction.strip_indent)
    end
  end

  shared_examples :accepts do |name, code|
    it "accepts #{name}" do
      inspect_source(code)
      expect(cop.offenses.empty?).to be(true)
    end
  end

  include_examples :offense, 'begin body starting', 'beginning',
                   <<-CODE, <<-CORRECTION
    begin

      foo
    end
  CODE
    begin
      foo
    end
  CORRECTION
  include_examples :offense, 'begin body ending', 'end', <<-CODE, <<-CORRECTION
    begin
      foo

    end
  CODE
    begin
      foo
    end
  CORRECTION
  include_examples :offense,
                   'begin body starting in method', 'beginning',
                   <<-CODE, <<-CORRECTION
    def bar
      begin

        foo
      end
    end
  CODE
    def bar
      begin
        foo
      end
    end
  CORRECTION
  include_examples :offense,
                   'begin body ending in method', 'end', <<-CODE, <<-CORRECTION
    def bar
      begin
        foo

      end
    end
  CODE
    def bar
      begin
        foo
      end
    end
  CORRECTION

  include_examples :offense,
                   'begin body starting with rescue', 'beginning',
                   <<-CODE, <<-CORRECTION
    begin

      foo
    rescue
      bar
    end
  CODE
    begin
      foo
    rescue
      bar
    end
  CORRECTION
  include_examples :offense, 'rescue body ending', 'end', <<-CODE, <<-CORRECTION
    begin
      foo
    rescue
      bar

    end
  CODE
    begin
      foo
    rescue
      bar
    end
  CORRECTION

  include_examples :offense, 'else body ending', 'end', <<-CODE, <<-CORRECTION
    begin
      foo
    rescue
      bar
    else
      baz

    end
  CODE
    begin
      foo
    rescue
      bar
    else
      baz
    end
  CORRECTION
  include_examples :offense, 'ensure body ending', 'end', <<-CODE, <<-CORRECTION
    begin
      foo
    ensure
      bar

    end
  CODE
    begin
      foo
    ensure
      bar
    end
  CORRECTION

  context 'with complex begin-end' do
    let(:source) { <<-RUBY.strip_indent }
      begin

        do_something1
      rescue RuntimeError
        do_something2
      rescue ArgumentError => ex
        do_something3
      rescue
        do_something3
      else
        do_something4
      ensure
        do_something4

      end
    RUBY
    let(:correction) { <<-RUBY.strip_indent }
      begin
        do_something1
      rescue RuntimeError
        do_something2
      rescue ArgumentError => ex
        do_something3
      rescue
        do_something3
      else
        do_something4
      ensure
        do_something4
      end
    RUBY

    it 'registers many offenses' do
      inspect_source(source)
      expect(cop.offenses.size).to eq(2)
    end

    it 'autocorrects' do
      corrected = autocorrect_source(source)
      expect(corrected).to eq correction
    end
  end

  include_examples :accepts, 'begin block without empty line', <<-RUBY
    begin
      foo
    end
  RUBY
  include_examples :accepts,
                   'begin block without empty line in a method', <<-RUBY
    def foo
      begin
        bar
      end
    end
  RUBY
end
