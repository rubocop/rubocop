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

    context 'when empty rescue for `def`' do
      it 'registers an offense for empty rescue without comment' do
        expect_offense(<<~RUBY)
          def foo
            do_something
          rescue
          ^^^^^^ Do not suppress exceptions.
          end
        RUBY
      end

      it 'registers an offense for empty rescue with comment' do
        expect_offense(<<~RUBY)
          def foo
            do_something
          rescue
          ^^^^^^ Do not suppress exceptions.
            # do nothing
          end
        RUBY
      end

      context 'with AllowNil set to true' do
        let(:cop_config) { { 'AllowComments' => false, 'AllowNil' => true } }

        it 'does not register an offense for rescue block with nil' do
          expect_no_offenses(<<~RUBY)
            begin
              do_something
            rescue
              nil
            end
          RUBY
        end

        it 'does not register an offense for inline nil rescue' do
          expect_no_offenses(<<~RUBY)
            something rescue nil
          RUBY
        end
      end

      context 'with AllowNil set to false' do
        let(:cop_config) { { 'AllowComments' => false, 'AllowNil' => false } }

        it 'registers an offense for rescue block with nil' do
          expect_offense(<<~RUBY)
            begin
              do_something
            rescue
            ^^^^^^ Do not suppress exceptions.
              nil
            end
          RUBY
        end

        it 'registers an offense for inline nil rescue' do
          expect_offense(<<~RUBY)
            something rescue nil
                      ^^^^^^^^^^ Do not suppress exceptions.
          RUBY
        end
      end
    end

    context 'when empty rescue for defs' do
      it 'registers an offense for empty rescue without comment' do
        expect_offense(<<~RUBY)
          def self.foo
            do_something
          rescue
          ^^^^^^ Do not suppress exceptions.
          end
        RUBY
      end

      it 'registers an offense for empty rescue with comment' do
        expect_offense(<<~RUBY)
          def self.foo
            do_something
          rescue
          ^^^^^^ Do not suppress exceptions.
            # do nothing
          end
        RUBY
      end
    end

    context 'Ruby 2.5 or higher', :ruby25 do
      context 'when empty rescue for `do` block' do
        it 'registers an offense for empty rescue without comment' do
          expect_offense(<<~RUBY)
            foo do
              do_something
            rescue
            ^^^^^^ Do not suppress exceptions.
            end
          RUBY
        end

        it 'registers an offense for empty rescue with comment' do
          expect_offense(<<~RUBY)
            foo do
            rescue
            ^^^^^^ Do not suppress exceptions.
              # do nothing
            end
          RUBY
        end
      end
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

    context 'when empty rescue for `def`' do
      it 'registers an offense for empty rescue without comment' do
        expect_offense(<<~RUBY)
          def foo
            do_something
          rescue
          ^^^^^^ Do not suppress exceptions.
          end
        RUBY
      end

      it 'does not register an offense for empty rescue with comment' do
        expect_no_offenses(<<~RUBY)
          def foo
            do_something
          rescue
            # do nothing
          end
        RUBY
      end
    end

    context 'when empty rescue for `defs`' do
      it 'registers an offense for empty rescue without comment' do
        expect_offense(<<~RUBY)
          def self.foo
            do_something
          rescue
          ^^^^^^ Do not suppress exceptions.
          end
        RUBY
      end

      it 'does not register an offense for empty rescue with comment' do
        expect_no_offenses(<<~RUBY)
          def self.foo
            do_something
          rescue
            # do nothing
          end
        RUBY
      end
    end

    context 'Ruby 2.5 or higher', :ruby25 do
      context 'when empty rescue for `do` block' do
        it 'registers an offense for empty rescue without comment' do
          expect_offense(<<~RUBY)
            foo do
              do_something
            rescue
            ^^^^^^ Do not suppress exceptions.
            end
          RUBY
        end

        it 'does not register an offense for empty rescue with comment' do
          expect_no_offenses(<<~RUBY)
            foo do
            rescue
              # do nothing
            end
          RUBY
        end
      end
    end

    context 'Ruby 2.7 or higher', :ruby27 do
      context 'when empty rescue for `do` block with a numbered parameter' do
        it 'registers an offense for empty rescue without comment' do
          expect_offense(<<~RUBY)
            foo do
              _1
            rescue
            ^^^^^^ Do not suppress exceptions.
            end
          RUBY
        end

        it 'does not register an offense for empty rescue with comment' do
          expect_no_offenses(<<~RUBY)
            foo do
              _1
            rescue
              # do nothing
            end
          RUBY
        end
      end
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
