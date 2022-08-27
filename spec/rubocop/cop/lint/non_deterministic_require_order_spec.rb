# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NonDeterministicRequireOrder, :config do
  context 'when requiring files' do
    context 'when Ruby 3.0 or higher', :ruby30 do
      context 'with `Dir[]`' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            Dir["./lib/**/*.rb"].each do |file|
              require file
            end
          RUBY
        end

        context 'with extra logic' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              Dir["./lib/**/*.rb"].each do |file|
                if file.start_with?('_')
                  puts "Not required."
                else
                  require file
                end
              end
            RUBY
          end
        end

        context 'with require block passed as parameter' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              Dir["./lib/**/*.rb"].each(&method(:require))
            RUBY
          end
        end

        context 'with top-level ::Dir' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              ::Dir["./lib/**/*.rb"].each do |file|
                require file
              end
            RUBY
          end
        end
      end

      context 'with `Dir.glob`' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            Dir.glob(Rails.root.join(__dir__, 'test', '*.rb'), File::FNM_DOTMATCH).each do |file|
              require file
            end
          RUBY
        end

        context 'with require block passed as parameter' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              Dir.glob(Rails.root.join('test', '*.rb')).each(&method(:require))
            RUBY
          end
        end

        context 'with top-level ::Dir' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              ::Dir.glob(Rails.root.join(__dir__, 'test', '*.rb'), ::File::FNM_DOTMATCH).each do |file|
                require file
              end
            RUBY
          end
        end

        context 'with `sort: false` keyword option' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              Dir.glob(Rails.root.join('test', '*.rb'), sort: false).each(&method(:require))
            RUBY
          end
        end
      end

      context 'with direct block glob' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            Dir.glob("./lib/**/*.rb") do |file|
              require file
            end
          RUBY
        end

        context 'with require block passed as parameter' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              Dir.glob(
                Rails.root.join('./lib/**/*.rb'),
                File::FNM_DOTMATCH,
                &method(:require)
              )
            RUBY
          end
        end

        context 'with top-level ::Dir' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              ::Dir.glob("./lib/**/*.rb") do |file|
                require file
              end
            RUBY
          end
        end
      end
    end

    context 'when Ruby 2.7 or lower', :ruby27 do
      context 'with unsorted index' do
        it 'registers an offense and autocorrects to add .sort when the block has `require`' do
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

        it 'registers an offense and autocorrects to add .sort when the numblock has `require`' do
          expect_offense(<<~RUBY)
            Dir["./lib/**/*.rb"].each do
            ^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
              require _1
            end
          RUBY

          expect_correction(<<~RUBY)
            Dir["./lib/**/*.rb"].sort.each do
              require _1
            end
          RUBY
        end

        it 'registers an offense and autocorrects to add .sort when the block has `require_relative`' do
          expect_offense(<<~RUBY)
            Dir["./lib/**/*.rb"].each do |file|
            ^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
              require_relative file
            end
          RUBY

          expect_correction(<<~RUBY)
            Dir["./lib/**/*.rb"].sort.each do |file|
              require_relative file
            end
          RUBY
        end

        it 'registers an offense with extra logic' do
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

        context 'with require_relative block passed as parameter' do
          it 'registers an offense an autocorrects to add sort' do
            expect_offense(<<~RUBY)
              Dir["./lib/**/*.rb"].each(&method(:require_relative))
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
            RUBY

            expect_correction(<<~RUBY)
              Dir["./lib/**/*.rb"].sort.each(&method(:require_relative))
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
        it 'registers an offense and autocorrects to add .sort' do
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
        it 'registers an offense and autocorrects to add .sort.each' do
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

        context 'with require_relative block passed as parameter' do
          it 'registers an offense and autocorrects to add sort' do
            expect_offense(<<~RUBY)
              Dir.glob(
              ^^^^^^^^^ Sort files before requiring them.
                Rails.root.join('./lib/**/*.rb'),
                File::FNM_DOTMATCH,
                &method(:require_relative)
              )
            RUBY

            expect_correction(<<~RUBY)
              Dir.glob(
                Rails.root.join('./lib/**/*.rb'),
                File::FNM_DOTMATCH
              ).sort.each(&method(:require_relative))
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
