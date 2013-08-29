# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Cop do
      let(:cop) { Cop.new }
      let(:location) do
        source_buffer = Parser::Source::Buffer.new('test', 1)
        source_buffer.source = "a\n"
        Parser::Source::Range.new(source_buffer, 0, 1)
      end

      it 'initially has 0 offences' do
        expect(cop.offences).to be_empty
      end

      it 'keeps track of offences' do
        cop.convention(nil, location, 'message')

        expect(cop.offences.size).to eq(1)
      end

      it 'will report registered offences' do
        cop.convention(nil, location, 'message')

        expect(cop.offences).not_to be_empty
      end

      it 'registers offence with its name' do
        cop = Style::AvoidFor.new
        cop.convention(nil, location, 'message')
        expect(cop.offences.first.cop_name).to eq('AvoidFor')
      end

      describe 'description' do
        let(:short_desc) { 'abc' }
        let(:long_desc) { short_desc + "\n" + short_desc + 'def' }
        before { Cop.config['Description'] = long_desc }
        context '#full_description' do
          it 'contains whole text' do
            expect(Cop.full_description).to eq(long_desc)
            expect(Cop.full_description.lines.to_a.size).to be > 1
          end
        end
        context '#short_description' do
          it 'contains first line' do
            expect(Cop.short_description).to eq(short_desc)
            expect(Cop.short_description.lines.to_a.size).to eq(1)
          end
        end
      end

      context 'with no submodule' do
        subject(:cop) { Cop }
        it('has right name') { expect(cop.cop_name).to eq('Cop') }
        it('has right type') { expect(cop.cop_type).to eq(:cop) }
      end

      context 'with style cops' do
        subject(:cop) { Style::AvoidFor }
        it('has right name') { expect(cop.cop_name).to eq('AvoidFor') }
        it('has right type') { expect(cop.cop_type).to eq(:style) }
      end

      context 'with lint cops' do
        subject(:cop) { Lint::Loop }
        it('has right name') { expect(cop.cop_name).to eq('Loop') }
        it('has right type') { expect(cop.cop_type).to eq(:lint) }
      end

      context 'with rails cops' do
        subject(:cop) { Rails::Validation }
        it('has right name') { expect(cop.cop_name).to eq('Validation') }
        it('has right type') { expect(cop.cop_type).to eq(:rails) }
      end

      describe 'CopStore' do
        context '#types' do
          subject { Rubocop::Cop::Cop.all.types }
          it('has types') { expect(subject.length).not_to eq(0) }
          it { should include :lint }
          it do
            pending 'Rails cops are usually removed after CLI start, ' +
                    'so CLI spec impacts this one'
            should include :rails
          end
          it { should include :style }
          it 'contains every value only once' do
            expect(subject.length).to eq(subject.uniq.length)
          end
        end
        context '#with_type' do
          let(:types) { Rubocop::Cop::Cop.all.types }
          it 'has at least one cop per type' do
            types.each do |c|
              expect(Rubocop::Cop::Cop.all.with_type(c).length).to be > 0
            end
          end

          it 'has each cop in exactly one type' do
            sum = 0
            types.each do |c|
              sum = sum + Rubocop::Cop::Cop.all.with_type(c).length
            end
            expect(sum).to be Rubocop::Cop::Cop.all.length
          end

          it 'returns 0 for an invalid type' do
            expect(Rubocop::Cop::Cop.all.with_type('x').length).to be 0
          end
        end
      end

    end
  end
end
