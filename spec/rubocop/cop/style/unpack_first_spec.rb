# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::UnpackFirst, :config do
  subject(:cop) { described_class.new(config) }

  context 'ruby version >= 2.4', :ruby24 do
    context 'registers offense' do
      it 'when using `#unpack` with `#first`' do
        expect_offense(<<-RUBY.strip_indent)
        x.unpack('h*').first
        ^^^^^^^^^^^^^^^^^^^^ Use `x.unpack1('h*')` instead of `x.unpack('h*').first`.
        RUBY
      end

      it 'when using `#unpack` with square brackets' do
        expect_offense(<<-RUBY.strip_indent)
        ''.unpack(y)[0]
        ^^^^^^^^^^^^^^^ Use `''.unpack1(y)` instead of `''.unpack(y)[0]`.
        RUBY
      end

      it 'when using `#unpack` with dot and square brackets' do
        expect_offense(<<-RUBY.strip_indent)
        ''.unpack(y).[](0)
        ^^^^^^^^^^^^^^^^^^ Use `''.unpack1(y)` instead of `''.unpack(y).[](0)`.
        RUBY
      end

      it 'when using `#unpack` with `#slice`' do
        expect_offense(<<-RUBY.strip_indent)
        ''.unpack(y).slice(0)
        ^^^^^^^^^^^^^^^^^^^^^ Use `''.unpack1(y)` instead of `''.unpack(y).slice(0)`.
        RUBY
      end

      it 'when using `#unpack` with `#at`' do
        expect_offense(<<-RUBY.strip_indent)
        ''.unpack(y).at(0)
        ^^^^^^^^^^^^^^^^^^ Use `''.unpack1(y)` instead of `''.unpack(y).at(0)`.
        RUBY
      end
    end

    context 'does not register offense' do
      it 'when using `#unpack1`' do
        expect_no_offenses(<<-RUBY.strip_indent)
          x.unpack1(y)
        RUBY
      end

      it 'when using `#unpack` accessing second element' do
        expect_no_offenses(<<-RUBY.strip_indent)
          ''.unpack('h*')[1]
        RUBY
      end
    end

    context 'autocorrects' do
      it '`#unpack` with `#first to `#unpack1`' do
        expect(autocorrect_source("x.unpack('h*').first"))
          .to eq("x.unpack1('h*')")
      end

      it 'autocorrects `#unpack` with square brackets' do
        expect(autocorrect_source("x.unpack('h*')[0]"))
          .to eq("x.unpack1('h*')")
      end

      it 'autocorrects `#unpack` with dot and square brackets' do
        expect(autocorrect_source("x.unpack('h*').[](0)"))
          .to eq("x.unpack1('h*')")
      end

      it 'autocorrects `#unpack` with `#slice`' do
        expect(autocorrect_source("x.unpack('h*').slice(0)"))
          .to eq("x.unpack1('h*')")
      end

      it 'autocorrects `#unpack` with `#at`' do
        expect(autocorrect_source("x.unpack('h*').at(0)"))
          .to eq("x.unpack1('h*')")
      end
    end
  end
end
