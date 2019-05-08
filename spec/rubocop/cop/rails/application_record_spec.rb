# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ApplicationRecord do
  context 'rails 4', :rails4, :config do
    subject(:cop) { described_class.new(config) }

    it 'allows ApplicationRecord to be defined' do
      expect_no_offenses(<<~RUBY)
        class ApplicationRecord < ActiveRecord::Base; end
      RUBY
    end

    it 'allows models that subclass ActiveRecord::Base' do
      expect_no_offenses(<<~RUBY)
        class MyModel < ActiveRecord::Base; end
      RUBY
    end

    it 'allows a single-line class definitions' do
      expect_no_offenses('class MyModel < ActiveRecord::Base; end')
    end

    it 'allows namespaced models that subclass ActiveRecord::Base' do
      expect_no_offenses(<<~RUBY)
        module Nested
          class MyModel < ActiveRecord::Base; end
        end
      RUBY
    end

    it 'allows models defined using nested constants' do
      expect_no_offenses(<<~RUBY)
        class Nested::MyModel < ActiveRecord::Base; end
      RUBY
    end

    it 'allows models defined using Class.new' do
      expect_no_offenses('MyModel = Class.new(ActiveRecord::Base)')
    end

    it 'allows nested models defined using Class.new' do
      expect_no_offenses('Nested::MyModel = Class.new(ActiveRecord::Base)')
    end

    it 'allows anonymous models' do
      expect_no_offenses('Class.new(ActiveRecord::Base) {}')
    end

    it 'allows ApplicationRecord defined using Class.new' do
      expect_no_offenses('ApplicationRecord = Class.new(ActiveRecord::Base)')
    end
  end

  context 'rails 5', :rails5 do
    subject(:cop) { described_class.new }

    it 'allows ApplicationRecord to be defined' do
      expect_no_offenses(<<~RUBY)
        class ApplicationRecord < ActiveRecord::Base
        end
      RUBY
    end

    it 'corrects models that subclass ActiveRecord::Base' do
      expect_offense(<<~RUBY)
        class MyModel < ActiveRecord::Base
                        ^^^^^^^^^^^^^^^^^^ Models should subclass `ApplicationRecord`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyModel < ApplicationRecord
        end
      RUBY
    end

    it 'corrects single-line class definitions' do
      expect_offense(<<~RUBY)
        class MyModel < ActiveRecord::Base; end
                        ^^^^^^^^^^^^^^^^^^ Models should subclass `ApplicationRecord`.
      RUBY

      expect_correction(<<~RUBY)
        class MyModel < ApplicationRecord; end
      RUBY
    end

    it 'corrects namespaced models that subclass ActiveRecord::Base' do
      expect_offense(<<~RUBY)
        module Nested
          class MyModel < ActiveRecord::Base
                          ^^^^^^^^^^^^^^^^^^ Models should subclass `ApplicationRecord`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Nested
          class MyModel < ApplicationRecord
          end
        end
      RUBY
    end

    it 'corrects models defined using nested constants' do
      expect_offense(<<~RUBY)
        class Nested::MyModel < ActiveRecord::Base
                                ^^^^^^^^^^^^^^^^^^ Models should subclass `ApplicationRecord`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Nested::MyModel < ApplicationRecord
        end
      RUBY
    end

    it 'corrects models defined using Class.new' do
      expect_offense(<<~RUBY)
        MyModel = Class.new(ActiveRecord::Base)
                            ^^^^^^^^^^^^^^^^^^ Models should subclass `ApplicationRecord`.
      RUBY

      expect_correction(<<~RUBY)
        MyModel = Class.new(ApplicationRecord)
      RUBY
    end

    it 'corrects nested models defined using Class.new' do
      expect_offense(<<~RUBY)
        Nested::MyModel = Class.new(ActiveRecord::Base)
                                    ^^^^^^^^^^^^^^^^^^ Models should subclass `ApplicationRecord`.
      RUBY

      expect_correction(<<~RUBY)
        Nested::MyModel = Class.new(ApplicationRecord)
      RUBY
    end

    it 'corrects anonymous models' do
      expect_offense(<<~RUBY)
        Class.new(ActiveRecord::Base) {}
                  ^^^^^^^^^^^^^^^^^^ Models should subclass `ApplicationRecord`.
      RUBY

      expect_correction(<<~RUBY)
        Class.new(ApplicationRecord) {}
      RUBY
    end

    it 'allows ApplicationRecord defined using Class.new' do
      expect_no_offenses('ApplicationRecord = Class.new(ActiveRecord::Base)')
    end
  end
end
