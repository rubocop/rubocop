# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::EmptyLinesAroundExceptionHandlingKeywords do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  shared_examples :offense do |name, code, correction|
    it "registers an offense for #{name} with a blank" do
      inspect_source(cop, code.strip_indent)
      expect(cop.offenses.size).to eq(1)
    end

    it "autocorrects for #{name} with a blank" do
      corrected = autocorrect_source(cop, code.strip_indent)
      expect(corrected).to eq(correction.strip_indent)
    end
  end

  shared_examples :accepts do |name, code|
    it "accepts #{name}" do
      inspect_source(cop, code)
      expect(cop.offenses).to be_empty
    end
  end

  include_examples :offense, 'above rescue keyword', <<-CODE, <<-CORRECTION
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
  include_examples :offense, 'rescue section starting', <<-CODE, <<-CORRECTION
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
  include_examples :offense, 'rescue section ending', <<-CODE, <<-CORRECTION
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

  include_examples :accepts, 'no empty line', <<-END
    begin
      f1
    rescue
      f2
    else
      f3
    ensure
      f4
    end
  END
  include_examples :accepts, 'empty liens around begin body', <<-END
    begin

      f1

    end
  END
  include_examples :accepts, 'empty begin', <<-END
    begin
    end
  END
  include_examples :accepts, 'empty method definition', <<-END
    def foo
    end
  END

  context 'with complex begin-end' do
    let(:source) { <<-END.strip_indent }
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
    END
    let(:correction) { <<-END.strip_indent }
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
    END

    it 'registers many offenses' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(10)
    end

    it 'autocorrects' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq correction
    end
  end

  context 'with complex method definition' do
    let(:source) { <<-END.strip_indent }
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
    END
    let(:correction) { <<-END.strip_indent }
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
    END

    it 'registers many offenses' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(10)
    end

    it 'autocorrects' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq correction
    end
  end
end
