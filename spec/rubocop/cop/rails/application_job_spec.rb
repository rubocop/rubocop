# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ApplicationJob do
  context 'rails 4', :rails4, :config do
    subject(:cop) { described_class.new(config) }

    it 'allows ApplicationJob to be defined' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class ApplicationJob < ActiveJob::Base
        end
      RUBY
    end

    it 'allows jobs that subclass ActiveJob::Base' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class MyJob < ActiveJob::Base
        end
      RUBY
    end

    it 'allows a single-line class definitions' do
      expect_no_offenses('class MyJob < ActiveJob::Base; end')
    end

    it 'allows namespaced jobs that subclass ActiveJob::Base' do
      expect_no_offenses(<<-RUBY.strip_indent)
        module Nested
          class MyJob < ActiveJob::Base
          end
        end
      RUBY
    end

    it 'allows jobs defined using nested constants' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Nested::MyJob < ActiveJob::Base
        end
      RUBY
    end

    it 'allows jobs defined using Class.new' do
      expect_no_offenses('MyJob = Class.new(ActiveJob::Base)')
    end

    it 'allows nested jobs defined using Class.new' do
      expect_no_offenses('Nested::MyJob = Class.new(ActiveJob::Base)')
    end

    it 'allows anonymous jobs' do
      expect_no_offenses('Class.new(ActiveJob::Base) {}')
    end

    it 'allows ApplicationJob defined using Class.new' do
      expect_no_offenses('ApplicationJob = Class.new(ActiveJob::Base)')
    end
  end

  context 'rails 5', :rails5 do
    subject(:cop) { described_class.new }

    it 'allows `ApplicationJob` to be defined' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class ApplicationJob < ActiveJob::Base; end
      RUBY
    end

    context 'when subclassing `ActiveJob::Base`' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          class MyJob < ActiveJob::Base; end
                        ^^^^^^^^^^^^^^^ Jobs should subclass `ApplicationJob`.
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          class MyJob < ApplicationJob; end
        RUBY
      end
    end

    context 'when subclassing `ActiveJob::Base` in a module namespace' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          module Nested
            class MyJob < ActiveJob::Base; end
                          ^^^^^^^^^^^^^^^ Jobs should subclass `ApplicationJob`.
          end
        RUBY
      end
    end

    context 'when subclassing `ActiveJob::Base` in an inline namespace' do
      it 'corrects jobs defined using nested constants' do
        expect_offense(<<-RUBY.strip_indent)
          class Nested::MyJob < ActiveJob::Base; end
                                ^^^^^^^^^^^^^^^ Jobs should subclass `ApplicationJob`.
        RUBY
      end
    end

    it 'corrects jobs defined using Class.new' do
      expect_offense(<<-RUBY.strip_indent)
        MyJob = Class.new(ActiveJob::Base)
                          ^^^^^^^^^^^^^^^ Jobs should subclass `ApplicationJob`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        MyJob = Class.new(ApplicationJob)
      RUBY
    end

    it 'corrects nested jobs defined using Class.new' do
      expect_offense(<<-RUBY.strip_indent)
        Nested::MyJob = Class.new(ActiveJob::Base)
                                  ^^^^^^^^^^^^^^^ Jobs should subclass `ApplicationJob`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        Nested::MyJob = Class.new(ApplicationJob)
      RUBY
    end

    it 'corrects anonymous jobs' do
      expect_offense(<<-RUBY.strip_indent)
        Class.new(ActiveJob::Base) {}
                  ^^^^^^^^^^^^^^^ Jobs should subclass `ApplicationJob`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        Class.new(ApplicationJob) {}
      RUBY
    end

    it 'allows ApplicationJob defined using Class.new' do
      expect_no_offenses('ApplicationJob = Class.new(ActiveJob::Base)')
    end
  end
end
