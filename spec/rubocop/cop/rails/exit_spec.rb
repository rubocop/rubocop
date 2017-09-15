# frozen_string_literal: true

describe RuboCop::Cop::Rails::Exit, :config do
  subject(:cop) { described_class.new }

  it 'registers an offense for an exit call with no receiver' do
    expect_offense(<<-RUBY.strip_indent)
      exit
      ^^^^ Do not use `exit` in Rails applications.
    RUBY
  end

  it 'registers an offense for an exit! call with no receiver' do
    expect_offense(<<-RUBY.strip_indent)
      exit!
      ^^^^^ Do not use `exit` in Rails applications.
    RUBY
  end

  context 'exit calls on objects' do
    it 'does not register an offense for an explicit exit call on an object' do
      expect_no_offenses('Object.new.exit')
    end

    it 'does not register an offense for an explicit exit call '\
      'with an argument on an object' do
      inspect_source('Object.new.exit(0)')
      expect(cop.offenses.empty?).to be(true)
    end

    it 'does not register an offense for an explicit exit! call on an object' do
      expect_no_offenses('Object.new.exit!(0)')
    end
  end

  context 'with arguments' do
    it 'registers an offense for an exit(0) call with no receiver' do
      expect_offense(<<-RUBY.strip_indent)
        exit(0)
        ^^^^ Do not use `exit` in Rails applications.
      RUBY
    end

    it 'ignores exit calls with unexpected number of parameters' do
      expect_no_offenses('exit(1, 2)')
    end
  end

  context 'explicit calls' do
    it 'does register an offense for explicit Kernel.exit calls' do
      expect_offense(<<-RUBY.strip_indent)
        Kernel.exit
               ^^^^ Do not use `exit` in Rails applications.
      RUBY
    end

    it 'does register an offense for explicit Process.exit calls' do
      expect_offense(<<-RUBY.strip_indent)
        Process.exit
                ^^^^ Do not use `exit` in Rails applications.
      RUBY
    end
  end
end
