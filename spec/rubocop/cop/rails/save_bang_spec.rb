# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::SaveBang, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'checks_common_offense' do |method|
    it "when using #{method} with arguments" do
      inspect_source("object.#{method}(name: 'Tom', age: 20)")

      if method == :destroy
        expect(cop.messages.empty?).to be(true)
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
      expect_no_offenses("object.#{method}!")
    end

    it "when using #{method} with 2 arguments" do
      expect_no_offenses("Model.#{method}(1, name: 'Tom')")
    end

    it "when using #{method} with wrong argument" do
      expect_no_offenses("object.#{method}('Tom')")
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
        expect(cop.messages.empty?).to be(true)
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
        expect(cop.messages.empty?).to be(true)
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
        expect(cop.messages.empty?).to be(true)
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with negated if" do
      inspect_source("if !object.#{method}; something; end")

      if pass
        expect(cop.messages.empty?).to be(true)
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
        expect(cop.messages.empty?).to be(true)
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with oneline if" do
      inspect_source("something if object.#{method}")

      if pass
        expect(cop.messages.empty?).to be(true)
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with oneline if and multiple conditional" do
      inspect_source("something if false || object.#{method}")

      if pass
        expect(cop.messages.empty?).to be(true)
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
        expect(cop.messages.empty?).to be(true)
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with '&&'" do
      inspect_source("object.#{method} && false")

      if pass
        expect(cop.messages.empty?).to be(true)
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with 'and'" do
      inspect_source("object.#{method} and false")

      if pass
        expect(cop.messages.empty?).to be(true)
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it "when using #{method} with '||'" do
      inspect_source("object.#{method} || false")

      if pass
        expect(cop.messages.empty?).to be(true)
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it 'when passing to a method' do
      expect_no_offenses("handle_save(object.#{method})")
    end

    it 'when passing to a method as the non-last argument' do
      expect_no_offenses("handle_save(object.#{method}, true)")
    end

    it "when using #{method} with 'or'" do
      inspect_source("object.#{method} or false")

      if pass
        expect(cop.messages.empty?).to be(true)
      else
        expect(cop.messages)
          .to eq(["`#{method}` returns a model which is always truthy."])
      end
    end

    it 'when passing to a method as a keyword argument' do
      expect_no_offenses("handle_save(success: object.#{method})")
    end

    it 'when assigning as a hash value' do
      expect_no_offenses("result = { success: object.#{method} }")
    end

    it 'when using an explicit early return' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def foo
          return foo.#{method} if do_the_save
          do_something_else
        end
      RUBY
    end

    it 'when using an explicit final return' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def foo
          return foo.#{method}
        end
      RUBY
    end

    it 'when using an explicit early return from a block' do
      expect_no_offenses(<<-RUBY.strip_indent)
        objects.each do |object|
          next object.#{method} if do_the_save
          do_something_else
        end
      RUBY
    end

    it 'when using an explicit final return from a block' do
      expect_no_offenses(<<-RUBY.strip_indent)
        objects.each do |object|
          next foo.#{method}
        end
      RUBY
    end

    # Bug: https://github.com/rubocop-hq/rubocop/issues/4264
    it 'when using the assigned variable as value in a hash' do
      inspect_source(<<-RUBY.strip_indent)
        def foo
          foo = Foo.#{method}
          render json: foo
        end
      RUBY
      if pass
        expect(cop.offenses.empty?).to be(true)
      else
        expect(cop.offenses.size).to eq(1)
      end
    end
  end

  shared_examples 'check_implicit_return' do |method, pass|
    it "when using #{method} as last method call" do
      inspect_source(<<-RUBY.strip_indent)
        def foo
          object.#{method}
        end
      RUBY

      if pass
        expect(cop.offenses.empty?).to be true
      else
        expect(cop.messages)
          .to match_array(start_with("Use `#{method}!` instead of `#{method}`" \
                             ' if the return value is not checked.'))
      end
    end

    it "when using #{method} as last method call of a block" do
      inspect_source(<<-RUBY.strip_indent)
        objects.each do |object|
          object.#{method}
        end
      RUBY

      if pass
        expect(cop.offenses.empty?).to be true
      else
        expect(cop.messages)
          .to match_array(start_with("Use `#{method}!` instead of `#{method}`" \
                             ' if the return value is not checked.'))
      end
    end
  end

  described_class::MODIFY_PERSIST_METHODS.each do |method|
    let(:cop_config) { { 'AllowImplicitReturn' => true } }

    context method.to_s do
      it_behaves_like('checks_common_offense', method)
      it_behaves_like('checks_variable_return_use_offense', method, true)
      it_behaves_like('check_implicit_return', method, true)

      context 'with AllowImplicitReturn false' do
        let(:cop_config) { { 'AllowImplicitReturn' => false } }

        it_behaves_like('checks_variable_return_use_offense', method, true)
        it_behaves_like('check_implicit_return', method, false)
      end
    end
  end

  shared_examples 'checks_create_offense' do |method|
    it "when using persisted? after #{method}" do
      expect_no_offenses("x = object.#{method}\n" \
                          'if x.persisted? then; something; end')
    end

    it "when using persisted? after #{method} with block" do
      expect_no_offenses("x = object.#{method} do |obj|\n" \
                          "  obj.name = 'Tom'\n" \
                          "end\n" \
                          'if x.persisted? then; something; end')
    end
  end

  described_class::CREATE_PERSIST_METHODS.each do |method|
    let(:cop_config) { { 'AllowImplicitReturn' => true } }

    context method.to_s do
      it_behaves_like('checks_common_offense', method)
      it_behaves_like('checks_variable_return_use_offense', method, false)
      it_behaves_like('checks_create_offense', method)
      it_behaves_like('check_implicit_return', method, true)

      context 'with AllowImplicitReturn false' do
        let(:cop_config) { { 'AllowImplicitReturn' => false } }

        it_behaves_like('checks_variable_return_use_offense', method, false)
        it_behaves_like('check_implicit_return', method, false)
      end
    end
  end

  it 'properly ignores lvasign without right hand side' do
    expect_no_offenses('variable += 1')
  end
end
