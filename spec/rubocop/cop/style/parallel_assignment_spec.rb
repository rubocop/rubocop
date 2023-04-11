# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ParallelAssignment, :config do
  let(:config) { RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 2 }) }

  it 'registers an offense when the right side has multiple arrays' do
    expect_offense(<<~RUBY)
      a, b, c = [1, 2], [3, 4], [5, 6]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = [1, 2]
      b = [3, 4]
      c = [5, 6]
    RUBY
  end

  it 'registers an offense when the right side has multiple hashes' do
    expect_offense(<<~RUBY)
      a, b, c = {a: 1}, {b: 2}, {c: 3}
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = {a: 1}
      b = {b: 2}
      c = {c: 3}
    RUBY
  end

  it 'registers an offense when the right side has constants' do
    expect_offense(<<~RUBY)
      a, b, c = CONSTANT1, CONSTANT2, CONSTANT3
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = CONSTANT1
      b = CONSTANT2
      c = CONSTANT3
    RUBY
  end

  it 'registers an offense when the right side has mixed expressions' do
    expect_offense(<<~RUBY)
      a, b, c = [1, 2], {a: 1}, CONSTANT3
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = [1, 2]
      b = {a: 1}
      c = CONSTANT3
    RUBY
  end

  it 'registers an offense when the right side has methods with/without blocks' do
    expect_offense(<<~RUBY)
      a, b = foo { |a| puts a }, bar()
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = foo { |a| puts a }
      b = bar()
    RUBY
  end

  it 'registers an offense when assignments must be reordered to preserve meaning' do
    expect_offense(<<~RUBY)
      a, b = 1, a
      ^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      b = a
      a = 1
    RUBY
  end

  it 'registers an offense when assigning to same variables in same order' do
    expect_offense(<<~RUBY)
      a, b = a, b
      ^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = a
      b = b
    RUBY
  end

  it 'registers an offense when right hand side has maps with blocks' do
    expect_offense(<<~RUBY)
      a, b = foo.map { |e| e.id }, bar.map { |e| e.id }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = foo.map { |e| e.id }
      b = bar.map { |e| e.id }
    RUBY
  end

  it 'registers an offense when left hand side ends with an implicit variable' do
    expect_offense(<<~RUBY)
      array = [1, 2, 3]
      a, b, c, = 8, 9, array
      ^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      array = [1, 2, 3]
      a = 8
      b = 9
      c = array
    RUBY
  end

  it 'registers an offense when right hand side has namespaced constants' do
    expect_offense(<<~RUBY)
      a, b = Float::INFINITY, Float::INFINITY
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = Float::INFINITY
      b = Float::INFINITY
    RUBY
  end

  it 'registers an offense when assigning to namespaced constants' do
    expect_offense(<<~RUBY)
      Float::INFINITY, Float::INFINITY = 1, 2
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      Float::INFINITY = 1
      Float::INFINITY = 2
    RUBY
  end

  it 'registers an offense with indices' do
    expect_offense(<<~RUBY)
      a[0], a[1] = a[1], a[2]
      ^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a[0] = a[1]
      a[1] = a[2]
    RUBY
  end

  it 'registers an offense with attributes when assignments must be ' \
     'reordered to preserve meaning' do
    expect_offense(<<~RUBY)
      obj.attr1, obj.attr2 = obj.attr3, obj.attr1
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      obj.attr2 = obj.attr1
      obj.attr1 = obj.attr3
    RUBY
  end

  it 'registers an offense with indices and attributes when assignments ' \
     'must be reordered to preserve meaning' do
    expect_offense(<<~RUBY)
      obj.attr1, ary[0] = ary[1], obj.attr1
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      ary[0] = obj.attr1
      obj.attr1 = ary[1]
    RUBY
  end

  it 'registers an offense with indices of different variables' do
    expect_offense(<<~RUBY)
      a[0], a[1] = a[1], b[0]
      ^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a[0] = a[1]
      a[1] = b[0]
    RUBY
  end

  shared_examples('allowed') do |source|
    it "allows assignment of: #{source.gsub(/\s*\n\s*/, '; ')}" do
      expect_no_offenses(source)
    end
  end

  it_behaves_like('allowed', 'a = 1')
  it_behaves_like('allowed', 'a = a')
  it_behaves_like('allowed', 'a, = a')
  it_behaves_like('allowed', 'a, = 1')
  it_behaves_like('allowed', "a = *'foo'")
  it_behaves_like('allowed', "a, = *'foo'")
  it_behaves_like('allowed', 'a, = 1, 2, 3')
  it_behaves_like('allowed', 'a, = *foo')
  it_behaves_like('allowed', 'a, *b = [1, 2, 3]')
  it_behaves_like('allowed', '*a, b = [1, 2, 3]')
  it_behaves_like('allowed', 'a, b = b, a')
  it_behaves_like('allowed', 'a, b, c = b, c, a')
  it_behaves_like('allowed', 'a, b = (a + b), (a - b)')
  it_behaves_like('allowed', 'a, b = foo.map { |e| e.id }')
  it_behaves_like('allowed', 'a, b = foo()')
  it_behaves_like('allowed', 'a, b = *foo')
  it_behaves_like('allowed', 'a, b, c = 1, 2, *node')
  it_behaves_like('allowed', 'a, b, c = *node, 1, 2')
  it_behaves_like('allowed', 'begin_token, end_token = CONSTANT')
  it_behaves_like('allowed', 'CONSTANT, = 1, 2')
  it_behaves_like('allowed', <<~RUBY)
    a = 1
    b = 2
  RUBY
  it_behaves_like('allowed', <<~RUBY)
    foo = [1, 2, 3]
    a, b, c = foo
  RUBY
  it_behaves_like('allowed', <<~RUBY)
    array = [1, 2, 3]
    a, = array
  RUBY
  it_behaves_like('allowed', 'a, b = Float::INFINITY')
  it_behaves_like('allowed', 'a[0], a[1] = a[1], a[0]')
  it_behaves_like('allowed', 'obj.attr1, obj.attr2 = obj.attr2, obj.attr1')
  it_behaves_like('allowed', 'obj.attr1, ary[0] = ary[0], obj.attr1')
  it_behaves_like('allowed', 'ary[0], ary[1], ary[2] = ary[1], ary[2], ary[0]')
  it_behaves_like('allowed', 'self.a, self.b = self.b, self.a')
  it_behaves_like('allowed', 'self.a, self.b = b, a')

  it 'corrects when the number of left hand variables matches the number of right hand variables' do
    expect_offense(<<~RUBY)
      a, b, c = 1, 2, 3
      ^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = 1
      b = 2
      c = 3
    RUBY
  end

  it 'corrects when the right variable is an array' do
    expect_offense(<<~RUBY)
      a, b, c = ["1", "2", :c]
      ^^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = "1"
      b = "2"
      c = :c
    RUBY
  end

  it 'corrects when the right variable is a word array' do
    expect_offense(<<~RUBY)
      a, b, c = %w(1 2 3)
      ^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = '1'
      b = '2'
      c = '3'
    RUBY
  end

  it 'corrects when the right variable is a symbol array' do
    expect_offense(<<~RUBY)
      a, b, c = %i(a b c)
      ^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = :a
      b = :b
      c = :c
    RUBY
  end

  it 'corrects when assigning to method returns' do
    expect_offense(<<~RUBY)
      a, b = foo(), bar()
      ^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = foo()
      b = bar()
    RUBY
  end

  it 'corrects when assigning from multiple methods with blocks' do
    expect_offense(<<~RUBY)
      a, b = foo() { |c| puts c }, bar() { |d| puts d }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = foo() { |c| puts c }
      b = bar() { |d| puts d }
    RUBY
  end

  it 'corrects when using constants' do
    expect_offense(<<~RUBY)
      CONSTANT1, CONSTANT2 = CONSTANT3, CONSTANT4
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      CONSTANT1 = CONSTANT3
      CONSTANT2 = CONSTANT4
    RUBY
  end

  it 'corrects when using parallel assignment in singleton method' do
    expect_offense(<<~RUBY)
      def self.foo
        foo, bar = 1, 2
        ^^^^^^^^^^^^^^^ Do not use parallel assignment.
      end
    RUBY

    expect_correction(<<~RUBY)
      def self.foo
        foo = 1
        bar = 2
      end
    RUBY
  end

  it 'corrects when the expression is missing spaces' do
    expect_offense(<<~RUBY)
      a,b,c=1,2,3
      ^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      a = 1
      b = 2
      c = 3
    RUBY
  end

  it 'corrects when using single indentation' do
    expect_offense(<<~RUBY)
      def foo
        a, b, c = 1, 2, 3
        ^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        a = 1
        b = 2
        c = 3
      end
    RUBY
  end

  it 'corrects when using nested indentation' do
    expect_offense(<<~RUBY)
      def foo
        if true
          a, b, c = 1, 2, 3
          ^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        if true
          a = 1
          b = 2
          c = 3
        end
      end
    RUBY
  end

  it 'corrects when the expression uses a modifier if statement' do
    expect_offense(<<~RUBY)
      a, b = 1, 2 if foo
      ^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      if foo
        a = 1
        b = 2
      end
    RUBY
  end

  it 'corrects when the expression uses a modifier if statement inside a method' do
    expect_offense(<<~RUBY)
      def foo
        a, b = 1, 2 if foo
        ^^^^^^^^^^^ Do not use parallel assignment.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        if foo
          a = 1
          b = 2
        end
      end
    RUBY
  end

  it 'corrects parallel assignment in if statements' do
    expect_offense(<<~RUBY)
      if foo
        a, b = 1, 2
        ^^^^^^^^^^^ Do not use parallel assignment.
      end
    RUBY

    expect_correction(<<~RUBY)
      if foo
        a = 1
        b = 2
      end
    RUBY
  end

  it 'corrects when the expression uses a modifier unless statement' do
    expect_offense(<<~RUBY)
      a, b = 1, 2 unless foo
      ^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      unless foo
        a = 1
        b = 2
      end
    RUBY
  end

  it 'corrects parallel assignment in unless statements' do
    expect_offense(<<~RUBY)
      unless foo
        a, b = 1, 2
        ^^^^^^^^^^^ Do not use parallel assignment.
      end
    RUBY

    expect_correction(<<~RUBY)
      unless foo
        a = 1
        b = 2
      end
    RUBY
  end

  it 'corrects when the expression uses a modifier while statement' do
    expect_offense(<<~RUBY)
      a, b = 1, 2 while foo
      ^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      while foo
        a = 1
        b = 2
      end
    RUBY
  end

  it 'corrects parallel assignment in while statements' do
    expect_offense(<<~RUBY)
      while foo
        a, b = 1, 2
        ^^^^^^^^^^^ Do not use parallel assignment.
      end
    RUBY

    expect_correction(<<~RUBY)
      while foo
        a = 1
        b = 2
      end
    RUBY
  end

  it 'corrects when the expression uses a modifier until statement' do
    expect_offense(<<~RUBY)
      a, b = 1, 2 until foo
      ^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      until foo
        a = 1
        b = 2
      end
    RUBY
  end

  it 'corrects parallel assignment in until statements' do
    expect_offense(<<~RUBY)
      until foo
        a, b = 1, 2
        ^^^^^^^^^^^ Do not use parallel assignment.
      end
    RUBY

    expect_correction(<<~RUBY)
      until foo
        a = 1
        b = 2
      end
    RUBY
  end

  it 'corrects when the expression uses a modifier rescue statement', :ruby26 do
    expect_offense(<<~RUBY)
      a, b = 1, 2 rescue foo
      ^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      begin
        a = 1
        b = 2
      rescue
        foo
      end
    RUBY
  end

  it 'corrects when the expression uses a modifier rescue statement', :ruby27 do
    expect_offense(<<~RUBY)
      a, b = 1, 2 rescue foo
      ^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      begin
        a = 1
        b = 2
      rescue
        foo
      end
    RUBY
  end

  it 'corrects parallel assignment inside rescue statements within method definitions' do
    expect_offense(<<~RUBY)
      def bar
        a, b = 1, 2
        ^^^^^^^^^^^ Do not use parallel assignment.
      rescue
        'foo'
      end
    RUBY

    expect_correction(<<~RUBY)
      def bar
        a = 1
        b = 2
      rescue
        'foo'
      end
    RUBY
  end

  it 'corrects parallel assignment in rescue statements within begin ... rescue' do
    expect_offense(<<~RUBY)
      begin
        a, b = 1, 2
        ^^^^^^^^^^^ Do not use parallel assignment.
      rescue
        'foo'
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        a = 1
        b = 2
      rescue
        'foo'
      end
    RUBY
  end

  it 'corrects when the expression uses a modifier rescue statement as the only thing inside of a method', :ruby26 do
    expect_offense(<<~RUBY)
      def foo
        a, b = 1, 2 rescue foo
        ^^^^^^^^^^^ Do not use parallel assignment.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        a = 1
        b = 2
      rescue
        foo
      end
    RUBY
  end

  it 'corrects when the expression uses a modifier rescue statement as the only thing inside of a method', :ruby27 do
    expect_offense(<<~RUBY)
      def foo
        a, b = 1, 2 rescue foo
        ^^^^^^^^^^^ Do not use parallel assignment.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        a = 1
        b = 2
      rescue
        foo
      end
    RUBY
  end

  it 'corrects when the expression uses a modifier rescue statement inside of a method', :ruby26 do
    expect_offense(<<~RUBY)
      def foo
        a, b = %w(1 2) rescue foo
        ^^^^^^^^^^^^^^ Do not use parallel assignment.
        something_else
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        begin
          a = '1'
          b = '2'
        rescue
          foo
        end
        something_else
      end
    RUBY
  end

  it 'corrects when the expression uses a modifier rescue statement inside of a method', :ruby27 do
    expect_offense(<<~RUBY)
      def foo
        a, b = %w(1 2) rescue foo
        ^^^^^^^^^^^^^^ Do not use parallel assignment.
        something_else
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        begin
          a = '1'
          b = '2'
        rescue
          foo
        end
        something_else
      end
    RUBY
  end

  it 'corrects when assignments must be reordered to avoid changing meaning' do
    expect_offense(<<~RUBY)
      a, b, c, d = 1, a + 1, b + 1, a + b + c
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
    RUBY

    expect_correction(<<~RUBY)
      d = a + b + c
      c = b + 1
      b = a + 1
      a = 1
    RUBY
  end

  it 'allows more left variables than right variables' do
    expect_no_offenses(<<~RUBY)
      a, b, c, d = 1, 2
    RUBY
  end

  it 'allows more right variables than left variables' do
    expect_no_offenses(<<~RUBY)
      a, b = 1, 2, 3
    RUBY
  end

  it 'allows expanding an assigned var' do
    expect_no_offenses(<<~RUBY)
      foo = [1, 2, 3]
      a, b, c = foo
    RUBY
  end

  describe 'using custom indentation width' do
    let(:config) do
      RuboCop::Config.new('Style/ParallelAssignment' => {
                            'Enabled' => true
                          },
                          'Layout/IndentationWidth' => {
                            'Enabled' => true,
                            'Width' => 3
                          })
    end

    it 'works with standard correction' do
      expect_offense(<<~RUBY)
        a, b, c = 1, 2, 3
        ^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
      RUBY

      expect_correction(<<~RUBY)
        a = 1
        b = 2
        c = 3
      RUBY
    end

    it 'works with guard clauses' do
      expect_offense(<<~RUBY)
        a, b = 1, 2 if foo
        ^^^^^^^^^^^ Do not use parallel assignment.
      RUBY

      expect_correction(<<~RUBY)
        if foo
           a = 1
           b = 2
        end
      RUBY
    end

    it 'works with rescue', :ruby26 do
      expect_offense(<<~RUBY)
        a, b = 1, 2 rescue foo
        ^^^^^^^^^^^ Do not use parallel assignment.
      RUBY

      expect_correction(<<~RUBY)
        begin
           a = 1
           b = 2
        rescue
           foo
        end
      RUBY
    end

    it 'works with rescue', :ruby27 do
      expect_offense(<<~RUBY)
        a, b = 1, 2 rescue foo
        ^^^^^^^^^^^ Do not use parallel assignment.
      RUBY

      expect_correction(<<~RUBY)
        begin
           a = 1
           b = 2
        rescue
           foo
        end
      RUBY
    end

    it 'works with nesting' do
      expect_offense(<<~RUBY)
        def foo
           if true
              a, b, c = 1, 2, 3
              ^^^^^^^^^^^^^^^^^ Do not use parallel assignment.
           end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
           if true
              a = 1
              b = 2
              c = 3
           end
        end
      RUBY
    end
  end
end
