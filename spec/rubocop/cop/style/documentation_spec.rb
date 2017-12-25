# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Documentation do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Style/CommentAnnotation' => {
                          'Keywords' => %w[TODO FIXME OPTIMIZE HACK REVIEW]
                        })
  end

  it 'registers an offense for non-empty class' do
    expect_offense(<<-RUBY.strip_indent)
      class My_Class
      ^^^^^ Missing top-level class documentation comment.
        def method
        end
      end
    RUBY
  end

  it 'does not consider comment followed by empty line to be class ' \
     'documentation' do
    inspect_source(<<-RUBY.strip_indent)
      # Copyright 2014
      # Some company

      class My_Class
        def method
        end
      end
    RUBY
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for non-namespace' do
    expect_offense(<<-RUBY.strip_indent)
      module My_Class
      ^^^^^^ Missing top-level module documentation comment.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for empty module without documentation' do
    # Because why would you have an empty module? It requires some
    # explanation.
    expect_offense(<<-RUBY.strip_indent)
      module Test
      ^^^^^^ Missing top-level module documentation comment.
      end
    RUBY
  end

  it 'accepts non-empty class with documentation' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # class comment
      class My_Class
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty class with annotation comment' do
    expect_offense(<<-RUBY.strip_indent)
      # OPTIMIZE: Make this faster.
      class My_Class
      ^^^^^ Missing top-level class documentation comment.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty class with directive comment' do
    expect_offense(<<-RUBY.strip_indent)
      # rubocop:disable Style/For
      class My_Class
      ^^^^^ Missing top-level class documentation comment.
        def method
        end
      end
    RUBY
  end

  it 'registers offense for non-empty class with frozen string comment' do
    expect_offense(<<-RUBY.strip_indent)
      # frozen_string_literal: true
      class My_Class
      ^^^^^ Missing top-level class documentation comment.
        def method
        end
      end
    RUBY
  end

  it 'registers an offense for non-empty class with encoding comment' do
    expect_offense(<<-RUBY.strip_indent)
      # encoding: ascii-8bit
      class My_Class
      ^^^^^ Missing top-level class documentation comment.
        def method
        end
      end
    RUBY
  end

  it 'accepts non-empty class with annotation comment followed by other ' \
     'comment' do
    inspect_source(<<-RUBY.strip_indent)
      # OPTIMIZE: Make this faster.
      # Class comment.
      class My_Class
        def method
        end
      end
    RUBY
    expect(cop.offenses.empty?).to be(true)
  end

  it 'accepts non-empty class with comment that ends with an annotation' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # Does fooing.
      # FIXME: Not yet implemented.
      class Foo
        def initialize
        end
      end
    RUBY
  end

  it 'accepts non-empty module with documentation' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # class comment
      module My_Class
        def method
        end
      end
    RUBY
  end

  it 'accepts empty class without documentation' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class My_Class
      end
    RUBY
  end

  it 'accepts namespace module without documentation' do
    expect_no_offenses(<<-RUBY.strip_indent)
      module Test
        class A; end
        class B; end
      end
    RUBY
  end

  it 'accepts namespace class without documentation' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Test
        class A; end
        class B; end
      end
    RUBY
  end

  it 'accepts namespace class which defines constants' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Test
        A = Class.new
        B = Class.new(A)
        C = Class.new { call_method }
        D = 1
      end
    RUBY
  end

  it 'accepts namespace module which defines constants' do
    expect_no_offenses(<<-RUBY.strip_indent)
      module Test
        A = Class.new
        B = Class.new(A)
        C = Class.new { call_method }
        D = 1
      end
    RUBY
  end

  it 'does not raise an error for an implicit match conditional' do
    expect do
      inspect_source(<<-RUBY.strip_indent)
        class Test
          if //
          end
        end
      RUBY
    end.not_to raise_error
  end

  it 'registers an offense if the comment line contains code' do
    expect_offense(<<-RUBY.strip_indent)
      module A # The A Module
        class B
        ^^^^^ Missing top-level class documentation comment.
          C = 1
          def method
          end
        end
      end
    RUBY
  end

  context 'sparse and trailing comments' do
    %w[class module].each do |keyword|
      it "ignores comments after #{keyword} node end" do
        inspect_source(<<-RUBY.strip_indent)
          module TestModule
            # documentation comment
            #{keyword} Test
              def method
              end
            end # decorating comment
          end
        RUBY
        expect(cop.offenses.empty?).to be(true)
      end

      it "ignores sparse comments inside #{keyword} node" do
        inspect_source(<<-RUBY.strip_indent)
          module TestModule
            #{keyword} Test
              def method
              end
              # sparse comment
            end
          end
        RUBY
        expect(cop.offenses.size).to eq(1)
      end
    end
  end

  context 'with # :nodoc:' do
    %w[class module].each do |keyword|
      it "accepts non-namespace #{keyword} without documentation" do
        inspect_source(<<-RUBY.strip_indent)
          #{keyword} Test #:nodoc:
            def method
            end
          end
        RUBY
        expect(cop.offenses.empty?).to be(true)
      end

      it "registers an offense for nested #{keyword} without documentation" do
        inspect_source(<<-RUBY.strip_indent)
          module TestModule #:nodoc:
            TEST = 20
            #{keyword} Test
              def method
              end
            end
          end
        RUBY
        expect(cop.offenses.size).to eq(1)
      end

      context 'with `all` modifier' do
        it "accepts nested #{keyword} without documentation" do
          inspect_source(<<-RUBY.strip_indent)
            module A #:nodoc: all
              module B
                TEST = 20
                #{keyword} Test
                  TEST = 20
                end
              end
            end
          RUBY
          expect(cop.offenses.empty?).to be(true)
        end
      end
    end

    context 'on a subclass' do
      it 'accepts non-namespace subclass without documentation' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Test < Parent #:nodoc:
            def method
            end
          end
        RUBY
      end

      it 'registers an offense for nested subclass without documentation' do
        expect_offense(<<-RUBY.strip_indent)
          module TestModule #:nodoc:
            TEST = 20
            class Test < Parent
            ^^^^^ Missing top-level class documentation comment.
              def method
              end
            end
          end
        RUBY
      end

      context 'with `all` modifier' do
        it 'accepts nested subclass without documentation' do
          expect_no_offenses(<<-RUBY.strip_indent)
            module A #:nodoc: all
              module B
                TEST = 20
                class Test < Parent
                  TEST = 20
                end
              end
            end
          RUBY
        end
      end
    end
  end
end
