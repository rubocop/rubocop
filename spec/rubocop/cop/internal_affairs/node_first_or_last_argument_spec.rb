# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::NodeFirstOrLastArgument, :config do
  shared_examples 'registers an offense' do |receiver:, position:, accessor:, dot: '.'|
    offending_source = "#{receiver}.arguments#{accessor}"
    correction_source = "#{receiver}#{dot}#{position}_argument"

    it "registers an offense when using `#{offending_source}`" do
      expect_offense(<<~RUBY, receiver: receiver, accessor: accessor, dot: dot)
        %{receiver}%{dot}arguments%{accessor}
        _{receiver}_{dot}^^^^^^^^^^{accessor} Use `##{position}_argument` instead of `#arguments#{accessor}`.
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

  it_behaves_like 'registers an offense', receiver: 'node', position: 'first', accessor: '.first'
  it_behaves_like 'registers an offense', receiver: 'node', position: 'first', accessor: '[0]'
  it_behaves_like 'registers an offense', receiver: 'node', position: 'last', accessor: '.last'
  it_behaves_like 'registers an offense', receiver: 'node', position: 'last', accessor: '[-1]'

  it_behaves_like 'registers an offense', receiver: 'node', position: 'first', accessor: '&.first'
  it_behaves_like 'registers an offense', receiver: 'node', position: 'first', accessor: '&.[](0)'
  it_behaves_like 'registers an offense', receiver: 'node', position: 'last', accessor: '&.last'
  it_behaves_like 'registers an offense', receiver: 'node', position: 'last', accessor: '&.[](-1)'

  it_behaves_like 'registers an offense', receiver: 'node', position: 'first', accessor: '&.first', dot: '&.'
  it_behaves_like 'registers an offense', receiver: 'node', position: 'first', accessor: '&.[](0)', dot: '&.'
  it_behaves_like 'registers an offense', receiver: 'node', position: 'last', accessor: '&.last', dot: '&.'
  it_behaves_like 'registers an offense', receiver: 'node', position: 'last', accessor: '&.[](-1)', dot: '&.'

  it_behaves_like 'registers an offense', receiver: 'some_node', position: 'first', accessor: '.first'
  it_behaves_like 'registers an offense', receiver: 'some_node', position: 'first', accessor: '[0]'
  it_behaves_like 'registers an offense', receiver: 'some_node', position: 'last', accessor: '.last'
  it_behaves_like 'registers an offense', receiver: 'some_node', position: 'last', accessor: '[-1]'

  it_behaves_like 'does not register an offense', 'node.first_argument'
  it_behaves_like 'does not register an offense', 'node.last_argument'
  it_behaves_like 'does not register an offense', 'arguments.first'
  it_behaves_like 'does not register an offense', 'arguments.last'
  it_behaves_like 'does not register an offense', 'arguments[0]'
  it_behaves_like 'does not register an offense', 'arguments[-1]'
end
