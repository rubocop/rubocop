# frozen_string_literal: true
require 'spec_helper'

describe RuboCop::Cop::Rails::SaveBang do
  subject(:cop) { described_class.new }

  shared_examples 'checks_common_offense' do |method|
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

    it 'autocorrects' do
      new_source = autocorrect_source(cop, "object.#{method}()")

      expect(new_source).to eq("object.#{method}!()")
    end
  end

  shared_examples 'checks_variable_return_use_offense' do |method, pass|
    it "when assigning the return value of #{method}" do
      inspect_source(cop, "x = object.#{method}\n")

      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["Use `#{method}!` instead of `#{method}` " \
                  'if the return value is not checked.' \
                  " Or check `persisted?` on model returned from `#{method}`."])
      end
    end

    it "when assigning the return value of #{method} with block" do
      inspect_source(cop, "x = object.#{method} do |obj|\n" \
                          "  obj.name = 'Tom'\n" \
                          'end')

      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["Use `#{method}!` instead of `#{method}` " \
                  'if the return value is not checked.' \
                  " Or check `persisted?` on model returned from `#{method}`."])
      end
    end

    it "when using #{method} with if" do
      inspect_source(cop, "if object.#{method}; something; end")

      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with multiple conditional" do
      inspect_source(cop, ["if true && object.active? && object.#{method}",
                           '  something',
                           'end'])
      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with oneline if" do
      inspect_source(cop, "something if object.#{method}")

      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with oneline if and multiple conditional" do
      inspect_source(cop, "something if false || object.#{method}")

      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} as last method call" do
      inspect_source(cop, ['def foo', "object.#{method}", 'end'])
      expect(cop.messages).to be_empty
    end
  end

  described_class::MODIFY_PERSIST_METHODS.each do |method|
    it_behaves_like('checks_common_offense', method)
    it_behaves_like('checks_variable_return_use_offense', method, true)
  end

  shared_examples 'checks_create_offense' do |method|
    it "when using persisted? after #{method}" do
      inspect_source(cop, "x = object.#{method}\n" \
                          'if x.persisted? then; something; end')

      expect(cop.messages).to be_empty
    end

    it "when using persisted? after #{method} with block" do
      inspect_source(cop, "x = object.#{method} do |obj|\n" \
                          "  obj.name = 'Tom'\n" \
                          "end\n" \
                          'if x.persisted? then; something; end')

      expect(cop.messages).to be_empty
    end
  end

  described_class::CREATE_PERSIST_METHODS.each do |method|
    it_behaves_like('checks_common_offense', method)
    it_behaves_like('checks_variable_return_use_offense', method, false)
    it_behaves_like('checks_create_offense', method)
  end

  it 'properly ignores lvasign without right hand side' do
    inspect_source(cop, 'variable += 1')

    expect(cop.messages).to be_empty
  end
end
