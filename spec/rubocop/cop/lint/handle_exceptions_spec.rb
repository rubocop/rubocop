# frozen_string_literal: true

describe RuboCop::Cop::Lint::HandleExceptions do
  subject(:cop) { described_class.new }

  it 'registers an offense for empty rescue block' do
    expect_offense(<<-RUBY.strip_indent)
      begin
        something
      rescue
      ^^^^^^ Do not suppress exceptions.
        #do nothing
      end
    RUBY
  end

  it 'does not register an offense for rescue with body' do
    expect_no_offenses(<<-END.strip_indent)
      begin
        something
        return
      rescue
        file.close
      end
    END
  end
end
