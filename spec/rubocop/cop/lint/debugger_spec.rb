# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::Debugger, :config do
  context 'with the DebuggerMethods configuration' do
    let(:cop_config) do
      { 'DebuggerMethods' => %w[custom_debugger] }
    end

    it 'does not register an offense for a byebug call' do
      expect_no_offenses(<<~RUBY)
        byebug
      RUBY
    end

    it 'registers an offense for a `custom_debugger` call' do
      expect_offense(<<~RUBY)
        custom_debugger
        ^^^^^^^^^^^^^^^ Remove debugger entry point `custom_debugger`.
      RUBY
    end

    context 'nested custom configurations' do
      let(:cop_config) do
        {
          'DebuggerMethods' => {
            'Custom' => %w[custom_debugger]
          }
        }
      end

      it 'registers an offense for a `custom_debugger call' do
        expect_offense(<<~RUBY)
          custom_debugger
          ^^^^^^^^^^^^^^^ Remove debugger entry point `custom_debugger`.
        RUBY
      end
    end
  end

  context 'built-in methods' do
    it 'registers an offense for a irb binding call' do
      expect_offense(<<~RUBY)
        binding.irb
        ^^^^^^^^^^^ Remove debugger entry point `binding.irb`.
      RUBY
    end

    it 'registers an offense for a binding.irb with Kernel call' do
      expect_offense(<<~RUBY)
        Kernel.binding.irb
        ^^^^^^^^^^^^^^^^^^ Remove debugger entry point `Kernel.binding.irb`.
      RUBY
    end
  end

  context 'byebug' do
    it 'registers an offense for a byebug call' do
      expect_offense(<<~RUBY)
        byebug
        ^^^^^^ Remove debugger entry point `byebug`.
      RUBY
    end

    it 'registers an offense for a byebug with an argument call' do
      expect_offense(<<~RUBY)
        byebug foo
        ^^^^^^^^^^ Remove debugger entry point `byebug foo`.
      RUBY
    end

    it 'registers an offense for a Kernel.byebug call' do
      expect_offense(<<~RUBY)
        Kernel.byebug
        ^^^^^^^^^^^^^ Remove debugger entry point `Kernel.byebug`.
      RUBY
    end

    it 'registers an offense for a remote_byebug call' do
      expect_offense(<<~RUBY)
        remote_byebug
        ^^^^^^^^^^^^^ Remove debugger entry point `remote_byebug`.
      RUBY
    end

    it 'registers an offense for a Kernel.remote_byebug call' do
      expect_offense(<<~RUBY)
        Kernel.remote_byebug
        ^^^^^^^^^^^^^^^^^^^^ Remove debugger entry point `Kernel.remote_byebug`.
      RUBY
    end
  end

  context 'capybara' do
    it 'registers an offense for save_and_open_page' do
      expect_offense(<<~RUBY)
        save_and_open_page
        ^^^^^^^^^^^^^^^^^^ Remove debugger entry point `save_and_open_page`.
      RUBY
    end

    it 'registers an offense for save_and_open_screenshot' do
      expect_offense(<<~RUBY)
        save_and_open_screenshot
        ^^^^^^^^^^^^^^^^^^^^^^^^ Remove debugger entry point `save_and_open_screenshot`.
      RUBY
    end

    context 'with an argument' do
      it 'registers an offense for save_and_open_page' do
        expect_offense(<<~RUBY)
          save_and_open_page foo
          ^^^^^^^^^^^^^^^^^^^^^^ Remove debugger entry point `save_and_open_page foo`.
        RUBY
      end

      it 'registers an offense for save_and_open_screenshot' do
        expect_offense(<<~RUBY)
          save_and_open_screenshot foo
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove debugger entry point `save_and_open_screenshot foo`.
        RUBY
      end
    end
  end

  context 'pry' do
    it 'registers an offense for a pry binding call' do
      expect_offense(<<~RUBY)
        binding.pry
        ^^^^^^^^^^^ Remove debugger entry point `binding.pry`.
      RUBY
    end

    it 'registers an offense for a remote_pry binding call' do
      expect_offense(<<~RUBY)
        binding.remote_pry
        ^^^^^^^^^^^^^^^^^^ Remove debugger entry point `binding.remote_pry`.
      RUBY
    end

    it 'registers an offense for a pry_remote binding call' do
      expect_offense(<<~RUBY)
        binding.pry_remote
        ^^^^^^^^^^^^^^^^^^ Remove debugger entry point `binding.pry_remote`.
      RUBY
    end

    it 'registers an offense for a pry binding with an argument call' do
      expect_offense(<<~RUBY)
        binding.pry foo
        ^^^^^^^^^^^^^^^ Remove debugger entry point `binding.pry foo`.
      RUBY
    end

    it 'registers an offense for a remote_pry binding with an argument call' do
      expect_offense(<<~RUBY)
        binding.remote_pry foo
        ^^^^^^^^^^^^^^^^^^^^^^ Remove debugger entry point `binding.remote_pry foo`.
      RUBY
    end

    it 'registers an offense for a pry_remote binding with an argument call' do
      expect_offense(<<~RUBY)
        binding.pry_remote foo
        ^^^^^^^^^^^^^^^^^^^^^^ Remove debugger entry point `binding.pry_remote foo`.
      RUBY
    end

    it 'registers an offense for a binding.pry with Kernel call' do
      expect_offense(<<~RUBY)
        Kernel.binding.pry
        ^^^^^^^^^^^^^^^^^^ Remove debugger entry point `Kernel.binding.pry`.
      RUBY
    end

    it 'registers an offense for a Pry.rescue call' do
      expect_offense(<<~RUBY)
        def method
          Pry.rescue { puts 1 }
          ^^^^^^^^^^ Remove debugger entry point `Pry.rescue`.
          ::Pry.rescue { puts 1 }
          ^^^^^^^^^^^^ Remove debugger entry point `::Pry.rescue`.
        end
      RUBY
    end

    it 'does not register an offense for a `pry` call without binding' do
      expect_no_offenses('pry')
    end

    it 'does not register an offense for a `rescue` call without Pry' do
      expect_no_offenses(<<~RUBY)
        begin
        rescue StandardError
        end
      RUBY
    end
  end

  context 'rails' do
    it 'registers an offense for a debugger call' do
      expect_offense(<<~RUBY)
        debugger
        ^^^^^^^^ Remove debugger entry point `debugger`.
      RUBY
    end

    it 'registers an offense for a debugger with an argument call' do
      expect_offense(<<~RUBY)
        debugger foo
        ^^^^^^^^^^^^ Remove debugger entry point `debugger foo`.
      RUBY
    end

    it 'registers an offense for a debugger with Kernel call' do
      expect_offense(<<~RUBY)
        Kernel.debugger
        ^^^^^^^^^^^^^^^ Remove debugger entry point `Kernel.debugger`.
      RUBY
    end

    it 'registers an offense for a debugger with ::Kernel call' do
      expect_offense(<<~RUBY)
        ::Kernel.debugger
        ^^^^^^^^^^^^^^^^^ Remove debugger entry point `::Kernel.debugger`.
      RUBY
    end
  end

  context 'web console' do
    it 'registers an offense for a `binding.console` call' do
      expect_offense(<<~RUBY)
        binding.console
        ^^^^^^^^^^^^^^^ Remove debugger entry point `binding.console`.
      RUBY
    end

    it 'does not register an offense for `console` without a receiver' do
      expect_no_offenses('console')
    end
  end

  it 'does not register an offense for a binding method that is not disallowed' do
    expect_no_offenses('binding.pirate')
  end

  %w[debugger byebug console pry remote_pry pry_remote irb save_and_open_page
     save_and_open_screenshot remote_byebug].each do |src|
    it "does not register an offense for a #{src} in comments" do
      expect_no_offenses(<<~RUBY)
        # #{src}
        # Kernel.#{src}
      RUBY
    end

    it "does not register an offense for a #{src} method" do
      expect_no_offenses("code.#{src}")
    end
  end

  context 'when a method group is disabled with nil' do
    let!(:old_pry_config) { cur_cop_config['DebuggerMethods']['Pry'] }

    before { cur_cop_config['DebuggerMethods']['Pry'] = nil }

    after { cur_cop_config['DebuggerMethods']['Pry'] = old_pry_config }

    it 'does not register an offense for a Pry debugger call' do
      expect_no_offenses('binding.pry')
    end

    it 'does register an offense for another group' do
      expect_offense(<<~RUBY)
        binding.irb
        ^^^^^^^^^^^ Remove debugger entry point `binding.irb`.
      RUBY
    end
  end

  context 'when a method group is disabled with false' do
    let!(:old_pry_config) { cur_cop_config['DebuggerMethods']['Pry'] }

    before { cur_cop_config['DebuggerMethods']['Pry'] = false }

    after { cur_cop_config['DebuggerMethods']['Pry'] = old_pry_config }

    it 'does not register an offense for a Pry debugger call' do
      expect_no_offenses('binding.pry')
    end

    it 'does register an offense for another group' do
      expect_offense(<<~RUBY)
        binding.irb
        ^^^^^^^^^^^ Remove debugger entry point `binding.irb`.
      RUBY
    end
  end
end
