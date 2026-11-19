# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::RedundantAutocorrectIncompatibleWith, :config do
  def source(declaration, cop:)
    department, name = cop.split('::')

    <<~RUBY
      module RuboCop
        module Cop
          module #{department}
            class #{name} < Base
              def self.autocorrect_incompatible_with
                #{declaration}
              end
            end
          end
        end
      end
    RUBY
  end

  # The examples rely on these declarations: `Layout/SpaceAroundOperators` is
  # incompatible with `Style/SelfAssignment`, `Layout/EmptyLineBetweenDefs`
  # with `Layout/EmptyLines`, and `Lint/TripleQuotes` with
  # `Lint/ImplicitStringConcatenation`.

  it 'registers an offense when the other cop declares the incompatibility too' do
    expect_offense(source(<<~RUBY.chomp, cop: 'Style::SelfAssignment'))
      [Layout::DotPosition, Layout::SpaceAroundOperators]
                                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Layout/SpaceAroundOperators` already declares that it is incompatible with this cop.
    RUBY
  end

  it 'registers an offense when the department of the other cop is left out' do
    expect_offense(source(<<~RUBY.chomp, cop: 'Layout::EmptyLines'))
      [EmptyLineBetweenDefs]
                 ^^^^^^^^^^^^^^^^^^^^ `Layout/EmptyLineBetweenDefs` already declares that it is incompatible with this cop.
    RUBY
  end

  it 'does not register an offense in the cop whose name comes first' do
    expect_no_offenses(source('[Lint::TripleQuotes]', cop: 'Lint::ImplicitStringConcatenation'))
  end

  it 'does not register an offense when the other cop does not declare the incompatibility' do
    expect_no_offenses(source('[Layout::DotPosition]', cop: 'Style::SelfAssignment'))
  end

  it 'does not register an offense when the other cop is not known' do
    expect_no_offenses(source('[Layout::Unknown]', cop: 'Style::SelfAssignment'))
  end

  it 'does not register an offense when the method does not return an array literal' do
    expect_no_offenses(source('INCOMPATIBLE_COPS', cop: 'Style::SelfAssignment'))
  end

  it 'does not register an offense for another method' do
    expect_no_offenses(<<~RUBY)
      module Style
        class SelfAssignment < Base
          def self.incompatible_cops
            [Layout::SpaceAroundOperators]
          end
        end
      end
    RUBY
  end
end
