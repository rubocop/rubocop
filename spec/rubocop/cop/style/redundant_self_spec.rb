# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantSelf do
  subject(:cop) { described_class.new }

  it 'reports an offense a self receiver on an rvalue' do
    src = 'a = self.b'
    inspect_source(src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not report an offense when receiver and lvalue have the same name' do
    expect_no_offenses('a = self.a')
  end

  it 'accepts a self receiver on an lvalue of an assignment' do
    expect_no_offenses('self.a = b')
  end

  it 'accepts a self receiver on an lvalue of a parallel assignment' do
    expect_no_offenses('a, self.b = c, d')
  end

  it 'accepts a self receiver on an lvalue of an or-assignment' do
    expect_no_offenses('self.logger ||= Rails.logger')
  end

  it 'accepts a self receiver on an lvalue of an and-assignment' do
    expect_no_offenses('self.flag &&= value')
  end

  it 'accepts a self receiver on an lvalue of a plus-assignment' do
    expect_no_offenses('self.sum += 10')
  end

  it 'accepts a self receiver with the square bracket operator' do
    expect_no_offenses('self[a]')
  end

  it 'accepts a self receiver with the double less-than operator' do
    expect_no_offenses('self << a')
  end

  it 'accepts a self receiver for methods named like ruby keywords' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a = self.class
      self.for(deps, [], true)
      self.and(other)
      self.or(other)
      self.alias
      self.begin
      self.break
      self.case
      self.def
      self.defined?
      self.do
      self.else
      self.elsif
      self.end
      self.ensure
      self.false
      self.if
      self.in
      self.module
      self.next
      self.nil
      self.not
      self.redo
      self.rescue
      self.retry
      self.return
      self.self
      self.super
      self.then
      self.true
      self.undef
      self.unless
      self.until
      self.when
      self.while
      self.yield
    RUBY
  end

  it 'accepts a self receiver used to distinguish from argument of block' do
    expect_no_offenses(<<-RUBY.strip_indent)
      %w[draft preview moderation approved rejected].each do |state|
        self.state == state
        define_method "\#{state}?" do
          self.state == state
        end
      end
    RUBY
  end

  describe 'instance methods' do
    it 'accepts a self receiver used to distinguish from blockarg' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def requested_specs(&groups)
          some_method(self.groups)
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from argument' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def requested_specs(groups)
          some_method(self.groups)
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from optional argument' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def requested_specs(final = true)
          something if self.final != final
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from local variable' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def requested_specs
          @requested_specs ||= begin
            groups = self.groups - Bundler.settings.without
            groups.map! { |g| g.to_sym }
            specs_for(groups)
          end
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from an argument' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def foo(bar)
          puts bar, self.bar
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from an argument' \
      ' when an inner method is defined' do
      src = <<-RUBY.strip_indent
        def foo(bar)
          def inner_method(); end
          puts bar, self.bar
        end
      RUBY
      inspect_source(src)
      expect(cop.offenses.empty?).to be(true)
    end
  end

  describe 'class methods' do
    it 'accepts a self receiver used to distinguish from blockarg' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def self.requested_specs(&groups)
          some_method(self.groups)
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from argument' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def self.requested_specs(groups)
          some_method(self.groups)
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from optional argument' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def self.requested_specs(final = true)
          something if self.final != final
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from local variable' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def self.requested_specs
          @requested_specs ||= begin
            groups = self.groups - Bundler.settings.without
            groups.map! { |g| g.to_sym }
            specs_for(groups)
          end
        end
      RUBY
    end
  end

  it 'accepts a self receiver used to distinguish from constant' do
    expect_no_offenses('self.Foo')
  end

  it 'accepts a self receiver of .()' do
    expect_no_offenses('self.()')
  end

  it 'reports an offence a self receiver of .call' do
    src = 'self.call'
    inspect_source(src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'auto-corrects by removing redundant self' do
    new_source = autocorrect_source('self.x')
    expect(new_source).to eq('x')
  end
end
