# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::OrderedMethods do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when methods are not in alphabetical order' do
    expect_offense(<<-RUBY.strip_indent)
      def self.class_b; end
      def self.class_a; end
      ^^^^^^^^^^^^^^^^^^^^^ Methods should be sorted alphabetically.

      def instance_b; end
      def instance_a; end
      ^^^^^^^^^^^^^^^^^^^ Methods should be sorted alphabetically.

      module_function

      def module_function_b; end
      def module_function_a; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Methods should be sorted alphabetically.

      private

      def private_b; end
      def private_a; end
      ^^^^^^^^^^^^^^^^^^ Methods should be sorted alphabetically.

      private

      def private_d; end
      def private_c; end
      ^^^^^^^^^^^^^^^^^^ Methods should be sorted alphabetically.

      protected

      def protected_b; end
      def protected_a; end
      ^^^^^^^^^^^^^^^^^^^^ Methods should be sorted alphabetically.

      public

      def public_b; end
      def public_a; end
      ^^^^^^^^^^^^^^^^^ Methods should be sorted alphabetically.

      def self.class_d; end
      def self.class_c; end
      ^^^^^^^^^^^^^^^^^^^^^ Methods should be sorted alphabetically.

      def instance_d; end
      def instance_c; end
      ^^^^^^^^^^^^^^^^^^^ Methods should be sorted alphabetically.
    RUBY
  end

  it 'does not register an offense when methods are in alphabetical order' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def f; end
    RUBY
  end
end
