# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ArgumentMismatch, :config do
  it 'does not register an offense without a project index' do
    expect_no_offenses(<<~RUBY)
      Report.generate(source)
    RUBY
  end

  context 'with a project index', :project_index do
    # Index the callee definitions together with the inspected call site, which
    # is inspected as `/call.rb`. This mirrors production, where the file being
    # linted is part of the whole-project index.
    def index_with_call(call, callees)
      cop.project_index = build_index(callees.merge('file:///call.rb' => call))
    end

    context 'for a fixed-arity singleton method' do
      let(:callee) do
        { 'file:///report.rb' => <<~RUBY }
          class Report
            def self.generate(source, format); end
          end
        RUBY
      end

      it 'registers an offense when too few arguments are given' do
        index_with_call('Report.generate(source)', callee)

        expect_offense(<<~RUBY, '/call.rb')
          Report.generate(source)
                 ^^^^^^^^ Wrong number of arguments to `generate` (given 1, expected 2).
        RUBY
      end

      it 'registers an offense when too many arguments are given' do
        index_with_call('Report.generate(source, :pdf, :extra)', callee)

        expect_offense(<<~RUBY, '/call.rb')
          Report.generate(source, :pdf, :extra)
                 ^^^^^^^^ Wrong number of arguments to `generate` (given 3, expected 2).
        RUBY
      end

      it 'does not register an offense when the arity matches' do
        index_with_call('Report.generate(source, :pdf)', callee)

        expect_no_offenses('Report.generate(source, :pdf)', '/call.rb')
      end

      it 'does not register an offense for a call that forwards a splat' do
        index_with_call('Report.generate(*args)', callee)

        expect_no_offenses('Report.generate(*args)', '/call.rb')
      end

      it 'does not register an offense on a different receiver' do
        index_with_call('Other.generate(source)', callee)

        expect_no_offenses('Other.generate(source)', '/call.rb')
      end
    end

    context 'for optional and rest parameters' do
      let(:callee) do
        { 'file:///calc.rb' => <<~RUBY }
          class Calc
            def self.add(a, b = 0); end
            def self.sum(*nums); end
          end
        RUBY
      end

      it 'accepts a call within the optional range' do
        index_with_call("Calc.add(1)\nCalc.add(1, 2)\n", callee)

        expect_no_offenses(<<~RUBY, '/call.rb')
          Calc.add(1)
          Calc.add(1, 2)
        RUBY
      end

      it 'registers an offense past the optional maximum' do
        index_with_call('Calc.add(1, 2, 3)', callee)

        expect_offense(<<~RUBY, '/call.rb')
          Calc.add(1, 2, 3)
               ^^^ Wrong number of arguments to `add` (given 3, expected 1..2).
        RUBY
      end

      it 'accepts any number of arguments for a rest parameter' do
        index_with_call("Calc.sum\nCalc.sum(1, 2, 3, 4)\n", callee)

        expect_no_offenses(<<~RUBY, '/call.rb')
          Calc.sum
          Calc.sum(1, 2, 3, 4)
        RUBY
      end
    end

    context 'for required plus rest parameters' do
      let(:callee) do
        { 'file:///calc.rb' => <<~RUBY }
          class Calc
            def self.join(sep, *parts); end
          end
        RUBY
      end

      it 'reports the minimum with a trailing plus' do
        index_with_call('Calc.join', callee)

        expect_offense(<<~RUBY, '/call.rb')
          Calc.join
               ^^^^ Wrong number of arguments to `join` (given 0, expected 1+).
        RUBY
      end
    end

    context 'with keyword arguments' do
      it 'folds keywords into a positional hash when the method has none' do
        index_with_call('M.opts(a: 1, b: 2)', 'file:///m.rb' => <<~RUBY)
          class M
            def self.opts(hash); end
          end
        RUBY

        expect_no_offenses('M.opts(a: 1, b: 2)', '/call.rb')
      end

      it 'registers an offense when the folded hash overflows the arity' do
        index_with_call('M.opts(a: 1)', 'file:///m.rb' => <<~RUBY)
          class M
            def self.opts; end
          end
        RUBY

        expect_offense(<<~RUBY, '/call.rb')
          M.opts(a: 1)
            ^^^^ Wrong number of arguments to `opts` (given 1, expected 0).
        RUBY
      end

      it 'does not count keywords as positional when the method declares them' do
        index_with_call('M.build(name, size: 1)', 'file:///m.rb' => <<~RUBY)
          class M
            def self.build(name, size:); end
          end
        RUBY

        expect_no_offenses('M.build(name, size: 1)', '/call.rb')
      end

      it 'skips a call that forwards a double splat' do
        index_with_call('M.build(name, **opts)', 'file:///m.rb' => <<~RUBY)
          class M
            def self.build(name); end
          end
        RUBY

        expect_no_offenses('M.build(name, **opts)', '/call.rb')
      end
    end

    context 'when the method is defined on the instance side' do
      it 'does not register an offense for an instance method called on the module' do
        index_with_call('Helper.call(1, 2)', 'file:///helper.rb' => <<~RUBY)
          module Helper
            def call(a); end
          end
        RUBY

        expect_no_offenses('Helper.call(1, 2)', '/call.rb')
      end
    end

    context 'when the ancestry is not fully resolved' do
      it 'does not register an offense' do
        index_with_call('Widget.render(1, 2)', 'file:///widget.rb' => <<~RUBY)
          class Widget < Unknown
            def self.render(a); end
          end
        RUBY

        expect_no_offenses('Widget.render(1, 2)', '/call.rb')
      end
    end

    context 'when the method is reopened with a different arity' do
      it 'does not register an offense when definitions disagree on arity' do
        index_with_call(
          'Thing.run(1)',
          'file:///thing.rb' => "class Thing\n  def self.run(a); end\nend\n",
          'file:///thing_ext.rb' => "class Thing\n  def self.run(a, b); end\nend\n"
        )

        expect_no_offenses('Thing.run(1)', '/call.rb')
      end
    end

    context 'for inherited singleton methods' do
      it 'registers an offense against the inherited signature' do
        index_with_call(
          'Child.build(1)',
          'file:///base.rb' => "class Base\n  def self.build(a, b); end\nend\n",
          'file:///child.rb' => "class Child < Base\nend\n"
        )

        expect_offense(<<~RUBY, '/call.rb')
          Child.build(1)
                ^^^^^ Wrong number of arguments to `build` (given 1, expected 2).
        RUBY
      end
    end

    context 'with safe navigation' do
      it 'registers an offense on a safe-navigation call' do
        index_with_call('Report&.generate(source)', 'file:///report.rb' => <<~RUBY)
          class Report
            def self.generate(source, format); end
          end
        RUBY

        expect_offense(<<~RUBY, '/call.rb')
          Report&.generate(source)
                  ^^^^^^^^ Wrong number of arguments to `generate` (given 1, expected 2).
        RUBY
      end
    end
  end
end
