# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ApplicationRecord do
  context 'rails 4', :rails4, :config do
    subject(:cop) { described_class.new(config) }

    it 'allows ApplicationRecord to be defined' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class ApplicationRecord < ActiveRecord::Base; end
      RUBY
    end

    it 'allows models that subclass ActiveRecord::Base' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class MyModel < ActiveRecord::Base; end
      RUBY
    end

    it 'allows a single-line class definitions' do
      expect_no_offenses('class MyModel < ActiveRecord::Base; end')
    end

    it 'allows namespaced models that subclass ActiveRecord::Base' do
      expect_no_offenses(<<-RUBY.strip_indent)
        module Nested
          class MyModel < ActiveRecord::Base; end
        end
      RUBY
    end

    it 'allows models defined using nested constants' do
      expect_no_offenses(<<-RUBY.strip_indent)
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
      expect_no_offenses(<<-RUBY.strip_indent)
        class ApplicationRecord < ActiveRecord::Base
        end
      RUBY
    end

    it 'corrects models that subclass ActiveRecord::Base' do
      expect_offense(<<-RUBY.strip_indent)
        class MyModel < ActiveRecord::Base
                        ^^^^^^^^^^^^^^^^^^ Models should subclass `ApplicationRecord`.
        end
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        class MyModel < ApplicationRecord
        end
      RUBY
    end

    it 'corrects single-line class definitions' do
      expect_offense(<<-RUBY.strip_indent)
        class MyModel < ActiveRecord::Base; end
                        ^^^^^^^^^^^^^^^^^^ Models should subclass `ApplicationRecord`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        class MyModel < ApplicationRecord; end
      RUBY
    end

    it 'corrects namespaced models that subclass ActiveRecord::Base' do
      expect_offense(<<-RUBY.strip_indent)
        module Nested
          class MyModel < ActiveRecord::Base
                          ^^^^^^^^^^^^^^^^^^ Models should subclass `ApplicationRecord`.
          end
        end
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        module Nested
          class MyModel < ApplicationRecord
          end
        end
      RUBY
    end

    it 'corrects models defined using nested constants' do
      expect_offense(<<-RUBY.strip_indent)
        class Nested::MyModel < ActiveRecord::Base
                                ^^^^^^^^^^^^^^^^^^ Models should subclass `ApplicationRecord`.
        end
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        class Nested::MyModel < ApplicationRecord
        end
      RUBY
    end

    it 'corrects models defined using Class.new' do
      expect_offense(<<-RUBY.strip_indent)
        MyModel = Class.new(ActiveRecord::Base)
                            ^^^^^^^^^^^^^^^^^^ Models should subclass `ApplicationRecord`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        MyModel = Class.new(ApplicationRecord)
      RUBY
    end

    it 'corrects nested models defined using Class.new' do
      expect_offense(<<-RUBY.strip_indent)
        Nested::MyModel = Class.new(ActiveRecord::Base)
                                    ^^^^^^^^^^^^^^^^^^ Models should subclass `ApplicationRecord`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        Nested::MyModel = Class.new(ApplicationRecord)
      RUBY
    end

    it 'corrects anonymous models' do
      expect_offense(<<-RUBY.strip_indent)
        Class.new(ActiveRecord::Base) {}
                  ^^^^^^^^^^^^^^^^^^ Models should subclass `ApplicationRecord`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        Class.new(ApplicationRecord) {}
      RUBY
    end

    it 'allows ApplicationRecord defined using Class.new' do
      expect_no_offenses('ApplicationRecord = Class.new(ActiveRecord::Base)')
    end
  end
end
