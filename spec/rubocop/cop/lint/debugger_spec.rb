# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::Debugger, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples_for 'debugger' do |name, src|
    it "reports an offense for a #{name} call" do
      inspect_source(src)
      src = [src] if src.is_a? String
      expect(cop.offenses.size).to eq(src.size)
      expect(cop.messages)
        .to eq(src.map { |s| "Remove debugger entry point `#{s}`." })
      expect(cop.highlights).to eq(src)
    end
  end

  shared_examples_for 'non-debugger' do |name, src|
    it "does not report an offense for #{name}" do
      inspect_source(src)
      expect(cop.offenses.empty?).to be(true)
    end
  end

  include_examples 'debugger', 'debugger', 'debugger'
  include_examples 'debugger', 'byebug', 'byebug'
  include_examples 'debugger', 'pry binding',
                   'binding.pry'
  include_examples 'debugger', 'pry binding',
                   'binding.remote_pry'
  include_examples 'debugger', 'pry binding',
                   'binding.pry_remote'
  include_examples 'debugger',
                   'capybara debug method',
                   'save_and_open_page'
  include_examples 'debugger',
                   'capybara debug method',
                   'save_and_open_screenshot'
  include_examples 'debugger',
                   'capybara debug method',
                   'save_screenshot'
  include_examples 'debugger', 'debugger with an argument', 'debugger foo'
  include_examples 'debugger', 'byebug with an argument', 'byebug foo'
  include_examples 'debugger',
                   'pry binding with an argument',
                   'binding.pry foo'
  include_examples 'debugger',
                   'pry binding with an argument',
                   'binding.remote_pry foo'
  include_examples 'debugger',
                   'pry binding with an argument',
                   'binding.pry_remote foo'
  include_examples 'debugger',
                   'capybara debug method with an argument',
                   'save_and_open_page foo'
  include_examples 'debugger',
                   'capybara debug method with an argument',
                   'save_and_open_screenshot foo'
  include_examples 'debugger',
                   'capybara debug method with an argument',
                   'save_screenshot foo'
  include_examples 'non-debugger', 'a non-pry binding', 'binding.pirate'

  include_examples 'debugger', 'debugger with Kernel', 'Kernel.debugger'
  include_examples 'debugger', 'debugger with ::Kernel', '::Kernel.debugger'
  include_examples 'debugger', 'binding.pry with Kernel', 'Kernel.binding.pry'
  include_examples 'non-debugger', 'save_and_open_page with Kernel',
                   'Kernel.save_and_open_page'

  ALL_COMMANDS = %w[debugger byebug pry remote_pry pry_remote irb
                    save_and_open_page save_and_open_screenshot
                    save_screenshot].freeze

  ALL_COMMANDS.each do |src|
    include_examples 'non-debugger', "a #{src} in comments", "# #{src}"
    include_examples 'non-debugger', "a #{src} method", "code.#{src}"
  end

  it 'reports an offense for a Pry.rescue call' do
    expect_offense(<<~RUBY)
      def method
        Pry.rescue { puts 1 }
        ^^^^^^^^^^ Remove debugger entry point `Pry.rescue`.
        ::Pry.rescue { puts 1 }
        ^^^^^^^^^^^^ Remove debugger entry point `::Pry.rescue`.
      end
    RUBY
  end

  context 'target_ruby_version >= 2.4', :ruby24 do
    include_examples 'debugger', 'irb binding', 'binding.irb'
    include_examples 'debugger', 'binding.irb with Kernel', 'Kernel.binding.irb'

    ALL_COMMANDS.each do |src|
      include_examples 'non-debugger', "a #{src} in comments", "# #{src}"
      include_examples 'non-debugger', "a #{src} method", "code.#{src}"
    end
  end
end
