# frozen_string_literal: true

describe RuboCop::Cop::Style::RedundantSelf do
  subject(:cop) { described_class.new }

  it 'reports an offense a self receiver on an rvalue' do
    src = 'a = self.b'
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not report an offense when receiver and lvalue have the same name' do
    src = 'a = self.a'
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'accepts a self receiver on an lvalue of an assignment' do
    src = 'self.a = b'
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'accepts a self receiver on an lvalue of a parallel assignment' do
    src = 'a, self.b = c, d'
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'accepts a self receiver on an lvalue of an or-assignment' do
    src = 'self.logger ||= Rails.logger'
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'accepts a self receiver on an lvalue of an and-assignment' do
    src = 'self.flag &&= value'
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'accepts a self receiver on an lvalue of a plus-assignment' do
    src = 'self.sum += 10'
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'accepts a self receiver with the square bracket operator' do
    src = 'self[a]'
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'accepts a self receiver with the double less-than operator' do
    src = 'self << a'
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'accepts a self receiver for methods named like ruby keywords' do
    src = <<-END.strip_indent
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
    END
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  describe 'instance methods' do
    it 'accepts a self receiver used to distinguish from blockarg' do
      src = <<-END.strip_indent
        def requested_specs(&groups)
          some_method(self.groups)
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts a self receiver used to distinguish from argument' do
      src = <<-END.strip_indent
        def requested_specs(groups)
          some_method(self.groups)
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts a self receiver used to distinguish from optional argument' do
      src = <<-END.strip_indent
        def requested_specs(final = true)
          something if self.final != final
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts a self receiver used to distinguish from local variable' do
      src = <<-END.strip_indent
        def requested_specs
          @requested_specs ||= begin
            groups = self.groups - Bundler.settings.without
            groups.map! { |g| g.to_sym }
            specs_for(groups)
          end
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts a self receiver used to distinguish from an argument' do
      src = <<-END.strip_indent
        def foo(bar)
          puts bar, self.bar
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts a self receiver used to distinguish from an argument' \
      ' when an inner method is defined' do
      src = <<-END.strip_indent
        def foo(bar)
          def inner_method(); end
          puts bar, self.bar
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end
  end

  describe 'class methods' do
    it 'accepts a self receiver used to distinguish from blockarg' do
      src = <<-END.strip_indent
        def self.requested_specs(&groups)
          some_method(self.groups)
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts a self receiver used to distinguish from argument' do
      src = <<-END.strip_indent
        def self.requested_specs(groups)
          some_method(self.groups)
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts a self receiver used to distinguish from optional argument' do
      src = <<-END.strip_indent
        def self.requested_specs(final = true)
          something if self.final != final
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts a self receiver used to distinguish from local variable' do
      src = <<-END.strip_indent
        def self.requested_specs
          @requested_specs ||= begin
            groups = self.groups - Bundler.settings.without
            groups.map! { |g| g.to_sym }
            specs_for(groups)
          end
        end
      END
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end
  end

  it 'accepts a self receiver used to distinguish from constant' do
    src = 'self.Foo'
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'accepts a self receiver of .()' do
    src = 'self.()'
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'reports an offence a self receiver of .call' do
    src = 'self.call'
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'auto-corrects by removing redundant self' do
    new_source = autocorrect_source(cop, 'self.x')
    expect(new_source).to eq('x')
  end
end
