# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceAroundEqualsInParameterDefault, :config do # rubocop:disable Metrics/LineLength
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is space' do
    let(:cop_config) { { 'EnforcedStyle' => 'space' } }

    it 'registers an offense for default value assignment without space' do
      expect_offense(<<-RUBY.strip_indent)
        def f(x, y=0, z= 1)
                  ^ Surrounding space missing in default value assignment.
                       ^^ Surrounding space missing in default value assignment.
        end
      RUBY
    end

    it 'registers an offense for assignment empty string without space' do
      expect_offense(<<-RUBY.strip_indent)
        def f(x, y="")
                  ^ Surrounding space missing in default value assignment.
        end
      RUBY
    end

    it 'registers an offense for assignment of empty list without space' do
      expect_offense(<<-RUBY.strip_indent)
        def f(x, y=[])
                  ^ Surrounding space missing in default value assignment.
        end
      RUBY
    end

    it 'accepts default value assignment with space' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def f(x, y = 0, z = {})
        end
      RUBY
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def f(x, y=0, z=1)
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def f(x, y = 0, z = 1)
        end
      RUBY
    end

    it 'accepts default value assignment with spaces and unary + operator' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def f(x, y = +1, z = {})
        end
      RUBY
    end

    it 'auto-corrects missing space for arguments with unary operators' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def f(x=-1, y= 0, z =+1)
        end
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        def f(x = -1, y = 0, z = +1)
        end
      RUBY
    end
  end

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'registers an offense for default value assignment with space' do
      expect_offense(<<-RUBY.strip_indent)
        def f(x, y = 0, z =1, w= 2)
                  ^^^ Surrounding space detected in default value assignment.
                         ^^ Surrounding space detected in default value assignment.
                               ^^ Surrounding space detected in default value assignment.
        end
      RUBY
    end

    it 'registers an offense for assignment empty string with space' do
      expect_offense(<<-RUBY.strip_indent)
        def f(x, y = "")
                  ^^^ Surrounding space detected in default value assignment.
        end
      RUBY
    end

    it 'registers an offense for assignment of empty list with space' do
      expect_offense(<<-RUBY.strip_indent)
        def f(x, y = [])
                  ^^^ Surrounding space detected in default value assignment.
        end
      RUBY
    end

    it 'accepts default value assignment without space' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def f(x, y=0, z={})
        end
      RUBY
    end

    it 'auto-corrects unwanted space' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def f(x, y = 0, z= 1, w= 2)
        end
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        def f(x, y=0, z=1, w=2)
        end
      RUBY
    end
  end
end
