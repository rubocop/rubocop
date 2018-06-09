# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLinesAroundBlockBody, :config do
  subject(:cop) { described_class.new(config) }

  # Test blocks using both {} and do..end
  [%w[{ }], %w[do end]].each do |open, close|
    context "when EnforcedStyle is no_empty_lines for #{open} #{close} block" do
      let(:cop_config) { { 'EnforcedStyle' => 'no_empty_lines' } }

      it 'registers an offense for block body starting with a blank' do
        inspect_source(<<-RUBY.strip_indent)
          some_method #{open}

            do_something
          #{close}
        RUBY

        expect(cop.messages)
          .to eq(['Extra empty line detected at block body beginning.'])
      end

      it 'autocorrects block body containing only a blank' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          some_method #{open}

          #{close}
        RUBY

        expect(corrected).to eq(<<-RUBY.strip_indent)
          some_method #{open}
          #{close}
        RUBY
      end

      it 'registers an offense for block body ending with a blank' do
        inspect_source(<<-RUBY.strip_indent)
          some_method #{open}
            do_something

            #{close}
        RUBY

        expect(cop.messages)
          .to eq(['Extra empty line detected at block body end.'])
      end

      it 'accepts block body starting with a line with spaces' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method #{open}
            
            do_something
          #{close}
        RUBY
      end

      it 'is not fooled by single line blocks' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method #{open} do_something #{close}

          something_else
        RUBY
      end
    end

    context "when EnforcedStyle is empty_lines for #{open} #{close} block" do
      let(:cop_config) { { 'EnforcedStyle' => 'empty_lines' } }

      it 'registers an offense for block body not starting or ending with a ' \
         'blank' do
        inspect_source(<<-RUBY.strip_indent)
          some_method #{open}
            do_something
          #{close}
        RUBY

        expect(cop.messages).to eq(['Empty line missing at block body '\
                                    'beginning.',
                                    'Empty line missing at block body end.'])
      end

      it 'ignores block with an empty body' do
        source = "some_method #{open}\n#{close}"
        corrected = autocorrect_source(source)
        expect(corrected).to eq(source)
      end

      it 'autocorrects beginning and end' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          some_method #{open}
            do_something
          #{close}
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          some_method #{open}

            do_something

          #{close}
        RUBY
      end

      it 'is not fooled by single line blocks' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method #{open} do_something #{close}
          something_else
        RUBY
      end
    end
  end
end
