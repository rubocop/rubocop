# frozen_string_literal: true

describe RuboCop::Cop::Performance::Count do
  subject(:cop) { described_class.new }

  shared_examples 'selectors' do |selector|
    it "registers an offense for using array.#{selector}...size" do
      inspect_source("[1, 2, 3].#{selector} { |e| e.even? }.size")

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...size`."])
      expect(cop.highlights).to eq(["#{selector} { |e| e.even? }.size"])
    end

    it "registers an offense for using hash.#{selector}...size" do
      inspect_source("{a: 1, b: 2, c: 3}.#{selector} { |e| e == :a }.size")

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...size`."])
      expect(cop.highlights).to eq(["#{selector} { |e| e == :a }.size"])
    end

    it "registers an offense for using array.#{selector}...length" do
      inspect_source("[1, 2, 3].#{selector} { |e| e.even? }.length")

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...length`."])
      expect(cop.highlights).to eq(["#{selector} { |e| e.even? }.length"])
    end

    it "registers an offense for using hash.#{selector}...length" do
      inspect_source("{a: 1, b: 2}.#{selector} { |e| e == :a }.length")

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...length`."])
      expect(cop.highlights).to eq(["#{selector} { |e| e == :a }.length"])
    end

    it "registers an offense for using array.#{selector}...count" do
      inspect_source("[1, 2, 3].#{selector} { |e| e.even? }.count")

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...count`."])
      expect(cop.highlights).to eq(["#{selector} { |e| e.even? }.count"])
    end

    it "registers an offense for using hash.#{selector}...count" do
      inspect_source("{a: 1, b: 2}.#{selector} { |e| e == :a }.count")

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...count`."])
      expect(cop.highlights).to eq(["#{selector} { |e| e == :a }.count"])
    end

    it "allows usage of #{selector}...count with a block on an array" do
      inspect_source("[1, 2, 3].#{selector} { |e| e.odd? }.count { |e| e > 2 }")

      expect(cop.messages).to be_empty
    end

    it "allows usage of #{selector}...count with a block on a hash" do
      source = "{a: 1, b: 2}.#{selector} { |e| e == :a }.count { |e| e > 2 }"
      inspect_source(source)

      expect(cop.messages).to be_empty
    end

    it "registers an offense for #{selector} with params instead of a block" do
      inspect_source(<<-RUBY.strip_indent)
        Data = Struct.new(:value)
        array = [Data.new(2), Data.new(3), Data.new(2)]
        puts array.#{selector}(&:value).count
      RUBY

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...count`."])
      expect(cop.highlights).to eq(["#{selector}(&:value).count"])
    end

    it "registers an offense for #{selector}(&:something).count" do
      inspect_source("foo.#{selector}(&:something).count")

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...count`."])
      expect(cop.highlights).to eq(["#{selector}(&:something).count"])
    end

    it "registers an offense for #{selector}(&:something).count " \
       'when called as an instance method on its own class' do
      source = <<-RUBY.strip_indent
        class A < Array
          def count(&block)
            #{selector}(&block).count
          end
        end
      RUBY
      inspect_source(source)

      expect(cop.messages)
        .to eq(["Use `count` instead of `#{selector}...count`."])
      expect(cop.highlights).to eq(["#{selector}(&block).count"])
    end

    it "allows usage of #{selector} without getting the size" do
      inspect_source("[1, 2, 3].#{selector} { |e| e.even? }")

      expect(cop.messages).to be_empty
    end

    context 'bang methods' do
      it "allows usage of #{selector}!...size" do
        inspect_source("[1, 2, 3].#{selector}! { |e| e.odd? }.size")

        expect(cop.messages).to be_empty
      end

      it "allows usage of #{selector}!...count" do
        inspect_source("[1, 2, 3].#{selector}! { |e| e.odd? }.count")

        expect(cop.messages).to be_empty
      end

      it "allows usage of #{selector}!...length" do
        inspect_source("[1, 2, 3].#{selector}! { |e| e.odd? }.length")

        expect(cop.messages).to be_empty
      end
    end
  end

  it_behaves_like('selectors', 'select')
  it_behaves_like('selectors', 'reject')

  context 'ActiveRecord select' do
    it 'allows usage of select with a string' do
      expect_no_offenses("Model.select('field AS field_one').count")
    end

    it 'allows usage of select with multiple strings' do
      expect_no_offenses(<<-RUBY.strip_indent)
        Model.select('field AS field_one', 'other AS field_two').count
      RUBY
    end

    it 'allows usage of select with a symbol' do
      expect_no_offenses('Model.select(:field).count')
    end

    it 'allows usage of select with multiple symbols' do
      expect_no_offenses('Model.select(:field, :other_field).count')
    end
  end

  it 'allows usage of another method with size' do
    expect_no_offenses('[1, 2, 3].map { |e| e + 1 }.size')
  end

  it 'allows usage of size on an array' do
    expect_no_offenses('[1, 2, 3].size')
  end

  it 'allows usage of count on an array' do
    expect_no_offenses('[1, 2, 3].count')
  end

  it 'allows usage of count on an interstitial method called on select' do
    expect_no_offenses(<<-RUBY.strip_indent)
      Data = Struct.new(:value)
      array = [Data.new(2), Data.new(3), Data.new(2)]
      puts array.select(&:value).uniq.count
    RUBY
  end

  it 'allows usage of count on an interstitial method with blocks ' \
     'called on select' do
    inspect_source(<<-RUBY.strip_indent)
      Data = Struct.new(:value)
      array = [Data.new(2), Data.new(3), Data.new(2)]
      array.select(&:value).uniq { |v| v > 2 }.count
    RUBY

    expect(cop.messages).to be_empty
  end

  it 'allows usage of size called on an assigned variable' do
    expect_no_offenses(<<-RUBY.strip_indent)
      nodes = [1]
      nodes.size
    RUBY
  end

  it 'allows usage of methods called on size' do
    expect_no_offenses('shorter.size.to_f')
  end

  context 'properly parses non related code' do
    it 'will not raise an error for Bundler.setup' do
      expect { inspect_source('Bundler.setup(:default, :development)') }
        .not_to raise_error
    end

    it 'will not raise an error for RakeTask.new' do
      expect { inspect_source('RakeTask.new(:spec)') }
        .not_to raise_error
    end
  end

  context 'autocorrect' do
    context 'will correct' do
      it 'select..size to count' do
        new_source = autocorrect_source(cop, '[1, 2].select { |e| e > 2 }.size')

        expect(new_source).to eq('[1, 2].count { |e| e > 2 }')
      end

      it 'select..count without a block to count' do
        new_source = autocorrect_source(cop,
                                        '[1, 2].select { |e| e > 2 }.count')

        expect(new_source).to eq('[1, 2].count { |e| e > 2 }')
      end

      it 'select..length to count' do
        new_source = autocorrect_source(cop,
                                        '[1, 2].select { |e| e > 2 }.length')

        expect(new_source).to eq('[1, 2].count { |e| e > 2 }')
      end

      it 'select...size when select has parameters' do
        source = <<-RUBY.strip_indent
          Data = Struct.new(:value)
          array = [Data.new(2), Data.new(3), Data.new(2)]
          puts array.select(&:value).size
        RUBY

        new_source = autocorrect_source(cop, source)

        expect(new_source)
          .to eq(<<-RUBY.strip_indent)
            Data = Struct.new(:value)
            array = [Data.new(2), Data.new(3), Data.new(2)]
            puts array.count(&:value)
          RUBY
      end
    end

    describe 'will not correct' do
      it 'reject...size' do
        new_source = autocorrect_source(cop, '[1, 2].reject { |e| e > 2 }.size')

        expect(new_source).to eq('[1, 2].reject { |e| e > 2 }.size')
      end

      it 'reject...count' do
        new_source = autocorrect_source(cop,
                                        '[1, 2].reject { |e| e > 2 }.count')

        expect(new_source).to eq('[1, 2].reject { |e| e > 2 }.count')
      end

      it 'reject...length' do
        new_source = autocorrect_source(cop,
                                        '[1, 2].reject { |e| e > 2 }.length')

        expect(new_source).to eq('[1, 2].reject { |e| e > 2 }.length')
      end

      it 'select...count when count has a block' do
        source = '[1, 2].select { |e| e > 2 }.count { |e| e.even? }'
        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(source)
      end

      it 'reject...size when select has parameters' do
        source = <<-RUBY.strip_indent
          Data = Struct.new(:value)
          array = [Data.new(2), Data.new(3), Data.new(2)]
          puts array.reject(&:value).size
        RUBY

        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq(source)
      end
    end
  end

  context 'SafeMode true' do
    subject(:cop) { described_class.new(config) }

    let(:config) do
      RuboCop::Config.new(
        'Rails' => {
          'Enabled' => true
        },
        'Performance/Count' => {
          'SafeMode' => true
        }
      )
    end

    shared_examples 'selectors' do |selector|
      it "allows using array.#{selector}...size" do
        inspect_source("[1, 2, 3].#{selector} { |e| e.even? }.size")

        expect(cop.offenses).to be_empty
      end
    end

    it_behaves_like('selectors', 'select')
    it_behaves_like('selectors', 'reject')
  end
end
