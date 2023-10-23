# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::NodeFirstOrLastArgument, :config do
  shared_examples 'registers an offense' do |receiver:, position:, accessor:|
    offending_source = "#{receiver}.arguments#{accessor}"
    correction_source = "#{receiver}.#{position}_argument"

    it "registers an offense when using `#{offending_source}`" do
      expect_offense(<<~RUBY, receiver: receiver, accessor: accessor)
        %{receiver}.arguments%{accessor}
        _{receiver} ^^^^^^^^^^{accessor} Use `##{position}_argument` instead of `#arguments#{accessor}`.
      RUBY

      expect_correction(<<~RUBY)
        #{correction_source}
      RUBY
    end
  end

  shared_examples 'does not register an offense' do |code|
    it "does not register an offense when using `#{code}`" do
      expect_no_offenses(code)
    end
  end

  include_examples 'registers an offense', receiver: 'node', position: 'first', accessor: '.first'
  include_examples 'registers an offense', receiver: 'node', position: 'first', accessor: '[0]'
  include_examples 'registers an offense', receiver: 'node', position: 'last', accessor: '.last'
  include_examples 'registers an offense', receiver: 'node', position: 'last', accessor: '[-1]'
  include_examples 'registers an offense', receiver: 'some_node', position: 'first', accessor: '.first'
  include_examples 'registers an offense', receiver: 'some_node', position: 'first', accessor: '[0]'
  include_examples 'registers an offense', receiver: 'some_node', position: 'last', accessor: '.last'
  include_examples 'registers an offense', receiver: 'some_node', position: 'last', accessor: '[-1]'

  include_examples 'does not register an offense', 'node.first_argument'
  include_examples 'does not register an offense', 'node.last_argument'
  include_examples 'does not register an offense', 'arguments.first'
  include_examples 'does not register an offense', 'arguments.last'
  include_examples 'does not register an offense', 'arguments[0]'
  include_examples 'does not register an offense', 'arguments[-1]'
end
