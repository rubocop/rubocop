# frozen_string_literal: true

describe RuboCop::Cop::Style::EmptyCaseCondition do
  subject(:cop) { described_class.new }

  let(:message) do
    'Do not use empty `case` condition, instead use an `if` expression.'
  end

  shared_examples 'detect/correct empty case, accept non-empty case' do
    it 'registers an offense' do
      inspect_source(source)
      expect(cop.messages).to eq [message]
    end

    it 'correctly autocorrects' do
      expect(autocorrect_source(source)).to eq corrected_source
    end

    let(:source_with_case) { source.sub(/case/, 'case :a') }

    it 'accepts the source with case' do
      inspect_source(source_with_case)
      expect(cop.messages).to be_empty
    end
  end

  context 'given a case statement with an empty case' do
    context 'with multiple when branches and an else' do
      let(:source) do
        <<-RUBY.strip_indent
          case
          when 1 == 2
            foo
          when 1 == 1
            bar
          else
            baz
          end
        RUBY
      end
      let(:corrected_source) do
        <<-RUBY.strip_indent
          if 1 == 2
            foo
          elsif 1 == 1
            bar
          else
            baz
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with multiple when branches and no else' do
      let(:source) do
        <<-RUBY.strip_indent
          case
          when 1 == 2
            foo
          when 1 == 1
            bar
          end
        RUBY
      end
      let(:corrected_source) do
        <<-RUBY.strip_indent
          if 1 == 2
            foo
          elsif 1 == 1
            bar
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with a single when branch and an else' do
      let(:source) do
        <<-RUBY.strip_indent
          case
          when 1 == 2
            foo
          else
            bar
          end
        RUBY
      end
      let(:corrected_source) do
        <<-RUBY.strip_indent
          if 1 == 2
            foo
          else
            bar
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with a single when branch and no else' do
      let(:source) do
        <<-RUBY.strip_indent
          case
          when 1 == 2
            foo
          end
        RUBY
      end
      let(:corrected_source) do
        <<-RUBY.strip_indent
          if 1 == 2
            foo
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with a when branch including comma-delimited alternatives' do
      let(:source) do
        <<-RUBY.strip_indent
          case
          when false
            foo
          when nil, false, 1
            bar
          when false, 1
            baz
          end
        RUBY
      end
      let(:corrected_source) do
        <<-RUBY.strip_indent
          if false
            foo
          elsif nil || false || 1
            bar
          elsif false || 1
            baz
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with when branches using then' do
      let(:source) do
        <<-RUBY.strip_indent
          case
          when false then foo
          when nil, false, 1 then bar
          when false, 1 then baz
          end
        RUBY
      end
      let(:corrected_source) do
        <<-RUBY.strip_indent
          if false then foo
          elsif nil || false || 1 then bar
          elsif false || 1 then baz
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with first when branch including comma-delimited alternatives' do
      let(:source) do
        <<-RUBY.strip_indent
          case
          when my.foo?, my.bar?
            something
          when my.baz?
            something_else
          end
        RUBY
      end
      let(:corrected_source) do
        <<-RUBY.strip_indent
          if my.foo? || my.bar?
            something
          elsif my.baz?
            something_else
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end
  end
end
