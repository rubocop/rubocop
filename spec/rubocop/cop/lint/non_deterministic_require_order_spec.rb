# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NonDeterministicRequireOrder do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when requiring files' do
    context 'with unsorted index' do
      it 'registers an offsense' do
        expect_offense(<<~RUBY)
          Dir["./lib/**/*.rb"].each do |file|
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
            require file
          end
        RUBY
      end

      it 'registers an offsense with extra logic' do
        expect_offense(<<~RUBY)
          Dir["./lib/**/*.rb"].each do |file|
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
            if file.starts_with('_')
              puts "Not required."
            else
              require file
            end
          end
        RUBY
      end

      it 'auto-corrects to add .sort' do
        new_source = autocorrect_source(<<~RUBY)
          Dir["./lib/**/*.rb"].each do |file|
            require file
          end
        RUBY
        expect(new_source).to eq(<<~RUBY)
          Dir["./lib/**/*.rb"].sort.each do |file|
            require file
          end
        RUBY
      end
    end

    context 'with unsorted glob' do
      it 'registers an offsense' do
        expect_offense(<<~RUBY)
          Dir.glob(Rails.root.join(__dir__, 'test', '*.rb'), File::FNM_DOTMATCH).each do |file|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
            require file
          end
        RUBY
      end

      it 'auto-corrects to add .sort' do
        new_source = autocorrect_source(<<~RUBY)
          Dir.glob(Rails.root.join(__dir__, 'test', '*.rb'), File::FNM_DOTMATCH).each do |file|
            require file
          end
        RUBY
        expect(new_source).to eq(<<~RUBY)
          Dir.glob(Rails.root.join(__dir__, 'test', '*.rb'), File::FNM_DOTMATCH).sort.each do |file|
            require file
          end
        RUBY
      end
    end

    context 'with direct block glob' do
      it 'registers an offsense' do
        expect_offense(<<~RUBY)
          Dir.glob("./lib/**/*.rb") do |file|
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Sort files before requiring them.
            require file
          end
        RUBY
      end

      it 'auto-corrects to add .sort.each' do
        new_source = autocorrect_source(<<~RUBY)
          Dir.glob("./lib/**/*.rb") do |file|
            require file
          end
        RUBY
        expect(new_source).to eq(<<~RUBY)
          Dir.glob("./lib/**/*.rb").sort.each do |file|
            require file
          end
        RUBY
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
