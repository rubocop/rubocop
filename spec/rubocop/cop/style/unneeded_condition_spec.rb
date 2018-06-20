# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::UnneededCondition do
  subject(:cop) { described_class.new }

  context 'when regular condition (if)' do
    it 'registers no offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if a
          b
        else
          c
        end
      RUBY
    end

    it 'registers no offense for elsif' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if a
          b
        elsif d
          d
        else
          c
        end
      RUBY
    end

    context 'when condition and if_branch are same' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          if b
          ^^^^ Use double pipes `||` instead.
            b
          else
            y(x,
              z)
          end
        RUBY
      end

      context 'when else_branch is complex' do
        it 'registers no offense' do
          expect_no_offenses(<<-RUBY.strip_indent)
            if b
              b
            else
              c
              d
            end
          RUBY
        end
      end

      context 'when using elsif branch' do
        it 'registers no offense' do
          expect_no_offenses(<<-RUBY.strip_indent)
            if a
              a
            elsif cond
              d
            end
          RUBY
        end
      end

      context 'when using modifier if' do
        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            bar if bar
            ^^^^^^^^^^ This condition is not needed.
          RUBY
        end
      end

      context 'when using ternary if in `else` branch' do
        it 'registers no offense' do
          expect_no_offenses(<<-RUBY.strip_indent)
            if a
              a
            else
              b ? c : d
            end
          RUBY
        end
      end
    end

    describe '#autocorrection' do
      it 'auto-corrects offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          if b
            b
          else
            c
          end
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          b || c
        RUBY
      end

      it 'auto-corrects multiline sendNode offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          if b
            b
          else
            y(x,
              z)
          end
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          b || y(x,
              z)
        RUBY
      end

      it 'auto-corrects one-line node offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          if b
            b
          else
            (c || d)
          end
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          b || (c || d)
        RUBY
      end

      it 'auto-corrects modifier nodes offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          if b
            b
          else
            c while d
          end
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          b || (c while d)
        RUBY
      end

      it 'auto-corrects modifer if statements' do
        new_source = autocorrect_source('bar if bar')

        expect(new_source).to eq('bar')
      end
    end
  end

  context 'when ternary expression (?:)' do
    it 'registers no offense' do
      expect_no_offenses('b ? d : c')
    end

    context 'when condition and if_branch are same' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          b ? b : c
            ^^^^^ Use double pipes `||` instead.
        RUBY
      end
    end

    describe '#autocorrection' do
      it 'auto-corrects vars' do
        new_source = autocorrect_source('a = b ? b : c')
        expect(new_source).to eq('a = b || c')
      end

      it 'auto-corrects nested vars' do
        new_source = autocorrect_source('b.x ? b.x : c')
        expect(new_source).to eq('b.x || c')
      end

      it 'auto-corrects class vars' do
        new_source = autocorrect_source('@b ? @b : c')
        expect(new_source).to eq('@b || c')
      end

      it 'auto-corrects functions' do
        new_source = autocorrect_source('a = b(x) ? b(x) : c')
        expect(new_source).to eq('a = b(x) || c')
      end
    end
  end
end
