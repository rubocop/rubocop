# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NameTypo, :config do
  it 'does not register an offense without a project index' do
    expect_no_offenses(<<~RUBY)
      Services::UserCraetor.new
      Report.generate_sumary
    RUBY
  end

  context 'with a project index', :project_index do
    context 'for constant references' do
      before do
        cop.project_index = build_index(
          'file:///services.rb' => <<~RUBY
            module Services
              class UserCreator
                class Params; end
              end

              class UserDeleter; end
            end
          RUBY
        )
      end

      it 'registers an offense for a typo in a qualified constant' do
        expect_offense(<<~RUBY)
          Services::UserCraetor.new
                    ^^^^^^^^^^^ Possible typo: `UserCraetor` is not defined in `Services`. Did you mean `UserCreator`?
        RUBY
      end

      it 'registers an offense for a typo in an intermediate segment' do
        expect_offense(<<~RUBY)
          Services::UserCraetor::Params.new
                    ^^^^^^^^^^^ Possible typo: `UserCraetor` is not defined in `Services`. Did you mean `UserCreator`?
        RUBY
      end

      it 'does not register an offense when the constant resolves' do
        expect_no_offenses(<<~RUBY)
          Services::UserCreator.new
        RUBY
      end

      it 'does not register an offense when no similarly named sibling exists' do
        expect_no_offenses(<<~RUBY)
          Services::Middleware.new
        RUBY
      end

      it 'does not register an offense for an unqualified reference' do
        expect_no_offenses(<<~RUBY)
          UserCraetor.new
        RUBY
      end

      it 'does not register an offense when the namespace is not indexed' do
        expect_no_offenses(<<~RUBY)
          External::UserCraetor.new
        RUBY
      end

      it 'does not register an offense for a definition of a new member' do
        expect_no_offenses(<<~RUBY)
          class Services::UserRestorer; end
        RUBY
      end

      it 'does not register an offense inside defined?' do
        expect_no_offenses(<<~RUBY)
          defined?(Services::UserCraetor)
        RUBY
      end

      it 'does not register an offense when the name appears in a string literal' do
        expect_no_offenses(<<~RUBY)
          stub_const('Services::UserCraetor', Class.new)
          Services::UserCraetor.new
        RUBY
      end

      context 'when CheckConstants is false' do
        let(:cop_config) { { 'CheckConstants' => false } }

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            Services::UserCraetor.new
          RUBY
        end
      end

      context 'when the name is allowed' do
        let(:cop_config) { { 'AllowedNames' => ['UserCraetor'] } }

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            Services::UserCraetor.new
          RUBY
        end
      end
    end

    context 'for method calls' do
      before do
        cop.project_index = build_index(
          'file:///report.rb' => <<~RUBY
            class Report
              def self.generate_summary; end
              def self.generate_details; end
            end

            module Formatting
              module_function

              def indent_text(text); end
            end
          RUBY
        )
      end

      it 'registers an offense for a typo in a singleton method call' do
        expect_offense(<<~RUBY)
          Report.generate_sumary
                 ^^^^^^^^^^^^^^^ Possible typo: `Report` does not respond to `generate_sumary`. Did you mean `generate_summary`?
        RUBY
      end

      it 'registers an offense for a typo with safe navigation' do
        expect_offense(<<~RUBY)
          Report&.generate_sumary
                  ^^^^^^^^^^^^^^^ Possible typo: `Report` does not respond to `generate_sumary`. Did you mean `generate_summary`?
        RUBY
      end

      it 'registers an offense for a typo in a module_function call' do
        expect_offense(<<~RUBY)
          Formatting.indent_txet('foo')
                     ^^^^^^^^^^^ Possible typo: `Formatting` does not respond to `indent_txet`. Did you mean `indent_text`?
        RUBY
      end

      it 'does not register an offense when the method exists' do
        expect_no_offenses(<<~RUBY)
          Report.generate_summary
        RUBY
      end

      it 'does not register an offense for a module_function method' do
        expect_no_offenses(<<~RUBY)
          Formatting.indent_text('foo')
        RUBY
      end

      it 'does not register an offense when no similarly named method exists' do
        expect_no_offenses(<<~RUBY)
          Report.download
        RUBY
      end

      it 'does not register an offense when the receiver is not indexed' do
        expect_no_offenses(<<~RUBY)
          External.generate_sumary
        RUBY
      end

      it 'does not register an offense without a constant receiver' do
        expect_no_offenses(<<~RUBY)
          report.generate_sumary
        RUBY
      end

      it 'does not register an offense inside defined?' do
        expect_no_offenses(<<~RUBY)
          defined?(Report.generate_sumary)
        RUBY
      end

      it 'does not register an offense when the name appears as a symbol' do
        expect_no_offenses(<<~RUBY)
          Report.define_singleton_method(:generate_sumary) { nil }
          Report.generate_sumary
        RUBY
      end

      context 'with attribute accessors' do
        before do
          cop.project_index = build_index(
            'file:///config.rb' => <<~RUBY
              class Config
                class << self
                  attr_accessor :debug_mode
                end
              end
            RUBY
          )
        end

        it 'does not register an offense for a setter backed by attr_accessor' do
          expect_no_offenses(<<~RUBY)
            Config.debug_mode = true
          RUBY
        end

        it 'registers an offense for a typo in a setter call' do
          expect_offense(<<~RUBY)
            Config.debug_mdoe = true
                   ^^^^^^^^^^ Possible typo: `Config` does not respond to `debug_mdoe=`. Did you mean `debug_mode=`?
          RUBY
        end
      end

      context 'when the ancestry is not fully resolved' do
        before do
          cop.project_index = build_index(
            'file:///report.rb' => <<~RUBY
              class Report < External::Base
                def self.generate_summary; end
              end
            RUBY
          )
        end

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            Report.generate_sumary
          RUBY
        end
      end

      context 'when CheckMethods is false' do
        let(:cop_config) { { 'CheckMethods' => false } }

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            Report.generate_sumary
          RUBY
        end
      end

      context 'when the name is allowed' do
        let(:cop_config) { { 'AllowedNames' => ['generate_sumary'] } }

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            Report.generate_sumary
          RUBY
        end
      end
    end
  end
end
