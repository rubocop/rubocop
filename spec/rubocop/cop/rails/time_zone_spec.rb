# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Rails::TimeZone, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is "always"' do
    let(:cop_config) { { 'EnforcedStyle' => 'always' } }

    described_class::TIMECLASS.each do |klass|
      it "registers an offense for #{klass}.now" do
        inspect_source(cop, "#{klass}.now")
        expect(cop.offenses.size).to eq(1)
      end

      it "registers an offense for #{klass}.new without argument" do
        inspect_source(cop, "#{klass}.new")
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to include('Time.zone.now')
      end

      it "registers an offense for #{klass}.new with argument" do
        inspect_source(cop, "#{klass}.new(2012, 6, 10, 12, 00)")
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to include('Time.zone.local')
      end

      described_class::ACCEPTED_METHODS.each do |a_method|
        it "registers an offense #{klass}.now.#{a_method}" do
          inspect_source(cop, "#{klass}.now.#{a_method}")
          expect(cop.offenses.size).to eq(1)
        end
      end
    end

    it 'registers an offense for Time.parse' do
      inspect_source(cop, 'Time.parse("2012-03-02 16:05:37")')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for Time.strftime' do
      inspect_source(cop, 'Time.strftime(time_string, "%Y-%m-%dT%H:%M:%S%z")')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for Time.strftime.in_time_zone' do
      inspect_source(
        cop,
        'Time.strftime(time_string, "%Y-%m-%dT%H:%M:%S%z").in_time_zone'
      )
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for Time.strftime with nested Time.zone' do
      inspect_source(
        cop,
        'Time.strftime(Time.zone.now.to_s, "%Y-%m-%dT%H:%M:%S%z")'
      )
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for Time.zone.strftime with nested Time.now' do
      inspect_source(
        cop,
        'Time.zone.strftime(Time.now.to_s, "%Y-%m-%dT%H:%M:%S%z")'
      )
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for Time.at' do
      inspect_source(cop, 'Time.at(ts)')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for Time.at.in_time_zone' do
      inspect_source(cop, 'Time.at(ts).in_time_zone')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for Time.parse.localtime(offset)' do
      inspect_source(cop, "Time.parse('12:00').localtime('+03:00')")
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for Time.parse.localtime' do
      inspect_source(cop, "Time.parse('12:00').localtime")
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts Time.zone.now' do
      inspect_source(cop, 'Time.zone.now')
      expect(cop.offenses).to be_empty
    end

    it 'accepts Time.zone.today' do
      inspect_source(cop, 'Time.zone.today')
      expect(cop.offenses).to be_empty
    end

    it 'accepts Time.zone.local' do
      inspect_source(cop, 'Time.zone.local(2012, 6, 10, 12, 00)')
      expect(cop.offenses).to be_empty
    end

    it 'accepts Time.zone.parse' do
      inspect_source(cop, 'Time.zone.parse("2012-03-02 16:05:37")')
      expect(cop.offenses).to be_empty
    end

    it 'accepts Time.zone.at' do
      inspect_source(cop, 'Time.zone.at(ts)')
      expect(cop.offenses).to be_empty
    end

    it 'accepts Time.strptime' do
      inspect_source(cop, 'Time.strptime(datetime, format).in_time_zone')
      expect(cop.offenses).to be_empty
    end

    it 'accepts Time.zone.strftime' do
      inspect_source(
        cop,
        'Time.zone.strftime(time_string, "%Y-%m-%dT%H:%M:%S%z")'
      )
      expect(cop.offenses).to be_empty
    end

    it 'accepts Time.zone.parse.localtime' do
      inspect_source(cop, "Time.zone.parse('12:00').localtime")
      expect(cop.offenses).to be_empty
    end

    it 'accepts Time.zone.parse.localtime(offset)' do
      inspect_source(cop, "Time.zone.parse('12:00').localtime('+03:00')")
      expect(cop.offenses).to be_empty
    end
  end

  context 'when EnforcedStyle is "acceptable"' do
    let(:cop_config) { { 'EnforcedStyle' => 'acceptable' } }

    described_class::TIMECLASS.each do |klass|
      it "registers an offense for #{klass}.now" do
        inspect_source(cop, "#{klass}.now")
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to include('Use one of')

        described_class::ACCEPTED_METHODS.each do |a_method|
          expect(cop.offenses.first.message)
            .to include("#{klass}.now.#{a_method}")
        end
      end

      described_class::ACCEPTED_METHODS.each do |a_method|
        it "accepts #{klass}.now.#{a_method}" do
          inspect_source(cop, "#{klass}.now.#{a_method}")
          expect(cop.offenses).to be_empty
        end
      end
    end

    it 'accepts Time.strftime.in_time_zone' do
      inspect_source(
        cop,
        'Time.strftime(time_string, "%Y-%m-%dT%H:%M:%S%z").in_time_zone'
      )
      expect(cop.offenses).to be_empty
    end

    it 'accepts Time.parse.localtime(offset)' do
      inspect_source(cop, "Time.parse('12:00').localtime('+03:00')")
      expect(cop.offenses).to be_empty
    end
  end
end
