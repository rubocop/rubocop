# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IdenticalConditionalBranches do
  subject(:cop) { described_class.new }

  context 'on if..else with identical bodies' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        if something
          do_x
          ^^^^ Move `do_x` out of the conditional.
        else
          do_x
          ^^^^ Move `do_x` out of the conditional.
        end
      RUBY
    end
  end

  context 'on if..else with identical trailing lines' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        if something
          method_call_here(1, 2, 3)
          do_x
          ^^^^ Move `do_x` out of the conditional.
        else
          1 + 2 + 3
          do_x
          ^^^^ Move `do_x` out of the conditional.
        end
      RUBY
    end
  end

  context 'on if..else with identical leading lines' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        if something
          do_x
          ^^^^ Move `do_x` out of the conditional.
          method_call_here(1, 2, 3)
        else
          do_x
          ^^^^ Move `do_x` out of the conditional.
          1 + 2 + 3
        end
      RUBY
    end
  end

  context 'on if..elsif with no else' do
    it "doesn't register an offense" do
      expect_no_offenses(<<-RUBY.strip_indent)
        if something
          do_x
        elsif something_else
          do_x
        end
      RUBY
    end
  end

  context 'on if..else with slightly different trailing lines' do
    it "doesn't register an offense" do
      expect_no_offenses(<<-RUBY.strip_indent)
        if something
          do_x(1)
        else
          do_x(2)
        end
      RUBY
    end
  end

  context 'on case with identical bodies' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        case something
        when :a
          do_x
          ^^^^ Move `do_x` out of the conditional.
        when :b
          do_x
          ^^^^ Move `do_x` out of the conditional.
        else
          do_x
          ^^^^ Move `do_x` out of the conditional.
        end
      RUBY
    end
  end

  # Regression: https://github.com/bbatsov/rubocop/issues/3868
  context 'when one of the case branches is empty' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        case value
        when cond1
        else
          if cond2
          else
          end
        end
      RUBY
    end
  end

  context 'on case with identical trailing lines' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        case something
        when :a
          x1
          do_x
          ^^^^ Move `do_x` out of the conditional.
        when :b
          x2
          do_x
          ^^^^ Move `do_x` out of the conditional.
        else
          x3
          do_x
          ^^^^ Move `do_x` out of the conditional.
        end
      RUBY
    end
  end

  context 'on case with identical leading lines' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        case something
        when :a
          do_x
          ^^^^ Move `do_x` out of the conditional.
          x1
        when :b
          do_x
          ^^^^ Move `do_x` out of the conditional.
          x2
        else
          do_x
          ^^^^ Move `do_x` out of the conditional.
          x3
        end
      RUBY
    end
  end

  context 'on case without else' do
    let(:source) do
      <<-RUBY.strip_indent
        case something
        when :a
          do_x
        when :b
          do_x
        end
      RUBY
    end

    it "doesn't register an offense" do
      expect_no_offenses(<<-RUBY.strip_indent)
        case something
        when :a
          do_x
        when :b
          do_x
        end
      RUBY
    end
  end

  context 'on case with empty when' do
    it "doesn't register an offense" do
      expect_no_offenses(<<-RUBY.strip_indent)
        case something
        when :a
          do_x
          do_y
        when :b
        else
          do_x
          do_z
        end
      RUBY
    end
  end
end
