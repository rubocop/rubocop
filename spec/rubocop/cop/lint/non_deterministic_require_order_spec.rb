# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NonDeterministicRequireOrder do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when requiring files' do
    context 'with unsorted index' do
      it 'registers an offsense and autocorrects to add .sort' do
        expect_offense(<<~RUBY)
          Dir["./lib/**/*.rb"].each do |file|
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
            require file
          end
        RUBY
        expect_correction(<<~RUBY)
          Dir["./lib/**/*.rb"].sort.each do |file|
            require file
          end
        RUBY
      end

      it 'registers an offsense with extra logic' do
        expect_offense(<<~RUBY)
          Dir["./lib/**/*.rb"].each do |file|
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
            if file.start_with?('_')
              puts "Not required."
            else
              require file
            end
          end
        RUBY
        expect_correction(<<~RUBY)
          Dir["./lib/**/*.rb"].sort.each do |file|
            if file.start_with?('_')
              puts "Not required."
            else
              require file
            end
          end
        RUBY
      end

      context 'with require block passed as parameter' do
        it 'registers an offense an autocorrects to add sort' do
          expect_offense(<<~RUBY)
            Dir["./lib/**/*.rb"].each(&method(:require))
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
          RUBY
          expect_correction(<<~RUBY)
            Dir["./lib/**/*.rb"].sort.each(&method(:require))
          RUBY
        end
      end

      context 'with top-level ::Dir' do
        it 'registers an offense and corrects to add .sort' do
          expect_offense(<<~RUBY)
            ::Dir["./lib/**/*.rb"].each do |file|
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
              require file
            end
          RUBY
          expect_correction(<<~RUBY)
            ::Dir["./lib/**/*.rb"].sort.each do |file|
              require file
            end
          RUBY
        end
      end
    end

    context 'with unsorted glob' do
      it 'registers an offsense and autocorrects to add .sort' do
        expect_offense(<<~RUBY)
          Dir.glob(Rails.root.join(__dir__, 'test', '*.rb'), File::FNM_DOTMATCH).each do |file|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
            require file
          end
        RUBY
        expect_correction(<<~RUBY)
          Dir.glob(Rails.root.join(__dir__, 'test', '*.rb'), File::FNM_DOTMATCH).sort.each do |file|
            require file
          end
        RUBY
      end

      context 'with require block passed as parameter' do
        it 'registers an offense an autocorrects to add sort' do
          expect_offense(<<~RUBY)
            Dir.glob(Rails.root.join('test', '*.rb')).each(&method(:require))
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
          RUBY
          expect_correction(<<~RUBY)
            Dir.glob(Rails.root.join('test', '*.rb')).sort.each(&method(:require))
          RUBY
        end
      end

      context 'with top-level ::Dir' do
        it 'registers an offense and corrects to add .sort' do
          expect_offense(<<~RUBY)
            ::Dir.glob(Rails.root.join(__dir__, 'test', '*.rb'), ::File::FNM_DOTMATCH).each do |file|
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
              require file
            end
          RUBY
          expect_correction(<<~RUBY)
            ::Dir.glob(Rails.root.join(__dir__, 'test', '*.rb'), ::File::FNM_DOTMATCH).sort.each do |file|
              require file
            end
          RUBY
        end
      end
    end

    context 'with direct block glob' do
      it 'registers an offsense and autocorrects to add .sort.each' do
        expect_offense(<<~RUBY)
          Dir.glob("./lib/**/*.rb") do |file|
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
            require file
          end
        RUBY
        expect_correction(<<~RUBY)
          Dir.glob("./lib/**/*.rb").sort.each do |file|
            require file
          end
        RUBY
      end

      context 'with require block passed as parameter' do
        it 'registers an offense and autocorrects to add sort' do
          expect_offense(<<~RUBY)
            Dir.glob(
            ^^^^^^^^^ Sort files before requiring them.
              Rails.root.join('./lib/**/*.rb'),
              File::FNM_DOTMATCH,
              &method(:require)
            )
          RUBY
          expect_correction(<<~RUBY)
            Dir.glob(
              Rails.root.join('./lib/**/*.rb'),
              File::FNM_DOTMATCH
            ).sort.each(&method(:require))
          RUBY
        end
      end

      context 'with top-level ::Dir' do
        it 'registers an offense and corrects to add .sort.each' do
          expect_offense(<<~RUBY)
            ::Dir.glob("./lib/**/*.rb") do |file|
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
              require file
            end
          RUBY
          expect_correction(<<~RUBY)
            ::Dir.glob("./lib/**/*.rb").sort.each do |file|
              require file
            end
          RUBY
        end
      end
    end

    context 'with sorted index' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Dir["./lib/**/*.rb"].sort.each do |file|
            require file
          end
        RUBY
      end
    end

    context 'with sorted glob' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Dir.glob(Rails.root.join(__dir__, 'test', '*.rb'), File::FNM_DOTMATCH).sort.each do |file|
            require file
          end
        RUBY
      end
    end
  end

  context 'when not requiring files' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Dir["./lib/**/*.rb"].each do |file|
          puts file
        end
      RUBY
    end
  end
end
