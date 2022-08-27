# frozen_string_literal: true

RSpec.shared_examples_for 'empty_lines_around_class_or_module_body' do |type|
  context 'when EnforcedStyle is empty_lines_special' do
    let(:cop_config) { { 'EnforcedStyle' => 'empty_lines_special' } }

    context 'when first child is a method' do
      it "requires blank line at the beginning and ending of #{type} body" do
        expect_no_offenses(<<~RUBY)
          #{type} SomeObject

            def do_something; end

          end
        RUBY
      end

      context 'source without blank lines' do
        it "registers an offense for #{type} not beginning and ending with a blank line" do
          expect_offense(<<~RUBY)
            #{type} SomeObject
              def do_something; end
            ^ #{missing_begin}
            end
            ^ #{missing_end}
          RUBY

          expect_correction(<<~RUBY)
            #{type} SomeObject

              def do_something; end

            end
          RUBY
        end
      end

      context "when #{type} has a namespace" do
        it 'requires no empty lines for namespace but ' \
           "requires blank line at the beginning and ending of #{type} body" do
          expect_no_offenses(<<~RUBY)
            #{type} Parent
              #{type} SomeObject

                def do_something
                end

              end
            end
          RUBY
        end

        context 'source without blank lines' do
          it 'registers and autocorrects the offenses' do
            expect_offense(<<~RUBY)
              #{type} Parent
                #{type} SomeObject
                  def do_something
              ^ #{missing_begin}
                  end
                end
              ^ #{missing_end}
              end
            RUBY

            expect_correction(<<~RUBY)
              #{type} Parent
                #{type} SomeObject

                  def do_something
                  end

                end
              end
            RUBY
          end
        end

        context 'source with blank lines' do
          it 'autocorrects the offenses' do
            expect_offense(<<~RUBY)
              #{type} Parent

              ^{} #{extra_begin}
                #{type} SomeObject

                  def do_something
                  end

                end

              ^{} #{extra_end}
              end
            RUBY

            expect_correction(<<~RUBY)
              #{type} Parent
                #{type} SomeObject

                  def do_something
                  end

                end
              end
            RUBY
          end
        end
      end
    end

    context 'when first child is an access modifier' do
      context "with blank lines at the beginning and ending of #{type} body" do
        it 'registers no offense' do
          expect_no_offenses(<<~RUBY)
            #{type} SomeObject

              private
              def do_something; end

            end
          RUBY
        end
      end

      context "with no blank lines at the beginning and ending of #{type} body" do
        it 'registers and corrects an offense' do
          expect_offense(<<~RUBY)
            #{type} SomeObject
              private
            ^ #{missing_begin}
              def do_something; end
            end
            ^ #{missing_end}
          RUBY

          expect_correction(<<~RUBY)
            #{type} SomeObject

              private
              def do_something; end

            end
          RUBY
        end
      end
    end

    context 'when first child is NOT a method' do
      it "does not require blank line at the beginning of #{type} body " \
         'but requires blank line before first def definition ' \
         "and requires blank line at the end of #{type} body" do
        expect_no_offenses(<<~RUBY)
          #{type} SomeObject
            include Something

            def do_something; end

          end
        RUBY
      end

      context 'source without blank lines' do
        it "registers an offense for #{type} not ending with a blank line" do
          expect_offense(<<~RUBY)
            #{type} SomeObject
              include Something
              def do_something; end
            ^ #{missing_def}
            end
            ^ #{missing_end}
          RUBY

          expect_correction(<<~RUBY)
            #{type} SomeObject
              include Something

              def do_something; end

            end
          RUBY
        end
      end

      context 'source with blank lines' do
        it "registers an offense for #{type} beginning with a blank line" do
          expect_offense(<<~RUBY)
            #{type} SomeObject

            ^{} #{extra_begin}
              include Something
              def do_something; end
            ^ #{missing_def}

            end
          RUBY

          expect_correction(<<~RUBY)
            #{type} SomeObject
              include Something

              def do_something; end

            end
          RUBY
        end
      end

      context 'source with comment before method definition' do
        it "registers an offense for #{type} beginning with a blank line" do
          expect_offense(<<~RUBY)
            #{type} SomeObject

            ^{} #{extra_begin}
              include Something
              # Comment
            ^ #{missing_def}
              def do_something; end

            end
          RUBY

          expect_correction(<<~RUBY)
            #{type} SomeObject
              include Something

              # Comment
              def do_something; end

            end
          RUBY
        end
      end

      context "when #{type} has a namespace" do
        it 'requires no empty lines for namespace ' \
           "and does not require blank line at the beginning of #{type} body " \
           "but requires blank line at the end of #{type} body" do
          expect_no_offenses(<<~RUBY)
            #{type} Parent
              #{type} SomeObject
                include Something

                def do_something
                end

              end
            end
          RUBY
        end

        context 'source without blank lines' do
          it 'registers and autocorrects the offenses' do
            expect_offense(<<~RUBY)
              #{type} Parent
                #{type} SomeObject
                  include Something
                  def do_something
              ^ #{missing_def}
                  end
                end
              ^ #{missing_end}
              end
            RUBY

            expect_correction(<<~RUBY)
              #{type} Parent
                #{type} SomeObject
                  include Something

                  def do_something
                  end

                end
              end
            RUBY
          end
        end

        context 'source with blank lines' do
          it 'registers and autocorrects the offenses' do
            expect_offense(<<~RUBY)
              #{type} Parent

              ^{} #{extra_begin}
                #{type} SomeObject

              ^{} #{extra_begin}
                  include Something

                  def do_something
                  end

                end

              ^{} #{extra_end}
              end
            RUBY

            expect_correction(<<~RUBY)
              #{type} Parent
                #{type} SomeObject
                  include Something

                  def do_something
                  end

                end
              end
            RUBY
          end
        end

        context 'source with constants' do
          it 'registers and autocorrects the offenses' do
            expect_offense(<<~RUBY)
              #{type} Parent
                #{type} SomeObject
                  URL = %q(http://example.com)
                  def do_something
              ^ #{missing_def}
                  end
                end
              ^ #{missing_end}
              end
            RUBY

            expect_correction(<<~RUBY)
              #{type} Parent
                #{type} SomeObject
                  URL = %q(http://example.com)

                  def do_something
                  end

                end
              end
            RUBY
          end
        end
      end
    end

    context 'when namespace has multiple children' do
      it 'requires empty lines for namespace' do
        expect_no_offenses(<<~RUBY)
          #{type} Parent

            #{type} Mom

              def do_something
              end

            end
            #{type} Dad

            end

          end
        RUBY
      end
    end

    context "#{type} with only constants" do
      it 'registers and autocorrects the offenses' do
        expect_offense(<<~RUBY)
          #{type} Parent
            #{type} SomeObject
              URL = %q(http://example.com)
              WSDL = %q(http://example.com/wsdl)
            end
          ^ #{missing_end}
          end
        RUBY

        expect_correction(<<~RUBY)
          #{type} Parent
            #{type} SomeObject
              URL = %q(http://example.com)
              WSDL = %q(http://example.com/wsdl)

            end
          end
        RUBY
      end
    end

    context "#{type} with constant and child #{type}" do
      it 'registers and autocorrects the offenses' do
        expect_offense(<<~RUBY)
          #{type} Parent
            URL = %q(http://example.com)
            #{type} SomeObject
          ^ #{missing_type}
              def do_something; end
          ^ #{missing_begin}
            end
          ^ #{missing_end}
          end
          ^ #{missing_end}
        RUBY

        expect_correction(<<~RUBY)
          #{type} Parent
            URL = %q(http://example.com)

            #{type} SomeObject

              def do_something; end

            end

          end
        RUBY
      end
    end

    context "#{type} with empty body" do
      context 'with empty line' do
        let(:source) do
          <<~RUBY
            #{type} SomeObject

            end
          RUBY
        end

        it 'does NOT register offenses' do
          expect_no_offenses(source)
        end
      end

      context 'without empty line' do
        let(:source) do
          <<~RUBY
            #{type} SomeObject
            end
          RUBY
        end

        it 'does NOT register offenses' do
          expect_no_offenses(source)
        end
      end
    end
  end
end
