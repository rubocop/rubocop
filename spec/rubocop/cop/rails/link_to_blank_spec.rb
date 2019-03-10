# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::LinkToBlank do
  subject(:cop) { described_class.new }

  context 'when not using target _blank' do
    it 'does not register an offence' do
      expect_no_offenses(<<-RUBY.strip_indent)
        link_to 'Click here', 'https://www.example.com'
      RUBY
    end

    it 'does not register an offence when passing options' do
      expect_no_offenses(<<-RUBY.strip_indent)
        link_to 'Click here', 'https://www.example.com', class: 'big'
      RUBY
    end

    it 'does not register an offence when using the block syntax' do
      expect_no_offenses(<<-RUBY.strip_indent)
        link_to 'https://www.example.com', class: 'big' do
          "Click Here"
        end
      RUBY
    end
  end

  context 'when using target_blank' do
    context 'when using no rel' do
      it 'registers and corrects an offence' do
        expect_offense(<<-RUBY.strip_indent)
          link_to 'Click here', 'https://www.example.com', target: '_blank'
                                                           ^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          link_to 'Click here', 'https://www.example.com', target: '_blank', rel: 'noopener'
        RUBY
      end

      it 'registers an offence when using a string for the target key' do
        expect_offense(<<-RUBY.strip_indent)
          link_to 'Click here', 'https://www.example.com', "target" => '_blank'
                                                           ^^^^^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
        RUBY
      end

      it 'registers an offence when using a symbol for the target value' do
        expect_offense(<<-RUBY.strip_indent)
          link_to 'Click here', 'https://www.example.com', target: :_blank
                                                           ^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
        RUBY
      end

      it 'registers an offence and auto-corrects when using the block syntax' do
        expect_offense(<<-RUBY.strip_indent)
          link_to 'https://www.example.com', target: '_blank' do
                                             ^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
            "Click here"
          end
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          link_to 'https://www.example.com', target: '_blank', rel: 'noopener' do
            "Click here"
          end
        RUBY
      end

      it 'autocorrects with a new rel when using the block syntax ' \
         'with parenthesis' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          link_to('https://www.example.com', target: '_blank') do
            "Click here"
          end
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          link_to('https://www.example.com', target: '_blank', rel: 'noopener') do
            "Click here"
          end
        RUBY
      end
    end

    context 'when using rel' do
      context 'when the rel does not contain noopener' do
        it 'registers an offence and corrects' do
          expect_offense(<<-RUBY.strip_indent)
            link_to 'Click here', 'https://www.example.com', "target" => '_blank', rel: 'unrelated'
                                                             ^^^^^^^^^^^^^^^^^^^^ Specify a `:rel` option containing noopener.
          RUBY

          expect_correction(<<-RUBY.strip_indent)
            link_to 'Click here', 'https://www.example.com', "target" => '_blank', rel: 'unrelated noopener'
          RUBY
        end
      end

      context 'when the rel contains noopener' do
        it 'register no offence' do
          expect_no_offenses(<<-RUBY.strip_indent)
            link_to 'Click here', 'https://www.example.com', target: '_blank', rel: 'noopener noreferrer'
          RUBY
        end
      end
    end
  end
end
