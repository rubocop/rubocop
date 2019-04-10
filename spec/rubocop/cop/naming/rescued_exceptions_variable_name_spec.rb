# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::RescuedExceptionsVariableName, :config do
  subject(:cop) { described_class.new(config) }

  context 'with default config' do
    context 'with explicit rescue' do
      context 'with `Exception` variable' do
        it 'registers an offense when using `exc`' do
          expect_offense(<<-RUBY.strip_indent)
            begin
              something
            rescue MyException => exc
                                  ^^^ Use `e` instead of `exc`.
              # do something
            end
          RUBY

          expect_correction(<<-RUBY.strip_indent)
            begin
              something
            rescue MyException => e
              # do something
            end
          RUBY
        end

        it 'does not register an offense when using `e`' do
          expect_no_offenses(<<-RUBY.strip_indent)
            begin
              something
            rescue MyException => e
              # do something
            end
          RUBY
        end
      end

      context 'without `Exception` variable' do
        it 'does not register an offense' do
          expect_no_offenses(<<-RUBY.strip_indent)
            begin
              something
            rescue MyException
              # do something
            end
          RUBY
        end
      end
    end

    context 'with implicit rescue' do
      context 'with `Exception` variable' do
        it 'registers an offense when using `exc`' do
          expect_offense(<<-RUBY.strip_indent)
            begin
              something
            rescue exc
                   ^^^ Use `e` instead of `exc`.
              # do something
            end
          RUBY

          expect_correction(<<-RUBY.strip_indent)
            begin
              something
            rescue e
              # do something
            end
          RUBY
        end

        it 'does not register an offense when using `e`' do
          expect_no_offenses(<<-RUBY.strip_indent)
            begin
              something
            rescue e
              # do something
            end
          RUBY
        end
      end

      context 'without `Exception` variable' do
        it 'does not register an offense' do
          expect_no_offenses(<<-RUBY.strip_indent)
            begin
              something
            rescue
              # do something
            end
          RUBY
        end
      end
    end
  end

  context 'with the `PreferredName` setup' do
    let(:cop_config) do
      {
        'PreferredName' => 'exception'
      }
    end

    it 'registers an offense when using `e`' do
      expect_offense(<<-RUBY.strip_indent)
        begin
          something
        rescue MyException => e
                              ^ Use `exception` instead of `e`.
          # do something
        end
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        begin
          something
        rescue MyException => exception
          # do something
        end
      RUBY
    end

    it 'does not register an offense when using `exception`' do
      expect_no_offenses(<<-RUBY.strip_indent)
        begin
          something
        rescue MyException => exception
          # do something
        end
      RUBY
    end
  end
end
