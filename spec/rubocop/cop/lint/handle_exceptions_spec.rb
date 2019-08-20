# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::HandleExceptions, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers an offense for empty rescue block' do
    expect_offense(<<~RUBY)
      begin
        something
      rescue
      ^^^^^^ Do not suppress exceptions.
        #do nothing
      end
    RUBY
  end

  it 'registers an offense for rescue nil' do
    expect_offense(<<~RUBY)
      begin
        something
      rescue
      ^^^^^^ Do not suppress exceptions.
        nil
      end
    RUBY
  end

  it 'registers an offense for inline nil rescue' do
    expect_offense(<<~RUBY)
      something rescue nil
                ^^^^^^^^^^ Do not suppress exceptions.
    RUBY
  end

  it 'does not register an offense for rescue with body' do
    expect_no_offenses(<<~RUBY)
      begin
        something
        return
      rescue
        file.close
      end
    RUBY
  end

  context 'AllowComments' do
    let(:cop_config) { { 'AllowComments' => true } }

    it 'does not register an offense for empty rescue with comment' do
      expect_no_offenses(<<~RUBY)
        begin
          something
          return
        rescue
          # do nothing
        end
      RUBY
    end
  end
end
