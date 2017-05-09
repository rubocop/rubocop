# frozen_string_literal: true

describe RuboCop::Cop::Lint::RescueException do
  subject(:cop) { described_class.new }

  it 'registers an offense for rescue from Exception' do
    expect_offense(<<-RUBY.strip_indent)
      begin
        something
      rescue Exception
      ^^^^^^^^^^^^^^^^ Avoid rescuing the `Exception` class. Perhaps you meant to rescue `StandardError`?
        #do nothing
      end
    RUBY
  end

  it 'registers an offense for rescue with ::Exception' do
    expect_offense(<<-RUBY.strip_indent)
      begin
        something
      rescue ::Exception
      ^^^^^^^^^^^^^^^^^^ Avoid rescuing the `Exception` class. Perhaps you meant to rescue `StandardError`?
        #do nothing
      end
    RUBY
  end

  it 'registers an offense for rescue with StandardError, Exception' do
    expect_offense(<<-RUBY.strip_indent)
      begin
        something
      rescue StandardError, Exception
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid rescuing the `Exception` class. Perhaps you meant to rescue `StandardError`?
        #do nothing
      end
    RUBY
  end

  it 'registers an offense for rescue with Exception => e' do
    expect_offense(<<-RUBY.strip_indent)
      begin
        something
      rescue Exception => e
      ^^^^^^^^^^^^^^^^^^^^^ Avoid rescuing the `Exception` class. Perhaps you meant to rescue `StandardError`?
        #do nothing
      end
    RUBY
  end

  it 'does not register an offense for rescue with no class' do
    expect_no_offenses(<<-END.strip_indent)
      begin
        something
        return
      rescue
        file.close
      end
    END
  end

  it 'does not register an offense for rescue with no class and => e' do
    expect_no_offenses(<<-END.strip_indent)
      begin
        something
        return
      rescue => e
        file.close
      end
    END
  end

  it 'does not register an offense for rescue with other class' do
    expect_no_offenses(<<-END.strip_indent)
      begin
        something
        return
      rescue ArgumentError => e
        file.close
      end
    END
  end

  it 'does not register an offense for rescue with other classes' do
    expect_no_offenses(<<-END.strip_indent)
      begin
        something
        return
      rescue EOFError, ArgumentError => e
        file.close
      end
    END
  end

  it 'does not register an offense for rescue with a module prefix' do
    expect_no_offenses(<<-END.strip_indent)
      begin
        something
        return
      rescue Test::Exception => e
        file.close
      end
    END
  end

  it 'does not crash when the splat operator is used in a rescue' do
    expect_no_offenses(<<-END.strip_indent)
      ERRORS = [Exception]
      begin
        a = 3 / 0
      rescue *ERRORS
        puts e
      end
    END
  end

  it 'does not crash when the namespace of a rescued class is in a local ' \
     'variable' do
    inspect_source(cop, <<-END.strip_indent)
      adapter = current_adapter
      begin
      rescue adapter::ParseError
      end
    END
    expect(cop.offenses).to be_empty
  end
end
