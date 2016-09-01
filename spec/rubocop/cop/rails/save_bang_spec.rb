# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe RuboCop::Cop::Rails::SaveBang do
  subject(:cop) { described_class.new }

  shared_examples 'checks_offense' do |method|
    it "when using #{method} with arguments" do
      inspect_source(cop, "object.#{method}(name: 'Tom', age: 20)")

      if method == :destroy
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["Use `#{method}!` instead of `#{method}` " \
                  'if the return value is not checked.'])
      end
    end

    it "when using #{method} without arguments" do
      inspect_source(cop, method.to_s)

      expect(cop.messages)
        .to eq(["Use `#{method}!` instead of `#{method}` " \
                'if the return value is not checked.'])
    end

    it "when using #{method}!" do
      inspect_source(cop, "object.#{method}!")

      expect(cop.messages).to be_empty
    end

    it "when using #{method} with 2 arguments" do
      inspect_source(cop, "Model.#{method}(1, name: 'Tom')")

      expect(cop.messages).to be_empty
    end

    it "when using #{method} with wrong argument" do
      inspect_source(cop, "object.#{method}('Tom')")

      expect(cop.messages).to be_empty
    end

    it "when assigning the return value of #{method}" do
      inspect_source(cop, "x = object.#{method}")

      expect(cop.messages).to be_empty
    end

    it "when assigning the return value of #{method} with block" do
      inspect_source(cop, "x = object.#{method} do |obj|\n" \
                          "  obj.name = 'Tom'\n" \
                          'end')

      expect(cop.messages).to be_empty
    end

    it "when using #{method} with if" do
      inspect_source(cop, "if object.#{method}; something; end")

      expect(cop.messages).to be_empty
    end

    it 'autocorrects' do
      new_source = autocorrect_source(cop, "object.#{method}()")

      expect(new_source).to eq("object.#{method}!()")
    end
  end

  described_class::PERSIST_METHODS.each do |method|
    it_behaves_like('checks_offense', method)
  end
end
