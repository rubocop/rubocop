# frozen_string_literal: true

# rubocop:disable RSpec/FilePath
RSpec.describe RuboCop::Cop::EnforceSuperclass, :restore_registry do
  subject(:cop) { cop_class.new(configuration) }

  let(:cop_class) { RuboCop::Cop::RSpec::ApplicationRecord }
  let(:msg) { 'Models should subclass `ApplicationRecord`' }

  before do
    stub_cop_class('RuboCop::Cop::RSpec::ApplicationRecord')
    stub_const("#{cop_class}::MSG", 'Models should subclass `ApplicationRecord`')
    stub_const("#{cop_class}::SUPERCLASS", 'ApplicationRecord')
    stub_const("#{cop_class}::BASE_PATTERN", '(const (const {nil? cbase} :ActiveRecord) :Base)')
    allow(described_class).to receive(:warn).with(
      /`RuboCop::Cop::EnforceSuperclass` is deprecated and will be removed/
    )
    RuboCop::Cop::RSpec::ApplicationRecord.include(described_class)
  end

  shared_examples 'no offense' do |code|
    it "registers no offenses for `#{code}`" do
      expect_no_offenses(code)
    end
  end

  it 'registers an offense for models that subclass ActiveRecord::Base' do
    expect_offense(<<~RUBY)
      class MyModel < ActiveRecord::Base
                      ^^^^^^^^^^^^^^^^^^ #{msg}
      end
    RUBY
  end

  it 'registers an offense for single-line definitions' do
    expect_offense(<<~RUBY)
      class MyModel < ActiveRecord::Base; end
                      ^^^^^^^^^^^^^^^^^^ #{msg}
    RUBY
  end

  it 'registers an offense for Class.new definition' do
    expect_offense(<<~RUBY)
      MyModel = Class.new(ActiveRecord::Base) {}
                          ^^^^^^^^^^^^^^^^^^ #{msg}
    RUBY
    expect_offense(<<~RUBY)
      MyModel = Class.new(ActiveRecord::Base)
                          ^^^^^^^^^^^^^^^^^^ #{msg}
    RUBY
  end

  it 'registers an offense for model defined using top-level' do
    expect_offense(<<~RUBY)
      class ::MyModel < ActiveRecord::Base
                        ^^^^^^^^^^^^^^^^^^ #{msg}
      end
    RUBY
  end

  it 'registers an offense for models that subclass ::ActiveRecord::Base' do
    expect_offense(<<~RUBY)
      class MyModel < ::ActiveRecord::Base
                      ^^^^^^^^^^^^^^^^^^^^ #{msg}
      end
    RUBY
  end

  it 'registers an offense for top-level constant ::Class.new definition' do
    expect_offense(<<~RUBY)
      ::MyModel = ::Class.new(::ActiveRecord::Base) {}
                              ^^^^^^^^^^^^^^^^^^^^ #{msg}
    RUBY
    expect_offense(<<~RUBY)
      ::MyModel = ::Class.new(::ActiveRecord::Base)
                              ^^^^^^^^^^^^^^^^^^^^ #{msg}
    RUBY
  end

  context 'when ApplicationRecord subclasses ActiveRecord::Base' do
    it_behaves_like 'no offense', 'class ApplicationRecord < ActiveRecord::Base; end'
    it_behaves_like 'no offense', 'class ::ApplicationRecord < ActiveRecord::Base; end'

    it_behaves_like 'no offense', <<~RUBY
      ApplicationRecord = Class.new(ActiveRecord::Base) do; end
    RUBY
    it_behaves_like 'no offense', <<~RUBY
      ApplicationRecord = Class.new(::ActiveRecord::Base) do; end
    RUBY
    it_behaves_like 'no offense', <<~RUBY
      ApplicationRecord = Class.new(ActiveRecord::Base)
    RUBY
    it_behaves_like 'no offense', <<~RUBY
      ::ApplicationRecord = Class.new(ActiveRecord::Base) do; end
    RUBY
    it_behaves_like 'no offense', <<~RUBY
      ::ApplicationRecord = ::Class.new(::ActiveRecord::Base) do; end
    RUBY
    it_behaves_like 'no offense', <<~RUBY
      ::ApplicationRecord = ::Class.new(::ActiveRecord::Base)
    RUBY
  end

  context 'when MyModel subclasses ApplicationRecord' do
    it_behaves_like 'no offense', 'class MyModel < ApplicationRecord; end'
    it_behaves_like 'no offense', 'class MyModel < ::ApplicationRecord; end'

    it_behaves_like 'no offense', <<~RUBY
      MyModel = Class.new(ApplicationRecord) do
      end
      MyModel = Class.new(ApplicationRecord)
    RUBY
    it_behaves_like 'no offense', <<~RUBY
      MyModel = ::Class.new(::ApplicationRecord) do
      end
      MyModel = ::Class.new(::ApplicationRecord)
    RUBY
  end
end
# rubocop:enable RSpec/FilePath
