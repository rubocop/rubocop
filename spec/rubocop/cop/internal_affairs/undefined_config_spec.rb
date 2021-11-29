# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::UndefinedConfig, :config, :isolated_environment do
  include FileHelper

  before do
    create_file('config/default.yml', <<~YAML)
      Test/Foo:
        Defined: true

      X/Y/Z:
        Defined: true
    YAML

    allow(RuboCop::ConfigLoader).to receive(:default_configuration).and_return(
      RuboCop::ConfigLoader.load_file('config/default.yml', check: false)
    )
  end

  it 'does not register an offense for implicit configuration keys' do
    expect_no_offenses(<<~RUBY)
      module RuboCop
        module Cop
          module Test
            class Foo < Base
              def configured?
                cop_config['Safe']
                cop_config['SafeAutoCorrect']
                cop_config['AutoCorrect']
                cop_config['Severity']
              end
            end
          end
        end
      end
    RUBY
  end

  it 'registers an offense when the cop has no configuration at all' do
    expect_offense(<<~RUBY)
      module RuboCop
        module Cop
          module Test
            class Bar < Base
              def configured?
                cop_config['Missing']
                           ^^^^^^^^^ `Missing` is not defined in the configuration for `Test/Bar` in `config/default.yml`.
              end
            end
          end
        end
      end
    RUBY
  end

  it 'registers an offense when the cop is not within the `RuboCop::Cop` namespace' do
    expect_offense(<<~RUBY)
      module Test
        class Foo < Base
          def configured?
            cop_config['Defined']
            cop_config['Missing']
                       ^^^^^^^^^ `Missing` is not defined in the configuration for `Test/Foo` in `config/default.yml`.
          end
        end
      end
    RUBY
  end

  it 'registers an offense when the cop inherits `Cop::Base`' do
    expect_offense(<<~RUBY)
      module Test
        class Foo < Cop::Base
          def configured?
            cop_config['Defined']
            cop_config['Missing']
                       ^^^^^^^^^ `Missing` is not defined in the configuration for `Test/Foo` in `config/default.yml`.
          end
        end
      end
    RUBY
  end

  it 'registers an offense when the cop inherits `RuboCop::Cop::Base`' do
    expect_offense(<<~RUBY)
      module Test
        class Foo < RuboCop::Cop::Base
          def configured?
            cop_config['Defined']
            cop_config['Missing']
                       ^^^^^^^^^ `Missing` is not defined in the configuration for `Test/Foo` in `config/default.yml`.
          end
        end
      end
    RUBY
  end

  it 'registers an offense when the cop inherits `::RuboCop::Cop::Base`' do
    expect_offense(<<~RUBY)
      module Test
        class Foo < ::RuboCop::Cop::Base
          def configured?
            cop_config['Defined']
            cop_config['Missing']
                       ^^^^^^^^^ `Missing` is not defined in the configuration for `Test/Foo` in `config/default.yml`.
          end
        end
      end
    RUBY
  end

  context 'element lookup' do
    it 'does not register an offense for defined configuration keys' do
      expect_no_offenses(<<~RUBY)
        module RuboCop
          module Cop
            module Test
              class Foo < Base
                def configured?
                  cop_config['Defined']
                end
              end
            end
          end
        end
      RUBY
    end

    it 'registers an offense for missing configuration keys' do
      expect_offense(<<~RUBY)
        module RuboCop
          module Cop
            module Test
              class Foo < Base
                def configured?
                  cop_config['Missing']
                             ^^^^^^^^^ `Missing` is not defined in the configuration for `Test/Foo` in `config/default.yml`.
                end
              end
            end
          end
        end
      RUBY
    end
  end

  context 'fetch' do
    it 'does not register an offense for defined configuration keys' do
      expect_no_offenses(<<~RUBY)
        module RuboCop
          module Cop
            module Test
              class Foo < Base
                def configured?
                  cop_config.fetch('Defined')
                end
              end
            end
          end
        end
      RUBY
    end

    it 'registers an offense for missing configuration keys' do
      expect_offense(<<~RUBY)
        module RuboCop
          module Cop
            module Test
              class Foo < Base
                def configured?
                  cop_config.fetch('Missing')
                                   ^^^^^^^^^ `Missing` is not defined in the configuration for `Test/Foo` in `config/default.yml`.
                end
              end
            end
          end
        end
      RUBY
    end

    context 'with a default value' do
      it 'does not register an offense for defined configuration keys' do
        expect_no_offenses(<<~RUBY)
          module RuboCop
            module Cop
              module Test
                class Foo < Base
                  def configured?
                    cop_config.fetch('Defined', default)
                  end
                end
              end
            end
          end
        RUBY
      end

      it 'registers an offense for missing configuration keys' do
        expect_offense(<<~RUBY)
          module RuboCop
            module Cop
              module Test
                class Foo < Base
                  def configured?
                    cop_config.fetch('Missing', default)
                                     ^^^^^^^^^ `Missing` is not defined in the configuration for `Test/Foo` in `config/default.yml`.
                  end
                end
              end
            end
          end
        RUBY
      end
    end
  end

  it 'works with deeper nested cop names' do
    expect_offense(<<~RUBY)
      module RuboCop
        module Cop
          module X
            module Y
              class Z < Base
                def configured?
                  cop_config['Defined']
                  cop_config['Missing']
                             ^^^^^^^^^ `Missing` is not defined in the configuration for `X/Y/Z` in `config/default.yml`.
                end
              end
            end
          end
        end
      end
    RUBY
  end

  # TODO: Remove this test when the `Cop` base class is removed
  it 'works when the base class is `Cop` instead of `Base`' do
    expect_offense(<<~RUBY)
      module RuboCop
        module Cop
          module Test
            class Foo < Cop
              def configured?
                cop_config['Defined']
                cop_config['Missing']
                           ^^^^^^^^^ `Missing` is not defined in the configuration for `Test/Foo` in `config/default.yml`.
              end
            end
          end
        end
      end
    RUBY
  end

  it 'ignores `cop_config` in non-cop classes' do
    expect_no_offenses(<<~RUBY)
      class Test
        def configured?
          cop_config['Missing']
        end
      end
    RUBY
  end

  it 'ignores `cop_config` in non-cop subclasses' do
    expect_no_offenses(<<~RUBY)
      module M
        class C < ApplicationRecord::Base
          def configured?
            cop_config['Missing']
          end
        end
      end
    RUBY
  end

  it 'does not register an offense if using `cop_config` outside of a cop class' do
    expect_no_offenses(<<~RUBY)
      def configured?
        cop_config['Missing']
      end
    RUBY
  end

  it 'can handle an empty file' do
    expect_no_offenses('')
  end
end
