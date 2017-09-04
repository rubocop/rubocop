# frozen_string_literal: true

describe RuboCop::Cop::Rails::SaveBang do
  subject(:cop) { described_class.new }

  shared_examples 'checks_common_offense' do |method|
    it "when using #{method} with arguments" do
      inspect_source("object.#{method}(name: 'Tom', age: 20)")

      if method == :destroy
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["Use `#{method}!` instead of `#{method}` " \
                  'if the return value is not checked.'])
      end
    end

    it "when using #{method} without arguments" do
      inspect_source(method.to_s)

      expect(cop.messages)
        .to eq(["Use `#{method}!` instead of `#{method}` " \
                'if the return value is not checked.'])
    end

    it "when using #{method}!" do
      inspect_source("object.#{method}!")

      expect(cop.messages).to be_empty
    end

    it "when using #{method} with 2 arguments" do
      inspect_source("Model.#{method}(1, name: 'Tom')")

      expect(cop.messages).to be_empty
    end

    it "when using #{method} with wrong argument" do
      inspect_source("object.#{method}('Tom')")

      expect(cop.messages).to be_empty
    end

    it 'autocorrects' do
      new_source = autocorrect_source("object.#{method}()")

      expect(new_source).to eq("object.#{method}!()")
    end
  end

  shared_examples 'checks_variable_return_use_offense' do |method, pass|
    it "when assigning the return value of #{method}" do
      inspect_source("x = object.#{method}\n")

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
      inspect_source("x = object.#{method} do |obj|\n" \
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
      inspect_source("if object.#{method}; something; end")

      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with multiple conditional" do
      inspect_source(<<-RUBY.strip_indent)
        if true && object.active? && object.#{method}
          something
        end
      RUBY
      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with oneline if" do
      inspect_source("something if object.#{method}")

      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with oneline if and multiple conditional" do
      inspect_source("something if false || object.#{method}")

      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with case statement" do
      inspect_source(<<-RUBY.strip_indent)
        case object.#{method}
        when true
          puts "true"
        when false
          puts "false"
        end
      RUBY

      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with '&&'" do
      inspect_source("object.#{method} && false")

      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with 'and'" do
      inspect_source("object.#{method} and false")

      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with '||'" do
      inspect_source("object.#{method} || false")

      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with 'or'" do
      inspect_source("object.#{method} or false")

      if pass
        expect(cop.messages).to be_empty
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} as last method call" do
      inspect_source(['def foo', "object.#{method}", 'end'])
      expect(cop.messages).to be_empty
    end

    # Bug: https://github.com/bbatsov/rubocop/issues/4264
    it 'when using the assigned variable as value in a hash' do
      inspect_source(['def foo',
                      "  foo = Foo.#{method}",
                      '  render json: foo',
                      'end'])
      if pass
        expect(cop.offenses).to be_empty
      else
        expect(cop.offenses.size).to eq(1)
      end
    end
  end

  described_class::MODIFY_PERSIST_METHODS.each do |method|
    it_behaves_like('checks_common_offense', method)
    it_behaves_like('checks_variable_return_use_offense', method, true)
  end

  shared_examples 'checks_create_offense' do |method|
    it "when using persisted? after #{method}" do
      inspect_source("x = object.#{method}\n" \
                          'if x.persisted? then; something; end')

      expect(cop.messages).to be_empty
    end

    it "when using persisted? after #{method} with block" do
      inspect_source("x = object.#{method} do |obj|\n" \
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
    expect_no_offenses('variable += 1')
  end
end
