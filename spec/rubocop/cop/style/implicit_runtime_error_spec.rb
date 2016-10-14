# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::ImplicitRuntimeError do
  subject(:cop) { described_class.new }

  %w[raise fail].each do |method|
    it "registers an offense for #{method} 'message'" do
      inspect_source(cop, "#{method} 'message'")
      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq(["Use `#{method}` with an explicit " \
                                 'exception class and message, rather than ' \
                                 'just a message.'])
      expect(cop.highlights).to eq(["#{method} 'message'"])
    end

    it "registers an offense for #{method} with a multiline string" do
      inspect_source(cop, ["#{method} 'message' \\", "'2nd line'"])
      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq(["Use `#{method}` with an explicit " \
                                 'exception class and message, rather than ' \
                                 'just a message.'])
      expect(cop.highlights).to eq(["#{method} 'message' \\\n'2nd line'"])
    end

    it "doesn't register an offense for #{method} StandardError, 'message'" do
      inspect_source(cop, "#{method} StandardError, 'message'")
      expect(cop.offenses).to be_empty
    end

    it "doesn't register an offense for #{method} with no arguments" do
      inspect_source(cop, method)
      expect(cop.offenses).to be_empty
    end
  end
end
