# frozen_string_literal: true

describe RuboCop::Cop::Style::RescueStandardError, :config do
  subject(:cop) { described_class.new(config) }

  context 'implicit' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'implicit',
        'SupportedStyles' => %w[implicit explicit] }
    end

    context 'when rescuing in a begin block' do
      it 'accpets rescuing no error class' do
        expect_no_offenses(<<-RUBY.strip_indent)
          begin
            foo
          rescue
            bar
          end
        RUBY
      end

      it 'accepts rescuing no error class, assigned to a variable' do
        expect_no_offenses(<<-RUBY.strip_indent)
          begin
            foo
          rescue => e
            bar
          end
        RUBY
      end

      it 'accepts rescuing a single error class other than StandardError' do
        expect_no_offenses(<<-RUBY.strip_indent)
          begin
            foo
          rescue BarError
            bar
          end
        RUBY
      end

      it 'accepts rescuing a single error class other than StandardError, ' \
        'assigned to a variable' do
        expect_no_offenses(<<-RUBY.strip_indent)
          begin
            foo
          rescue BarError => e
            bar
          end
        RUBY
      end

      context 'when rescuing StandardError by itself' do
        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            begin
              foo
            rescue StandardError
            ^^^^^^^^^^^^^^^^^^^^ Omit the error class when rescuing `StandardError` by itself.
              bar
            end
          RUBY
        end

        it 'autocorrect will remove StandardError' do
          new_source = autocorrect_source(<<-RUBY.strip_indent)
            begin
              foo
            rescue StandardError
              bar
            end
          RUBY

          expect(new_source).to eq(<<-RUBY.strip_indent)
            begin
              foo
            rescue
              bar
            end
          RUBY
        end

        context 'when the error is assigned to a variable' do
          it 'registers an offense' do
            expect_offense(<<-RUBY.strip_indent)
              begin
                foo
              rescue StandardError => e
              ^^^^^^^^^^^^^^^^^^^^ Omit the error class when rescuing `StandardError` by itself.
                bar
              end
            RUBY
          end

          it 'autocorrect will remove StandardError' do
            new_source = autocorrect_source(<<-RUBY.strip_indent)
              begin
                foo
              rescue StandardError => e
                bar
              end
            RUBY

            expect(new_source).to eq(<<-RUBY.strip_indent)
              begin
                foo
              rescue => e
                bar
              end
            RUBY
          end
        end
      end

      it 'accepts rescuing StandardError with other errors' do
        expect_no_offenses(<<-RUBY.strip_indent)
          begin
            foo
          rescue StandardError, BarError
            bar
          rescue BazError, StandardError
            baz
          end
        RUBY
      end

      it 'accepts rescuing StandardError with other errors, ' \
        'assigned to a variable' do
        expect_no_offenses(<<-RUBY.strip_indent)
          begin
            foo
          rescue StandardError, BarError => e
            bar
          rescue BazError, StandardError => e
            baz
          end
        RUBY
      end
    end

    context 'when rescuing in a method definition' do
      it 'accepts rescuing no error class' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def baz
            foo
          rescue
            bar
          end
        RUBY
      end

      it 'accepts rescuing no error class, assigned to a variable' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def baz
            foo
          rescue => e
            bar
          end
        RUBY
      end

      it 'accepts rescuing a single error other than StandardError' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def baz
            foo
          rescue BarError
            bar
          end
        RUBY
      end

      it 'accepts rescuing a single error other than StandardError, ' \
        'assigned to a variable' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def baz
            foo
          rescue BarError => e
            bar
          end
        RUBY
      end

      context 'when rescuing StandardError by itself' do
        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            def foobar
              foo
            rescue StandardError
            ^^^^^^^^^^^^^^^^^^^^ Omit the error class when rescuing `StandardError` by itself.
              bar
            end
          RUBY
        end

        it 'autocorrect will remove StandardError' do
          new_source = autocorrect_source(<<-RUBY.strip_indent)
            def foobar
              foo
            rescue StandardError
              bar
            end
          RUBY

          expect(new_source).to eq(<<-RUBY.strip_indent)
            def foobar
              foo
            rescue
              bar
            end
          RUBY
        end

        context 'when the error is assigned to a variable' do
          it 'registers an offense' do
            expect_offense(<<-RUBY.strip_indent)
              def foobar
                foo
              rescue StandardError => e
              ^^^^^^^^^^^^^^^^^^^^ Omit the error class when rescuing `StandardError` by itself.
                bar
              end
            RUBY
          end

          it 'autocorrect will remove StandardError' do
            new_source = autocorrect_source(<<-RUBY.strip_indent)
              def foobar
                foo
              rescue StandardError => e
                bar
              end
            RUBY

            expect(new_source).to eq(<<-RUBY.strip_indent)
              def foobar
                foo
              rescue => e
                bar
              end
            RUBY
          end
        end
      end

      it 'accepts rescuing StandardError with other errors' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def foobar
            foo
          rescue StandardError, BarError
            bar
          rescue BazError, StandardError
            baz
          end
        RUBY
      end

      it 'accepts rescuing StandardError with other errors, ' \
        'assigned to a variable' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def foobar
            foo
          rescue StandardError, BarError => e
            bar
          rescue BazError, StandardError => e
            baz
          end
        RUBY
      end
    end

    it 'accepts rescue modifier' do
      expect_no_offenses(<<-RUBY.strip_indent)
        foo rescue 42
      RUBY
    end
  end

  context 'explicit' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'explicit',
        'SupportedStyles' => %w[implicit explicit] }
    end

    context 'when rescuing in a begin block' do
      context 'when calling rescue without an error class' do
        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            begin
              foo
            rescue
            ^^^^^^ Avoid rescuing without specifying an error class.
              bar
            end
          RUBY
        end

        it 'autocorrect will add StandardError' do
          new_source = autocorrect_source(<<-RUBY.strip_indent)
            begin
              foo
            rescue
              bar
            end
          RUBY

          expect(new_source).to eq(<<-RUBY.strip_indent)
            begin
              foo
            rescue StandardError
              bar
            end
          RUBY
        end

        context 'when the error is assigned to a variable' do
          it 'registers an offense' do
            expect_offense(<<-RUBY.strip_indent)
              begin
                foo
              rescue => e
              ^^^^^^ Avoid rescuing without specifying an error class.
                bar
              end
            RUBY
          end

          it 'autocorrect will add StandardError' do
            new_source = autocorrect_source(<<-RUBY.strip_indent)
              begin
                foo
              rescue => e
                bar
              end
            RUBY

            expect(new_source).to eq(<<-RUBY.strip_indent)
              begin
                foo
              rescue StandardError => e
                bar
              end
            RUBY
          end
        end
      end

      it 'accepts rescuing a single error other than StandardError' do
        expect_no_offenses(<<-RUBY.strip_indent)
          begin
            foo
          rescue BarError
            bar
          end
        RUBY
      end

      it 'accepts rescuing a single error other than StandardError' \
        'assigned to a variable' do
        expect_no_offenses(<<-RUBY.strip_indent)
          begin
            foo
          rescue BarError => e
            bar
          end
        RUBY
      end

      it 'accepts rescuing StandardError by itself' do
        expect_no_offenses(<<-RUBY.strip_indent)
          begin
            foo
          rescue StandardError
            bar
          end
        RUBY
      end

      it 'accepts rescuing StandardError by itself, assigned to a variable' do
        expect_no_offenses(<<-RUBY.strip_indent)
          begin
            foo
          rescue StandardError => e
            bar
          end
        RUBY
      end

      it 'accepts rescuing StandardError with other errors' do
        expect_no_offenses(<<-RUBY.strip_indent)
          begin
            foo
          rescue StandardError, BarError
            bar
          rescue BazError, StandardError
            baz
          end
        RUBY
      end

      it 'accepts rescuing StandardError with other errors, ' \
        'assigned to a variable' do
        expect_no_offenses(<<-RUBY.strip_indent)
          begin
            foo
          rescue StandardError, BarError => e
            bar
          rescue BazError, StandardError => e
            baz
          end
        RUBY
      end
    end

    context 'when rescuing in a method definition' do
      context 'when rescue is called without an error class' do
        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            def baz
              foo
            rescue
            ^^^^^^ Avoid rescuing without specifying an error class.
              bar
            end
          RUBY
        end

        it 'autocorrect will add StandardError' do
          new_source = autocorrect_source(<<-RUBY.strip_indent)
            def baz
              foo
            rescue
              bar
            end
          RUBY

          expect(new_source).to eq(<<-RUBY.strip_indent)
            def baz
              foo
            rescue StandardError
              bar
            end
          RUBY
        end
      end

      context 'when the error is assigned to a variable' do
        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            def baz
              foo
            rescue => e
            ^^^^^^ Avoid rescuing without specifying an error class.
              bar
            end
          RUBY
        end

        it 'autocorrect will add StandardError' do
          new_source = autocorrect_source(<<-RUBY.strip_indent)
            def baz
              foo
            rescue => e
              bar
            end
          RUBY

          expect(new_source).to eq(<<-RUBY.strip_indent)
            def baz
              foo
            rescue StandardError => e
              bar
            end
          RUBY
        end
      end

      it 'accepts rescueing a single error other than StandardError' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def baz
            foo
          rescue BarError
            bar
          end
        RUBY
      end

      it 'accepts rescueing a single error other than StandardError, ' \
        'assigned to a variable' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def baz
            foo
          rescue BarError => e
            bar
          end
        RUBY
      end

      it 'accepts rescuing StandardError by itself' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def foobar
            foo
          rescue StandardError
            bar
          end
        RUBY
      end

      it 'accepts rescuing StandardError by itself, assigned to a variable' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def foobar
            foo
          rescue StandardError => e
            bar
          end
        RUBY
      end

      it 'accepts rescuing StandardError with other errors' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def foobar
            foo
          rescue StandardError, BarError
            bar
          rescue BazError, StandardError
            baz
          end
        RUBY
      end

      it 'accepts rescuing StandardError with other errors, ' \
        'assigned to a variable' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def foobar
            foo
          rescue StandardError, BarError => e
            bar
          rescue BazError, StandardError => e
            baz
          end
        RUBY
      end
    end

    it 'accepts rescue modifier' do
      expect_no_offenses(<<-RUBY.strip_indent)
        foo rescue 42
      RUBY
    end
  end
end
