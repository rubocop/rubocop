# frozen_string_literal: true

describe RuboCop::Cop::Style::RedundantException do
  subject(:cop) { described_class.new }

  shared_examples 'common behavior' do |keyword|
    it "reports an offense for a #{keyword} with RuntimeError" do
      src = "#{keyword} RuntimeError, msg"
      inspect_source(src)
      expect(cop.highlights).to eq([src])
      expect(cop.messages)
        .to eq(['Redundant `RuntimeError` argument can be removed.'])
    end

    it "reports an offense for a #{keyword} with RuntimeError.new" do
      src = "#{keyword} RuntimeError.new(msg)"
      inspect_source(src)
      expect(cop.highlights).to eq([src])
      expect(cop.messages)
        .to eq(['Redundant `RuntimeError.new` call can be replaced with ' \
                'just the message.'])
    end

    it "accepts a #{keyword} with RuntimeError if it does not have 2 args" do
      inspect_source("#{keyword} RuntimeError, msg, caller")
      expect(cop.offenses).to be_empty
    end

    it "auto-corrects a #{keyword} RuntimeError by removing RuntimeError" do
      src = "#{keyword} RuntimeError, msg"
      result_src = "#{keyword} msg"
      new_src = autocorrect_source(cop, src)
      expect(new_src).to eq(result_src)
    end

    it "auto-corrects a #{keyword} RuntimeError.new with parentheses by " \
       'removing RuntimeError.new' do
      src = "#{keyword} RuntimeError.new(msg)"
      result_src = "#{keyword} msg"
      new_src = autocorrect_source(cop, src)
      expect(new_src).to eq(result_src)
    end

    it "auto-corrects a #{keyword} RuntimeError.new without parentheses by " \
       'removing RuntimeError.new' do
      src = "#{keyword} RuntimeError.new msg"
      result_src = "#{keyword} msg"
      new_src = autocorrect_source(cop, src)
      expect(new_src).to eq(result_src)
    end

    it "does not modify #{keyword} w/ RuntimeError if it does not have 2 " \
       'args' do
      src = "#{keyword} runtimeError, msg, caller"
      new_src = autocorrect_source(cop, src)
      expect(new_src).to eq(src)
    end

    it 'does not modify rescue w/ non redundant error' do
      src = "#{keyword} OtherError, msg"
      new_src = autocorrect_source(cop, src)
      expect(new_src).to eq(src)
    end
  end

  include_examples 'common behavior', 'raise'
  include_examples 'common behavior', 'fail'
end
