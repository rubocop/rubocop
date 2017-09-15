# frozen_string_literal: true

describe RuboCop::Cop::Layout::EmptyLinesAroundExceptionHandlingKeywords do
  let(:config) { RuboCop::Config.new }

  subject(:cop) { described_class.new(config) }

  shared_examples :offense do |name, message, code, correction|
    it "registers an offense for #{name} with a blank" do
      inspect_source(code.strip_indent)
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(["Extra empty line detected #{message}."])
    end

    it "autocorrects for #{name} with a blank" do
      corrected = autocorrect_source(code.strip_indent)
      expect(corrected).to eq(correction.strip_indent)
    end
  end

  shared_examples :accepts do |name, code|
    it "accepts #{name}" do
      inspect_source(code)
      expect(cop.offenses).to be_empty
    end
  end

  include_examples :offense,
                   'above rescue keyword',
                   'before the `rescue`',
                   <<-CODE, <<-CORRECTION
    begin
      f1

    rescue
      f2
    end
  CODE
    begin
      f1
    rescue
      f2
    end
  CORRECTION

  include_examples :offense,
                   'rescue section starting',
                   'after the `rescue`',
                   <<-CODE, <<-CORRECTION
    begin
      f1
    rescue

      f2
    end
  CODE
    begin
      f1
    rescue
      f2
    end
  CORRECTION

  include_examples :offense,
                   'rescue section ending',
                   'before the `else`',
                   <<-CODE, <<-CORRECTION
    begin
      f1
    rescue
      f2

    else
      f3
    end
  CODE
    begin
      f1
    rescue
      f2
    else
      f3
    end
  CORRECTION

  include_examples :offense,
                   'rescue section ending for method definition',
                   'before the `else`',
                   <<-CODE, <<-CORRECTION
    def foo
      f1
    rescue
      f2

    else
      f3
    end
  CODE
    def foo
      f1
    rescue
      f2
    else
      f3
    end
  CORRECTION

  include_examples :accepts, 'no empty line', <<-RUBY
    begin
      f1
    rescue
      f2
    else
      f3
    ensure
      f4
    end
  RUBY

  include_examples :accepts, 'empty lines around begin body', <<-RUBY
    begin

      f1

    end
  RUBY

  include_examples :accepts, 'empty begin', <<-RUBY
    begin
    end
  RUBY

  include_examples :accepts, 'empty method definition', <<-RUBY
    def foo
    end
  RUBY

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
      expect(cop.offenses.size).to eq(10)
    end

    it 'autocorrects' do
      corrected = autocorrect_source(source)
      expect(corrected).to eq correction
    end
  end

  context 'with complex method definition' do
    let(:source) { <<-RUBY.strip_indent }
      def foo

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
      def foo

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
      expect(cop.offenses.size).to eq(10)
    end

    it 'autocorrects' do
      corrected = autocorrect_source(source)
      expect(corrected).to eq correction
    end
  end
end
