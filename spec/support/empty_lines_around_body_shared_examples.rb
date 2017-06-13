# frozen_string_literal: true

shared_examples_for 'empty_lines_around_class_or_module_body' do |type|
  context 'when EnforcedStyle is empty_lines_special' do
    let(:cop_config) { { 'EnforcedStyle' => 'empty_lines_special' } }

    context 'when first child is method' do
      it "requires blank line at the beginning and ending of #{type} body" do
        inspect_source(<<-RUBY.strip_indent)
          #{type} SomeObject

            def do_something; end

          end
        RUBY
        expect(cop.messages).to eq([])
      end

      context 'source without blank lines' do
        let(:source) do
          <<-RUBY.strip_indent
            #{type} SomeObject
              def do_something; end
            end
          RUBY
        end

        it "registers an offense for #{type} not beginning "\
          'and ending with a blank line' do
          inspect_source(source)
          expect(cop.messages).to eq([missing_begin, missing_end])
        end

        it 'autocorrects the offenses' do
          new_source = autocorrect_source(cop, source)
          expect(new_source).to eq(<<-RUBY.strip_indent)
            #{type} SomeObject

              def do_something; end

            end
          RUBY
        end
      end

      context "when #{type} has a namespace" do
        it 'requires no empty lines for namespace but '\
          "requires blank line at the beginning and ending of #{type} body" do
          inspect_source(<<-RUBY.strip_indent)
            #{type} Parent
              #{type} SomeObject

                def do_something
                end

              end
            end
          RUBY
          expect(cop.messages).to eq([])
        end

        context 'source without blank lines' do
          let(:source) do
            <<-RUBY.strip_indent
              #{type} Parent
                #{type} SomeObject
                  def do_something
                  end
                end
              end
            RUBY
          end

          it 'autocorrects the offenses' do
            new_source = autocorrect_source(cop, source)
            expect(new_source).to eq(<<-RUBY.strip_indent)
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
          let(:source) do
            <<-RUBY.strip_indent
              #{type} Parent

                #{type} SomeObject

                  def do_something
                  end

                end

              end
            RUBY
          end

          it 'autocorrects the offenses' do
            new_source = autocorrect_source(cop, source)
            expect(new_source).to eq(<<-RUBY.strip_indent)
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

    context 'when first child is NOT a method' do
      it "does not require blank line at the beginning of #{type} body "\
        'but requires blank line before first def definition '\
        "and requires blank line at the end of #{type} body" do
        inspect_source(<<-RUBY.strip_indent)
          #{type} SomeObject
            include Something

            def do_something; end

          end
        RUBY
        expect(cop.messages).to eq([])
      end

      context 'source without blank lines' do
        let(:source) do
          <<-RUBY.strip_indent
            #{type} SomeObject
              include Something
              def do_something; end
            end
          RUBY
        end

        it "registers an offense for #{type} not ending with a blank line" do
          inspect_source(source)
          expect(cop.messages).to eq([missing_def, missing_end])
        end

        it 'autocorrects the offenses' do
          new_source = autocorrect_source(cop, source)
          expect(new_source).to eq(<<-RUBY.strip_indent)
            #{type} SomeObject
              include Something

              def do_something; end

            end
          RUBY
        end
      end

      context 'source with blank lines' do
        let(:source) do
          <<-RUBY.strip_indent
            #{type} SomeObject

              include Something
              def do_something; end

            end
          RUBY
        end

        it "registers an offense for #{type} beginning with a blank line" do
          inspect_source(source)
          expect(cop.messages).to eq([extra_begin, missing_def])
        end

        it 'autocorrects the offenses' do
          new_source = autocorrect_source(cop, source)
          expect(new_source).to eq(<<-RUBY.strip_indent)
            #{type} SomeObject
              include Something

              def do_something; end

            end
          RUBY
        end
      end

      context 'source with comment before method definition' do
        let(:source) do
          <<-RUBY.strip_indent
            #{type} SomeObject

              include Something
              # Comment
              def do_something; end

            end
          RUBY
        end

        it "registers an offense for #{type} beginning with a blank line" do
          inspect_source(source)
          expect(cop.messages).to eq([extra_begin, missing_def])
        end

        it 'autocorrects the offenses' do
          new_source = autocorrect_source(cop, source)
          expect(new_source).to eq(<<-RUBY.strip_indent)
            #{type} SomeObject
              include Something

              # Comment
              def do_something; end

            end
          RUBY
        end
      end

      context "when #{type} has a namespace" do
        it 'requires no empty lines for namespace '\
          "and does not require blank line at the beginning of #{type} body "\
          "but requires blank line at the end of #{type} body" do
          inspect_source(<<-RUBY.strip_indent)
            #{type} Parent
              #{type} SomeObject
                include Something

                def do_something
                end

              end
            end
          RUBY
          expect(cop.messages).to eq([])
        end

        context 'source without blank lines' do
          let(:source) do
            <<-RUBY.strip_indent
              #{type} Parent
                #{type} SomeObject
                  include Something
                  def do_something
                  end
                end
              end
            RUBY
          end

          it 'autocorrects the offenses' do
            new_source = autocorrect_source(cop, source)
            expect(new_source).to eq(<<-RUBY.strip_indent)
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
          let(:source) do
            <<-RUBY.strip_indent
              #{type} Parent

                #{type} SomeObject

                  include Something

                  def do_something
                  end

                end

              end
            RUBY
          end

          it 'autocorrects the offenses' do
            new_source = autocorrect_source(cop, source)
            expect(new_source).to eq(<<-RUBY.strip_indent)
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
          let(:source) do
            <<-RUBY.strip_indent
              #{type} Parent
                #{type} SomeObject
                  URL = %q(http://example.com)
                  def do_something
                  end
                end
              end
            RUBY
          end

          it 'autocorrects the offenses' do
            new_source = autocorrect_source(cop, source)
            expect(new_source).to eq(<<-RUBY.strip_indent)
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
        inspect_source(<<-RUBY.strip_indent)
          #{type} Parent

            #{type} Mom

              def do_something
              end

            end
            #{type} Dad

            end

          end
        RUBY
        expect(cop.messages).to eq([])
      end
    end

    context "#{type} with only constants" do
      let(:source) do
        <<-RUBY.strip_indent
          #{type} Parent
            #{type} SomeObject
              URL = %q(http://example.com)
              WSDL = %q(http://example.com/wsdl)
            end
          end
        RUBY
      end

      it 'autocorrects the offenses' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(<<-RUBY.strip_indent)
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
      let(:source) do
        <<-RUBY.strip_indent
          #{type} Parent
            URL = %q(http://example.com)
            #{type} SomeObject
              def do_something; end
            end
          end
        RUBY
      end

      it 'registers offenses' do
        inspect_source(source)
        expect(cop.messages).to eq([missing_type,
                                    missing_begin,
                                    missing_end,
                                    missing_end])
      end

      it 'autocorrects the offenses' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(<<-RUBY.strip_indent)
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
          <<-RUBY.strip_indent
            #{type} SomeObject

            end
          RUBY
        end

        it 'does NOT register offenses' do
          inspect_source(source)
          expect(cop.messages).to eq([])
        end
      end

      context 'without empty line' do
        let(:source) do
          <<-RUBY.strip_indent
            #{type} SomeObject
            end
          RUBY
        end

        it 'does NOT register offenses' do
          inspect_source(source)
          expect(cop.messages).to eq([])
        end
      end
    end
  end
end
