# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::Debugger, :config do
  it 'reports an offense for a debugger call' do
    expect_offense(<<~RUBY)
      debugger
      ^^^^^^^^ Remove debugger entry point `debugger`.
    RUBY
  end

  it 'reports an offense for a byebug call' do
    expect_offense(<<~RUBY)
      byebug
      ^^^^^^ Remove debugger entry point `byebug`.
    RUBY
  end

  it 'reports an offense for a pry binding call' do
    expect_offense(<<~RUBY)
      binding.pry
      ^^^^^^^^^^^ Remove debugger entry point `binding.pry`.
    RUBY
  end

  it 'reports an offense for a remote_pry binding call' do
    expect_offense(<<~RUBY)
      binding.remote_pry
      ^^^^^^^^^^^^^^^^^^ Remove debugger entry point `binding.remote_pry`.
    RUBY
  end

  it 'reports an offense for a pry_remote binding call' do
    expect_offense(<<~RUBY)
      binding.pry_remote
      ^^^^^^^^^^^^^^^^^^ Remove debugger entry point `binding.pry_remote`.
    RUBY
  end

  context 'with capybara debug method call' do
    it 'reports an offense for save_and_open_page' do
      expect_offense(<<~RUBY)
        save_and_open_page
        ^^^^^^^^^^^^^^^^^^ Remove debugger entry point `save_and_open_page`.
      RUBY
    end

    it 'reports an offense for save_and_open_screenshot' do
      expect_offense(<<~RUBY)
        save_and_open_screenshot
        ^^^^^^^^^^^^^^^^^^^^^^^^ Remove debugger entry point `save_and_open_screenshot`.
      RUBY
    end

    it 'reports an offense for save_screenshot' do
      expect_offense(<<~RUBY)
        save_screenshot
        ^^^^^^^^^^^^^^^ Remove debugger entry point `save_screenshot`.
      RUBY
    end

    context 'with an argument' do
      it 'reports an offense for save_and_open_page' do
        expect_offense(<<~RUBY)
          save_and_open_page foo
          ^^^^^^^^^^^^^^^^^^^^^^ Remove debugger entry point `save_and_open_page foo`.
        RUBY
      end

      it 'reports an offense for save_and_open_screenshot' do
        expect_offense(<<~RUBY)
          save_and_open_screenshot foo
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove debugger entry point `save_and_open_screenshot foo`.
        RUBY
      end

      it 'reports an offense for save_screenshot' do
        expect_offense(<<~RUBY)
          save_screenshot foo
          ^^^^^^^^^^^^^^^^^^^ Remove debugger entry point `save_screenshot foo`.
        RUBY
      end
    end
  end

  it 'reports an offense for a debugger with an argument call' do
    expect_offense(<<~RUBY)
      debugger foo
      ^^^^^^^^^^^^ Remove debugger entry point `debugger foo`.
    RUBY
  end

  it 'reports an offense for a byebug with an argument call' do
    expect_offense(<<~RUBY)
      byebug foo
      ^^^^^^^^^^ Remove debugger entry point `byebug foo`.
    RUBY
  end

  it 'reports an offense for a pry binding with an argument call' do
    expect_offense(<<~RUBY)
      binding.pry foo
      ^^^^^^^^^^^^^^^ Remove debugger entry point `binding.pry foo`.
    RUBY
  end

  it 'reports an offense for a remote_pry binding with an argument call' do
    expect_offense(<<~RUBY)
      binding.remote_pry foo
      ^^^^^^^^^^^^^^^^^^^^^^ Remove debugger entry point `binding.remote_pry foo`.
    RUBY
  end

  it 'reports an offense for a pry_remote binding with an argument call' do
    expect_offense(<<~RUBY)
      binding.pry_remote foo
      ^^^^^^^^^^^^^^^^^^^^^^ Remove debugger entry point `binding.pry_remote foo`.
    RUBY
  end

  it 'reports an offense for a remote_byebug call' do
    expect_offense(<<~RUBY)
      remote_byebug
      ^^^^^^^^^^^^^ Remove debugger entry point `remote_byebug`.
    RUBY
  end

  it 'reports an offense for a web console binding call' do
    expect_offense(<<~RUBY)
      binding.console
      ^^^^^^^^^^^^^^^ Remove debugger entry point `binding.console`.
    RUBY
  end

  it 'does not report an offense for a non-pry binding' do
    expect_no_offenses('binding.pirate')
  end

  it 'reports an offense for a debugger with Kernel call' do
    expect_offense(<<~RUBY)
      Kernel.debugger
      ^^^^^^^^^^^^^^^ Remove debugger entry point `Kernel.debugger`.
    RUBY
  end

  it 'reports an offense for a debugger with ::Kernel call' do
    expect_offense(<<~RUBY)
      ::Kernel.debugger
      ^^^^^^^^^^^^^^^^^ Remove debugger entry point `::Kernel.debugger`.
    RUBY
  end

  it 'reports an offense for a binding.pry with Kernel call' do
    expect_offense(<<~RUBY)
      Kernel.binding.pry
      ^^^^^^^^^^^^^^^^^^ Remove debugger entry point `Kernel.binding.pry`.
    RUBY
  end

  it 'does not report an offense for save_and_open_page with Kernel' do
    expect_no_offenses('Kernel.save_and_open_page')
  end

  %w[debugger byebug console pry remote_pry pry_remote irb save_and_open_page
     save_and_open_screenshot save_screenshot remote_byebug].each do |src|
    it "does not report an offense for a #{src} in comments" do
      expect_no_offenses("# #{src}")
    end

    it "does not report an offense for a #{src} method" do
      expect_no_offenses("code.#{src}")
    end
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

  it 'reports an offense for a irb binding call' do
    expect_offense(<<~RUBY)
      binding.irb
      ^^^^^^^^^^^ Remove debugger entry point `binding.irb`.
    RUBY
  end

  it 'reports an offense for a binding.irb with Kernel call' do
    expect_offense(<<~RUBY)
      Kernel.binding.irb
      ^^^^^^^^^^^^^^^^^^ Remove debugger entry point `Kernel.binding.irb`.
    RUBY
  end
end
