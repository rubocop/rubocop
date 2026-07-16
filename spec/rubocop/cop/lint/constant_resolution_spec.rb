# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ConstantResolution, :config do
  it 'registers no offense when qualifying a const' do
    expect_no_offenses(<<~RUBY)
      ::MyConst
    RUBY
  end

  it 'registers no offense qualifying a namespace const' do
    expect_no_offenses(<<~RUBY)
      ::MyConst::MY_CONST
    RUBY
  end

  it 'registers an offense not qualifying a const' do
    expect_offense(<<~RUBY)
      MyConst
      ^^^^^^^ Fully qualify this constant to avoid possibly ambiguous resolution.
    RUBY
  end

  it 'registers an offense not qualifying a namespace const' do
    expect_offense(<<~RUBY)
      MyConst::MY_CONST
      ^^^^^^^ Fully qualify this constant to avoid possibly ambiguous resolution.
    RUBY
  end

  context 'module & class definitions' do
    it 'does not register offense' do
      expect_no_offenses(<<~RUBY)
        module Foo; end
        class Bar; end
      RUBY
    end
  end

  context 'with Only set' do
    let(:cop_config) { { 'Only' => ['MY_CONST'] } }

    it 'registers no offense when qualifying a const' do
      expect_no_offenses(<<~RUBY)
        ::MyConst
      RUBY
    end

    it 'registers no offense qualifying a namespace const' do
      expect_no_offenses(<<~RUBY)
        ::MyConst::MY_CONST
      RUBY
    end

    it 'registers no offense not qualifying another const' do
      expect_no_offenses(<<~RUBY)
        MyConst
      RUBY
    end

    it 'registers no with a namespace const' do
      expect_no_offenses(<<~RUBY)
        MyConst::MY_CONST
      RUBY
    end

    it 'registers an offense with an unqualified const' do
      expect_offense(<<~RUBY)
        MY_CONST
        ^^^^^^^^ Fully qualify this constant to avoid possibly ambiguous resolution.
      RUBY
    end

    it 'registers an offense when an unqualified namespace const' do
      expect_offense(<<~RUBY)
        MY_CONST::B
        ^^^^^^^^ Fully qualify this constant to avoid possibly ambiguous resolution.
      RUBY
    end
  end

  context 'with Ignore set' do
    let(:cop_config) { { 'Ignore' => ['MY_CONST'] } }

    it 'registers no offense when qualifying a const' do
      expect_no_offenses(<<~RUBY)
        ::MyConst
      RUBY
    end

    it 'registers no offense qualifying a namespace const' do
      expect_no_offenses(<<~RUBY)
        ::MyConst::MY_CONST
      RUBY
    end

    it 'registers an offense not qualifying another const' do
      expect_offense(<<~RUBY)
        MyConst
        ^^^^^^^ Fully qualify this constant to avoid possibly ambiguous resolution.
      RUBY
    end

    it 'registers an offense with a namespace const' do
      expect_offense(<<~RUBY)
        MyConst::MY_CONST
        ^^^^^^^ Fully qualify this constant to avoid possibly ambiguous resolution.
      RUBY
    end

    it 'registers no offense with an unqualified const' do
      expect_no_offenses(<<~RUBY)
        MY_CONST
      RUBY
    end

    it 'registers no offense when an unqualified namespace const' do
      expect_no_offenses(<<~RUBY)
        MY_CONST::B
      RUBY
    end

    it 'registers no offense when using `__ENCODING__`' do
      expect_no_offenses(<<~RUBY)
        __ENCODING__
      RUBY
    end
  end

  context 'with a project index', :project_index do
    let(:cop_config) { {} }

    def index_with_current(source, sources = {})
      build_index(sources.merge('file:///current.rb' => source))
    end

    it 'registers an offense when the constant is shadowed by the surrounding nesting' do
      source = <<~RUBY
        module App
          def self.load
            Config.load
          end
        end
      RUBY
      cop.project_index = index_with_current(
        source,
        'file:///config.rb' => "class Config\nend\n",
        'file:///app_config.rb' => "module App\n  class Config\n  end\nend\n"
      )

      expect_offense(<<~RUBY, 'current.rb')
        module App
          def self.load
            Config.load
            ^^^^^^ Fully qualify this constant to avoid possibly ambiguous resolution.
          end
        end
      RUBY
    end

    it 'does not register an offense when the constant resolves identically either way' do
      source = <<~RUBY
        module App
          def self.load
            Config.load
          end
        end
      RUBY
      cop.project_index = index_with_current(
        source, 'file:///config.rb' => "class Config\nend\n"
      )

      expect_no_offenses(source, 'current.rb')
    end

    it 'does not register an offense when the constant is not in the index' do
      source = <<~RUBY
        module App
          def self.parse(json)
            JSON.parse(json)
          end
        end
      RUBY
      cop.project_index = index_with_current(source)

      expect_no_offenses(source, 'current.rb')
    end
  end
end
