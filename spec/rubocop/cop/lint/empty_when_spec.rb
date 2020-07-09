# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyWhen, :config do
  shared_examples 'code with offense' do |code|
    context "when checking #{code}" do
      it 'registers an offense' do
        expect_offense(code)
        expect_no_corrections
      end
    end
  end

  shared_examples 'code without offense' do |code|
    it 'does not register an offense' do
      expect_no_offenses(code)
    end
  end

  let(:cop_config) { { 'AllowComments' => false } }

  context 'when a `when` body is missing' do
    it_behaves_like 'code with offense', <<~RUBY
      case foo
      when :bar then 1
      when :baz # nothing
      ^^^^^^^^^ Avoid `when` branches without a body.
      end
    RUBY

    it_behaves_like 'code with offense', <<~RUBY
      case foo
      when :bar then 1
      when :baz # nothing
      ^^^^^^^^^ Avoid `when` branches without a body.
      else 3
      end
    RUBY

    it_behaves_like 'code with offense', <<~RUBY
      case foo
      when :bar then 1
      when :baz then # nothing
      ^^^^^^^^^ Avoid `when` branches without a body.
      end
    RUBY

    it_behaves_like 'code with offense', <<~RUBY
      case foo
      when :bar then 1
      when :baz then # nothing
      ^^^^^^^^^ Avoid `when` branches without a body.
      else 3
      end
    RUBY

    it_behaves_like 'code with offense', <<~RUBY
      case foo
      when :bar
        1
      when :baz
      ^^^^^^^^^ Avoid `when` branches without a body.
        # nothing
      end
    RUBY

    it_behaves_like 'code with offense', <<~RUBY
      case foo
      when :bar
        1
      when :baz
      ^^^^^^^^^ Avoid `when` branches without a body.
        # nothing
      else
        3
      end
    RUBY

    it_behaves_like 'code with offense', <<~RUBY
      case
      when :bar
        1
      when :baz
      ^^^^^^^^^ Avoid `when` branches without a body.
        # nothing
      else
        3
      end
    RUBY
  end

  context 'when a `when` body is present' do
    it_behaves_like 'code without offense', <<~RUBY
      case foo
      when :bar then 1
      when :baz then 2
      end
    RUBY

    it_behaves_like 'code without offense', <<~RUBY
      case foo
      when :bar then 1
      when :baz then 2
      else 3
      end
    RUBY

    it_behaves_like 'code without offense', <<~RUBY
      case foo
      when :bar
        1
      when :baz
        2
      end
    RUBY

    it_behaves_like 'code without offense', <<~RUBY
      case foo
      when :bar
        1
      when :baz
        2
      else
        3
      end
    RUBY
    it_behaves_like 'code without offense', <<~RUBY
      case
      when :bar
        1
      when :baz
        2
      else
        3
      end
    RUBY
  end

  context 'when `AllowComments: true`' do
    let(:cop_config) { { 'AllowComments' => true } }

    it_behaves_like 'code without offense', <<~RUBY
      case condition
      when foo
        do_something
      when bar
        # do nothing
      end
    RUBY
  end

  context 'when `AllowComments: false`' do
    let(:cop_config) { { 'AllowComments' => false } }

    it_behaves_like 'code with offense', <<~RUBY
      case condition
      when foo
        do_something
      when bar
      ^^^^^^^^ Avoid `when` branches without a body.
        # do nothing
      end
    RUBY
  end
end
