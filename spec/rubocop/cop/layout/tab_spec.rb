# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::Tab do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Layout/IndentationWidth' => { 'Width' => 2 })
  end

  it 'registers an offense for a line indented with tab' do
    expect_offense(<<-RUBY.strip_indent)
      	x = 0
      ^ Tab detected.
    RUBY
  end

  it 'registers an offense for a line indented with multiple tabs' do
    expect_offense(<<-RUBY.strip_indent)
      			x = 0
      ^^^ Tab detected.
    RUBY
  end

  it 'registers an offense for a line indented with mixed whitespace' do
    expect_offense(<<-RUBY.strip_indent)
       	x = 0
       ^ Tab detected.
    RUBY
  end

  it 'registers offenses before __RUBY__ but not after' do
    expect_offense(<<-RUBY.strip_indent)
      \tx = 0
      ^ Tab detected.
      __END__
      \tx = 0
    RUBY
  end

  it 'accepts a line with tab in a string' do
    expect_no_offenses("(x = \"\t\")")
  end

  it 'accepts a line which begins with tab in a string' do
    expect_no_offenses("x = '\n\thello'")
  end

  it 'accepts a line which begins with tab in a heredoc' do
    expect_no_offenses("x = <<HELLO\n\thello\nHELLO")
  end

  it 'auto-corrects a line indented with tab' do
    new_source = autocorrect_source(["\tx = 0"])
    expect(new_source).to eq('  x = 0')
  end

  it 'auto-corrects a line indented with multiple tabs' do
    new_source = autocorrect_source(["\t\t\tx = 0"])
    expect(new_source).to eq('      x = 0')
  end

  it 'auto-corrects a line indented with mixed whitespace' do
    new_source = autocorrect_source([" \tx = 0"])
    expect(new_source).to eq('   x = 0')
  end

  it 'auto-corrects a line with tab in a string indented with tab' do
    new_source = autocorrect_source(["\t(x = \"\t\")"])
    expect(new_source).to eq("  (x = \"\t\")")
  end

  context 'custom indentation width' do
    let(:config) do
      RuboCop::Config.new('Layout/Tab' => {
                            'IndentationWidth' => 3
                          },
                          'Layout/IndentationWidth' => { 'Width' => 2 })
    end

    it 'uses the configured number of spaces to replace a tab' do
      new_source = autocorrect_source("\tx = 0")

      expect(new_source).to eq('   x = 0')
    end
  end
end
