# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::TimeZone, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is "strict"' do
    let(:cop_config) { { 'EnforcedStyle' => 'strict' } }

    described_class::TIMECLASS.each do |klass|
      it "registers an offense for #{klass}.now" do
        inspect_source("#{klass}.now")
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to include('`Time.zone.now`')
      end

      it "registers an offense for #{klass}.current" do
        inspect_source("#{klass}.current")
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to include('`Time.zone.now`')
      end

      it "registers an offense for #{klass}.new without argument" do
        inspect_source("#{klass}.new")
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to include('`Time.zone.now`')
      end

      it "registers an offense for #{klass}.new with argument" do
        inspect_source("#{klass}.new(2012, 6, 10, 12, 00)")
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to include('`Time.zone.local`')
      end

      it 'does not register an offense when a .new method is made
        independently of the Time class' do
        inspect_source('Range.new(1,
                                  Time.days_in_month(date.month, date.year))')
        expect(cop.offenses.empty?).to be(true)
      end

      it "does not register an offense for #{klass}.new with zone argument" do
        inspect_source("#{klass}.new(1988, 3, 15, 3, 0, 0, '-05:00')")
        expect(cop.offenses.empty?).to be(true)
      end

      it "registers an offense for ::#{klass}.now" do
        inspect_source("::#{klass}.now")
        expect(cop.offenses.size).to eq(1)
      end

      it "accepts Some::#{klass}.now" do
        inspect_source("Some::#{klass}.forward(0).strftime('%H:%M')")
        expect(cop.offenses.empty?).to be(true)
      end

      described_class::ACCEPTED_METHODS.each do |a_method|
        it "registers an offense #{klass}.now.#{a_method}" do
          inspect_source("#{klass}.now.#{a_method}")
          expect(cop.offenses.size).to eq(1)
        end
      end
    end

    it 'registers an offense for Time.parse' do
      expect_offense(<<-RUBY.strip_indent)
        Time.parse("2012-03-02 16:05:37")
             ^^^^^ Do not use `Time.parse` without zone. Use `Time.zone.parse` instead.
      RUBY
    end

    it 'registers an offense for Time.strftime' do
      expect_offense(<<-RUBY.strip_indent)
        Time.strftime(time_string, "%Y-%m-%dT%H:%M:%S%z")
             ^^^^^^^^ Do not use `Time.strftime` without zone. Use `Time.zone.strftime` instead.
      RUBY
    end

    it 'registers an offense for Time.strftime.in_time_zone' do
      expect_offense(<<-RUBY.strip_indent)
        Time.strftime(time_string, "%Y-%m-%dT%H:%M:%S%z").in_time_zone
             ^^^^^^^^ Do not use `Time.strftime` without zone. Use `Time.zone.strftime` instead.
      RUBY
    end

    it 'registers an offense for Time.strftime with nested Time.zone' do
      expect_offense(<<-RUBY.strip_indent)
        Time.strftime(Time.zone.now.to_s, "%Y-%m-%dT%H:%M:%S%z")
             ^^^^^^^^ Do not use `Time.strftime` without zone. Use `Time.zone.strftime` instead.
      RUBY
    end

    it 'registers an offense for Time.zone.strftime with nested Time.now' do
      expect_offense(<<-RUBY.strip_indent)
        Time.zone.strftime(Time.now.to_s, "%Y-%m-%dT%H:%M:%S%z")
                                ^^^ Do not use `Time.now.strftime` without zone. Use `Time.zone.now.strftime` instead.
      RUBY
    end

    it 'registers an offense for Time.at' do
      expect_offense(<<-RUBY.strip_indent)
        Time.at(ts)
             ^^ Do not use `Time.at` without zone. Use `Time.zone.at` instead.
      RUBY
    end

    it 'registers an offense for Time.at.in_time_zone' do
      expect_offense(<<-RUBY.strip_indent)
        Time.at(ts).in_time_zone
             ^^ Do not use `Time.at` without zone. Use `Time.zone.at` instead.
      RUBY
    end

    it 'registers an offense for Time.parse.localtime(offset)' do
      expect_offense(<<-RUBY.strip_indent)
        Time.parse('12:00').localtime('+03:00')
             ^^^^^ Do not use `Time.parse` without zone. Use `Time.zone.parse` instead.
      RUBY
    end

    it 'registers an offense for Time.parse.localtime' do
      expect_offense(<<-RUBY.strip_indent)
        Time.parse('12:00').localtime
             ^^^^^ Do not use `Time.parse` without zone. Use `Time.zone.parse` instead.
      RUBY
    end

    it 'registers an offense for Time.parse in return' do
      expect_offense(<<-RUBY.strip_indent)
        return Foo, Time.parse("2012-03-02 16:05:37")
                         ^^^^^ Do not use `Time.parse` without zone. Use `Time.zone.parse` instead.
      RUBY
    end

    it 'accepts Time.zone.now' do
      expect_no_offenses('Time.zone.now')
    end

    it 'accepts Time.zone.today' do
      expect_no_offenses('Time.zone.today')
    end

    it 'accepts Time.zone.local' do
      expect_no_offenses('Time.zone.local(2012, 6, 10, 12, 00)')
    end

    it 'accepts Time.zone.parse' do
      expect_no_offenses('Time.zone.parse("2012-03-02 16:05:37")')
    end

    it 'accepts Time.zone.at' do
      expect_no_offenses('Time.zone.at(ts)')
    end

    it 'accepts Time.strptime' do
      expect_no_offenses('Time.strptime(datetime, format).in_time_zone')
    end

    it 'accepts Time.zone.strftime' do
      expect_no_offenses(
        'Time.zone.strftime(time_string, "%Y-%m-%dT%H:%M:%S%z")'
      )
    end

    it 'accepts Time.zone.parse.localtime' do
      expect_no_offenses("Time.zone.parse('12:00').localtime")
    end

    it 'accepts Time.zone.parse.localtime(offset)' do
      expect_no_offenses("Time.zone.parse('12:00').localtime('+03:00')")
    end

    it 'accepts Time.zone_default.now' do
      expect_no_offenses('Time.zone_default.now')
    end

    it 'accepts Time.zone_default.today' do
      expect_no_offenses('Time.zone_default.today')
    end

    it 'accepts Time.zone_default.local' do
      expect_no_offenses('Time.zone_default.local(2012, 6, 10, 12, 00)')
    end

    it 'accepts Time.find_zone(time_zone).now' do
      expect_no_offenses("Time.find_zone('EST').now")
    end

    it 'accepts Time.find_zone(time_zone).today' do
      expect_no_offenses("Time.find_zone('EST').today")
    end

    it 'accepts Time.find_zone(time_zone).local' do
      expect_no_offenses("Time.find_zone('EST').local(2012, 6, 10, 12, 00)")
    end

    it 'accepts Time.find_zone!(time_zone).now' do
      expect_no_offenses("Time.find_zone!('EST').now")
    end

    it 'accepts Time.find_zone!(time_zone).today' do
      expect_no_offenses("Time.find_zone!('EST').today")
    end

    it 'accepts Time.find_zone!(time_zone).local' do
      expect_no_offenses("Time.find_zone!('EST').local(2012, 6, 10, 12, 00)")
    end

    described_class::DANGEROUS_METHODS.each do |a_method|
      it "accepts Some::Time.#{a_method}" do
        inspect_source("Some::Time.#{a_method}")
        expect(cop.offenses.empty?).to be(true)
      end
    end
  end

  context 'when EnforcedStyle is "flexible"' do
    let(:cop_config) { { 'EnforcedStyle' => 'flexible' } }

    described_class::TIMECLASS.each do |klass|
      it "registers an offense for #{klass}.now" do
        inspect_source("#{klass}.now")
        expect(cop.offenses.size).to eq(1)

        expect(cop.offenses.first.message).to include('Use one of')
        expect(cop.offenses.first.message).to include('`Time.zone.now`')
        expect(cop.offenses.first.message).to include("`#{klass}.current`")

        described_class::ACCEPTED_METHODS.each do |a_method|
          expect(cop.offenses.first.message)
            .to include("#{klass}.now.#{a_method}")
        end
      end

      it "accepts #{klass}.current" do
        inspect_source("#{klass}.current")
        expect(cop.offenses.empty?).to be(true)
      end

      described_class::ACCEPTED_METHODS.each do |a_method|
        it "accepts #{klass}.now.#{a_method}" do
          inspect_source("#{klass}.now.#{a_method}")
          expect(cop.offenses.empty?).to be(true)
        end
      end

      it "accepts #{klass}.zone.now" do
        inspect_source("#{klass}.zone.now")
        expect(cop.offenses.empty?).to be(true)
      end

      it "accepts #{klass}.zone_default.now" do
        inspect_source("#{klass}.zone_default.now")
        expect(cop.offenses.empty?).to be(true)
      end

      it "accepts #{klass}.find_zone(time_zone).now" do
        inspect_source("#{klass}.find_zone('EST').now")
        expect(cop.offenses.empty?).to be(true)
      end

      it "accepts #{klass}.find_zone!(time_zone).now" do
        inspect_source("#{klass}.find_zone!('EST').now")
        expect(cop.offenses.empty?).to be(true)
      end

      described_class::DANGEROUS_METHODS.each do |a_method|
        it "accepts #{klass}.current.#{a_method}" do
          inspect_source("#{klass}.current.#{a_method}")
          expect(cop.offenses.empty?).to be(true)
        end
      end
    end

    it 'accepts Time.strftime.in_time_zone' do
      expect_no_offenses(
        'Time.strftime(time_string, "%Y-%m-%dT%H:%M:%S%z").in_time_zone'
      )
    end

    it 'accepts Time.parse.localtime(offset)' do
      expect_no_offenses("Time.parse('12:00').localtime('+03:00')")
    end

    it 'does not blow up in the presence of a single constant to inspect' do
      expect_no_offenses('A')
    end
  end
end
