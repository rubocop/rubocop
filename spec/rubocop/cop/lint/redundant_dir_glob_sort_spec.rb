# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantDirGlobSort, :config do
  context 'when Ruby 3.0 or higher', :ruby30 do
    it 'registers an offense and correction when using `Dir.glob.sort`' do
      expect_offense(<<~RUBY)
        Dir.glob(Rails.root.join('test', '*.rb')).sort.each(&method(:require))
                                                  ^^^^ Remove redundant `sort`.
      RUBY

      expect_correction(<<~RUBY)
        Dir.glob(Rails.root.join('test', '*.rb')).each(&method(:require))
      RUBY
    end

    it 'registers an offense and correction when using `::Dir.glob.sort`' do
      expect_offense(<<~RUBY)
        ::Dir.glob(Rails.root.join('test', '*.rb')).sort.each(&method(:require))
                                                    ^^^^ Remove redundant `sort`.
      RUBY

      expect_correction(<<~RUBY)
        ::Dir.glob(Rails.root.join('test', '*.rb')).each(&method(:require))
      RUBY
    end

    it 'registers an offense and correction when using `Dir[].sort.each do`' do
      expect_offense(<<~RUBY)
        Dir['./lib/**/*.rb'].sort.each do |file|
                             ^^^^ Remove redundant `sort`.
        end
      RUBY

      expect_correction(<<~RUBY)
        Dir['./lib/**/*.rb'].each do |file|
        end
      RUBY
    end

    it 'registers an offense and correction when using `Dir[].sort.each(&do_something)`' do
      expect_offense(<<~RUBY)
        Dir['./lib/**/*.rb'].sort.each(&method(:require))
                             ^^^^ Remove redundant `sort`.
      RUBY

      expect_correction(<<~RUBY)
        Dir['./lib/**/*.rb'].each(&method(:require))
      RUBY
    end

    it 'does not register an offense when not using `sort` with `sort: false` option for `Dir`' do
      expect_no_offenses(<<~RUBY)
        Dir.glob(Rails.root.join('test', '*.rb'), sort: false).each do
        end
      RUBY
    end

    it "does not register an offense when using `Dir.glob('./b/*.txt', './a/*.txt').sort`" do
      expect_no_offenses(<<~RUBY)
        Dir.glob('./b/*.txt', './a/*.txt').sort.each(&method(:require))
      RUBY
    end

    it 'does not register an offense when using `Dir.glob(*path).sort`' do
      expect_no_offenses(<<~RUBY)
        Dir.glob(*path).sort.each(&method(:require))
      RUBY
    end

    it "does not register an offense when using `Dir['./b/*.txt', './a/*.txt'].sort`" do
      expect_no_offenses(<<~RUBY)
        Dir['./b/*.txt', './a/*.txt'].sort.each(&method(:require))
      RUBY
    end

    it 'does not register an offense when using `Dir[*path].sort`' do
      expect_no_offenses(<<~RUBY)
        Dir[*path].sort.each(&method(:require))
      RUBY
    end

    it 'does not register an offense when using `collection.sort`' do
      expect_no_offenses(<<~RUBY)
        collection.sort
      RUBY
    end
  end

  context 'when Ruby 2.7 or lower', :ruby27 do
    it 'does not register an offense and correction when using `Dir.glob.sort`' do
      expect_no_offenses(<<~RUBY)
        Dir.glob(Rails.root.join('test', '*.rb')).sort.each(&method(:require))
      RUBY
    end

    it 'does not register an offense and correction when using `::Dir.glob.sort`' do
      expect_no_offenses(<<~RUBY)
        ::Dir.glob(Rails.root.join('test', '*.rb')).sort.each(&method(:require))
      RUBY
    end

    it 'does not register an offense and correction when using `Dir[].sort.each do`' do
      expect_no_offenses(<<~RUBY)
        Dir['./lib/**/*.rb'].sort.each do |file|
        end
      RUBY
    end

    it 'does not register an offense and correction when using `Dir[].sort.each(&do_something)`' do
      expect_no_offenses(<<~RUBY)
        Dir['./lib/**/*.rb'].sort.each(&method(:require))
      RUBY
    end
  end

  it 'does not register an offense when not using `sort` for `Dir`' do
    expect_no_offenses(<<~RUBY)
      Dir['./lib/**/*.rb'].each do |file|
      end
    RUBY
  end

  it 'does not register an offense when using `sort` without a receiver' do
    expect_no_offenses(<<~RUBY)
      sort.do_something
    RUBY
  end
end
