# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ModuleMemberExistenceCheck, :config do
  shared_examples 'module member inclusion' do |array_returning_method, predicate_method, has_inherit_param = true|
    it "registers an offense when using `.#{array_returning_method}.include?(method)`" do
      expect_offense(<<~RUBY, array_returning_method: array_returning_method)
        x.#{array_returning_method}.include?(method)
          ^{array_returning_method}^^^^^^^^^^^^^^^^^ Use `#{predicate_method}(method)` instead.
      RUBY

      expect_correction(<<~RUBY)
        x.#{predicate_method}(method)
      RUBY
    end

    it "registers an offense when using `.#{array_returning_method}.include? method`" do
      expect_offense(<<~RUBY, array_returning_method: array_returning_method)
        x.#{array_returning_method}.include? method
          ^{array_returning_method}^^^^^^^^^^^^^^^^ Use `#{predicate_method}(method)` instead.
      RUBY

      expect_correction(<<~RUBY)
        x.#{predicate_method}(method)
      RUBY
    end

    it "registers an offense when using `.#{array_returning_method}.member?(method)`" do
      expect_offense(<<~RUBY, array_returning_method: array_returning_method)
        x.#{array_returning_method}.member?(method)
          ^{array_returning_method}^^^^^^^^^^^^^^^^ Use `#{predicate_method}(method)` instead.
      RUBY

      expect_correction(<<~RUBY)
        x.#{predicate_method}(method)
      RUBY
    end

    it "registers an offense when using `&.#{array_returning_method}&.include?(method)`" do
      expect_offense(<<~RUBY, array_returning_method: array_returning_method)
        x&.#{array_returning_method}&.include?(method)
           ^{array_returning_method}^^^^^^^^^^^^^^^^^^ Use `#{predicate_method}(method)` instead.
      RUBY

      expect_correction(<<~RUBY)
        x&.#{predicate_method}(method)
      RUBY
    end

    it "registers an offense when using `#{array_returning_method}.include?(method)`" do
      expect_offense(<<~RUBY, array_returning_method: array_returning_method)
        #{array_returning_method}.include?(method)
        ^{array_returning_method}^^^^^^^^^^^^^^^^^ Use `#{predicate_method}(method)` instead.
      RUBY

      expect_correction(<<~RUBY)
        #{predicate_method}(method)
      RUBY
    end

    if has_inherit_param
      it "registers an offense when using `.#{array_returning_method}(false).include?(method)`" do
        expect_offense(<<~RUBY, array_returning_method: array_returning_method)
          x.#{array_returning_method}(false).include?(method)
            ^{array_returning_method}^^^^^^^^^^^^^^^^^^^^^^^^ Use `#{predicate_method}(method, false)` instead.
        RUBY

        expect_correction(<<~RUBY)
          x.#{predicate_method}(method, false)
        RUBY
      end

      it "registers an offense when using `.#{array_returning_method}(true).include?(method)`" do
        expect_offense(<<~RUBY, array_returning_method: array_returning_method)
          x.#{array_returning_method}(true).include?(method)
            ^{array_returning_method}^^^^^^^^^^^^^^^^^^^^^^^ Use `#{predicate_method}(method)` instead.
        RUBY

        expect_correction(<<~RUBY)
          x.#{predicate_method}(method)
        RUBY
      end

      it "registers an offense when using `.#{array_returning_method}(inherit).include?(method)`" do
        expect_offense(<<~RUBY, array_returning_method: array_returning_method)
          x.#{array_returning_method}(inherit).include?(method)
            ^{array_returning_method}^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `#{predicate_method}(method, inherit)` instead.
        RUBY

        expect_correction(<<~RUBY)
          x.#{predicate_method}(method, inherit)
        RUBY
      end
    else
      it "does not register an offense when using `.#{array_returning_method}(inherit).include?(method)`" do
        expect_no_offenses(<<~RUBY)
          x.#{array_returning_method}(inherit).include?(method)
        RUBY
      end
    end

    it "does not register an offense when passing more than one argument to `#{array_returning_method}`" do
      expect_no_offenses(<<~RUBY)
        x.#{array_returning_method}(true, false).include?(method)
      RUBY
    end

    it 'does not register an offense when passing more than one argument to `include?`' do
      expect_no_offenses(<<~RUBY)
        x.#{array_returning_method}.include?(foo, bar)
      RUBY
    end

    it 'does not register an offense when passing a splat argument to `include?`' do
      expect_no_offenses(<<~RUBY)
        x.#{array_returning_method}.include?(*foo)
      RUBY
    end

    it 'does not register an offense when passing a kwargs argument to `include?`' do
      expect_no_offenses(<<~RUBY)
        x.#{array_returning_method}.include?(**foo)
      RUBY
    end

    it 'does not register an offense when passing a block argument to `include?`' do
      expect_no_offenses(<<~RUBY)
        x.#{array_returning_method}.include?(&foo)
      RUBY
    end

    it "does not register an offense when passing a splat argument to `#{array_returning_method}`" do
      expect_no_offenses(<<~RUBY)
        x.#{array_returning_method}(*foo).include?(method)
      RUBY
    end

    context "when #{array_returning_method} is in AllowedMethods" do
      let(:cop_config) { { 'AllowedMethods' => [array_returning_method.to_s] } }

      it "does not register an offense when using `.#{array_returning_method}.include?(method)`" do
        expect_no_offenses(<<~RUBY)
          x.#{array_returning_method}.include?(method)
        RUBY
      end
    end
  end

  it_behaves_like 'module member inclusion', :class_variables, :class_variable_defined?, false
  it_behaves_like 'module member inclusion', :constants, :const_defined?
  it_behaves_like 'module member inclusion', :included_modules, :include?, false
  it_behaves_like 'module member inclusion', :instance_methods, :method_defined?
  it_behaves_like 'module member inclusion', :private_instance_methods, :private_method_defined?
  it_behaves_like 'module member inclusion', :protected_instance_methods, :protected_method_defined?
  it_behaves_like 'module member inclusion', :public_instance_methods, :public_method_defined?
end
