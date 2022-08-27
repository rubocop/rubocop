# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::OpenStructUse, :config do
  context 'when using OpenStruct' do
    ['OpenStruct', '::OpenStruct'].each do |klass|
      context "for #{klass}" do
        context 'when used in assignments' do
          it 'registers an offense' do
            expect_offense(<<~RUBY, klass: klass)
              a = %{klass}.new(a: 42)
                  ^{klass} Avoid using `OpenStruct`;[...]
            RUBY
          end
        end

        context 'when inheriting from it via <' do
          it 'registers an offense' do
            expect_offense(<<~RUBY, klass: klass)
              class SubClass < %{klass}
                               ^{klass} Avoid using `OpenStruct`;[...]
              end
            RUBY
          end
        end

        context 'when inheriting from it via Class.new' do
          it 'registers an offense' do
            expect_offense(<<~RUBY, klass: klass)
              SubClass = Class.new(%{klass})
                                   ^{klass} Avoid using `OpenStruct`;[...]
            RUBY
          end
        end
      end
    end
  end

  context 'when using custom namespaced OpenStruct' do
    context 'when inheriting from it' do
      specify { expect_no_offenses('class A < SomeNamespace::OpenStruct; end') }
    end

    context 'when defined in custom namespace' do
      context 'when class' do
        specify do
          expect_no_offenses(<<~RUBY)
            module SomeNamespace
              class OpenStruct
              end
            end
          RUBY
        end
      end

      context 'when module' do
        specify do
          expect_no_offenses(<<~RUBY)
            module SomeNamespace
              module OpenStruct
              end
            end
          RUBY
        end
      end
    end

    context 'when used in assignments' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          a = SomeNamespace::OpenStruct.new
        RUBY
      end
    end
  end

  context 'when not using OpenStruct' do
    it 'registers no offense', :aggregate_failures do
      expect_no_offenses('class A < B; end')
      expect_no_offenses('a = 42')
    end
  end
end
