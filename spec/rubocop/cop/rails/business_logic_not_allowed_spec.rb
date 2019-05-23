# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::BusinessLogicNotAllowed, :config do
  subject(:cop) { described_class.new(config) }

  let(:standard_actions) { %i[index show new edit create update destroy] }

  let(:source) { code.to_s }

  shared_examples 'accepts' do |name, code|
    let(:code) { code }

    it "accepts usages of #{name}" do
      inspect_source(source)
      expect(cop.offenses.empty?).to be(true)
    end
  end

  shared_examples 'offense' do |name, code|
    let(:code) { code }

    it "registers an offense for #{name}" do
      inspect_source(source)
      error = ['Business logic is not allowed in this part of the application.']
      expect(cop.messages).to eq(error)
    end
  end

  it_behaves_like 'offense', 'if/else', <<-RUBY
    if true
      my_var = 1
    else
      my_var = 2
    end
  RUBY

  it_behaves_like 'offense', 'unless', <<-RUBY
    unless true
      my_var = 1
    else
      my_var = 2
    end
  RUBY

  it_behaves_like 'offense', 'until', <<-RUBY
    a = 0
    until a > 10 do
      p a
      a += 1
    end
    p a
  RUBY

  it_behaves_like 'offense', 'while', <<-RUBY
    while total < 100
      total += foo
      foo += 1
    end
  RUBY

  it_behaves_like 'offense', 'ternary', <<-RUBY
    my_var = true ? 1 : 2
  RUBY

  it_behaves_like 'offense', 'unless', <<-RUBY
    case expr0
    when expr1, expr2
       stmt1
    when expr3, expr4
       stmt2
    else
       stmt3
    end
  RUBY

  it_behaves_like 'offense', 'rescue block', <<-RUBY
    begin
      my_method
    rescue
      raise
    end
  RUBY

  it_behaves_like 'offense', 'rescue one line', <<-RUBY
    user.destroy! rescue nil
  RUBY

  it_behaves_like 'offense', '&&', <<-RUBY
    false && true
  RUBY

  it_behaves_like 'offense', 'and', <<-RUBY
    false and true
  RUBY
end
