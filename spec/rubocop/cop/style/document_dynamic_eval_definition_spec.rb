# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DocumentDynamicEvalDefinition do
  subject(:cop) { described_class.new }

  it 'registers an offense when using eval-type method with string interpolation without comment docs' do
    expect_offense(<<~RUBY)
      class_eval <<-EOT, __FILE__, __LINE__ + 1
      ^^^^^^^^^^ Add a comment block showing its appearance if interpolated.
        def \#{unsafe_method}(*params, &block)
          to_str.\#{unsafe_method}(*params, &block)
        end
      EOT
    RUBY
  end

  it 'does not register an offense when using eval-type method without string interpolation' do
    expect_no_offenses(<<~RUBY)
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def capitalize(*params, &block)
          to_str.capitalize(*params, &block)
        end
      EOT
    RUBY
  end

  it 'does not register an offense when using eval-type method with string interpolation with comment docs' do
    expect_no_offenses(<<~RUBY)
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def \#{unsafe_method}(*params, &block)       # def capitalize(*params, &block)
          to_str.\#{unsafe_method}(*params, &block)  #   to_str.capitalize(*params, &block)
        end                                          # end
      EOT
    RUBY
  end
end
