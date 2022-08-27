# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::CopDescription, :config do
  before do
    allow_any_instance_of(described_class).to receive(:relevant_file?).and_return(true) # rubocop:disable RSpec/AnyInstance
  end

  context 'The description starts with `This cop ...`' do
    it 'registers an offense and corrects if using just a verb' do
      expect_offense(<<~RUBY)
        module RuboCop
          module Cop
            module Lint
              # This cop checks some offenses...
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Description should be started with `Checks` instead of `This cop ...`.
              #
              # ...
              class Foo < Base
              end
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module RuboCop
          module Cop
            module Lint
              # Checks some offenses...
              #
              # ...
              class Foo < Base
              end
            end
          end
        end
      RUBY
    end

    it 'registers an offense if using an auxiliary verb' do
      expect_offense(<<~RUBY)
        module RuboCop
          module Cop
            module Lint
              # This cop can check some offenses...
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Description should be started with a word such as verb instead of `This cop ...`.
              #
              # ...
              class Foo < Base
              end
            end
          end
        end
      RUBY
    end

    it 'registers an offense if the description like `This cop is ...`' do
      expect_offense(<<~RUBY)
        module RuboCop
          module Cop
            module Lint
              # This cop is used to...
                ^^^^^^^^^^^^^^^^^^^^^^ Description should be started with a word such as verb instead of `This cop ...`.
              #
              # ...
              class Foo < Base
              end
            end
          end
        end
      RUBY
    end
  end

  context 'The description starts with a word such as verb' do
    it 'does not register if the description like `Checks`' do
      expect_no_offenses(<<~RUBY)
        module RuboCop
          module Cop
            module Lint
              # Checks some problem
              #
              # ...
              class Foo < Base
              end
            end
          end
        end
      RUBY
    end

    it 'does not register if the description starts with non-verb word' do
      expect_no_offenses(<<~RUBY)
        module RuboCop
          module Cop
            module Lint
              # Either foo or bar ...
              #
              # ...
              class Foo < Base
              end
            end
          end
        end
      RUBY
    end
  end

  context 'There is no description comment' do
    it 'does not register offense' do
      expect_no_offenses(<<~RUBY)
        module RuboCop
          module Cop
            module Lint
              class Foo < Base
              end
            end
          end
        end
      RUBY
    end
  end
end
