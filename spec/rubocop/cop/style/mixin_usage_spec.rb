# frozen_string_literal: true

describe RuboCop::Cop::Style::MixinUsage do
  subject(:cop) { described_class.new }

  context 'include' do
    it 'registers an offense when using outside class (used above)' do
      expect_offense(<<-RUBY.strip_indent)
        include M
        ^^^^^^^^^ `include` is used at the top level. Use inside `class` or `module`.
        class C
        end
      RUBY
    end

    it 'registers an offense when using outside class (used below)' do
      expect_offense(<<-RUBY.strip_indent)
        class C
        end
        include M
        ^^^^^^^^^ `include` is used at the top level. Use inside `class` or `module`.
      RUBY
    end

    it 'registers an offense when using only `include` statement' do
      expect_offense(<<-RUBY.strip_indent)
        include M
        ^^^^^^^^^ `include` is used at the top level. Use inside `class` or `module`.
      RUBY
    end

    it 'registers an offense when using `include` in method definition ' \
       'outside class or module' do
      expect_offense(<<-RUBY.strip_indent)
        def foo
          include M
          ^^^^^^^^^ `include` is used at the top level. Use inside `class` or `module`.
        end
      RUBY
    end

    it 'does not register an offense when using outside class' do
      expect_no_offenses(<<-RUBY.strip_indent)
        Foo.include M
        class C; end
      RUBY
    end

    it 'does not register an offense when using inside class' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class C
          include M
        end
      RUBY
    end

    it 'does not register an offense when using inside block' do
      expect_no_offenses(<<-RUBY.strip_indent)
        Class.new do
          include M
        end
      RUBY
    end

    it "doesn't register an offense when `include` call is a method argument" do
      expect_no_offenses(<<-RUBY.strip_indent)
        do_something(include(M))
      RUBY
    end

    it 'does not register an offense when using `include` in method ' \
       'definition inside class' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class X
          def foo
            include M
          end
        end
      RUBY
    end

    it 'does not register an offense when using `include` in method ' \
       'definition inside module' do
      expect_no_offenses(<<-RUBY.strip_indent)
        module X
          def foo
            include M
          end
        end
      RUBY
    end

    context 'Multiple definition classes in one' do
      it 'does not register an offense when using inside class' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class C1
            include M
          end

          class C2
            include M
          end
        RUBY
      end
    end

    context 'Nested module' do
      it 'registers an offense when using outside class' do
        expect_offense(<<-RUBY.strip_indent)
          include M1::M2::M3
          ^^^^^^^^^^^^^^^^^^ `include` is used at the top level. Use inside `class` or `module`.
          class C
          end
        RUBY
      end
    end
  end

  context 'extend' do
    it 'registers an offense when using outside class' do
      expect_offense(<<-RUBY.strip_indent)
        extend M
        ^^^^^^^^ `extend` is used at the top level. Use inside `class` or `module`.
        class C
        end
      RUBY
    end

    it 'does not register an offense when using inside class' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class C
          extend M
        end
      RUBY
    end
  end

  context 'prepend' do
    it 'registers an offense when using outside class' do
      expect_offense(<<-RUBY.strip_indent)
        prepend M
        ^^^^^^^^^ `prepend` is used at the top level. Use inside `class` or `module`.
        class C
        end
      RUBY
    end

    it 'does not register an offense when using inside class' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class C
          prepend M
        end
      RUBY
    end
  end

  it 'does not register an offense when using inside nested module' do
    expect_no_offenses(<<-RUBY.strip_indent)
      module M1
        include M2

        class C
          include M3
        end
      end
    RUBY
  end
end
