# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SuppressedException, :config do
  context 'with AllowComments set to false' do
    let(:cop_config) { { 'AllowComments' => false } }

    it 'registers an offense for empty rescue block' do
      expect_offense(<<~RUBY)
        begin
          something
        rescue
        ^^^^^^ Do not suppress exceptions.
          #do nothing
        end
      RUBY
    end

    it 'does not register an offense for rescue with body' do
      expect_no_offenses(<<~RUBY)
        begin
          something
          return
        rescue
          file.close
        end
      RUBY
    end
  end

  context 'with AllowComments set to true' do
    let(:cop_config) { { 'AllowComments' => true } }

    it 'does not register an offense for empty rescue with comment' do
      expect_no_offenses(<<~RUBY)
        begin
          something
          return
        rescue
          # do nothing
        end
      RUBY
    end

    it 'registers an offense for empty rescue block in `def`' do
      expect_offense(<<~RUBY)
        def foo
          do_something
        rescue
        ^^^^^^ Do not suppress exceptions.
        end
      RUBY
    end

    it 'registers an offense for empty rescue on single line with a comment after it' do
      expect_offense(<<~RUBY)
        RSpec.describe Dummy do
          it 'dummy spec' do
            # This rescue is here to ensure the test does not fail because of the `raise`
            expect { begin subject; rescue ActiveRecord::Rollback; end }.not_to(change(Post, :count))
                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not suppress exceptions.
            # Done
          end
        end
      RUBY
    end
  end
end
