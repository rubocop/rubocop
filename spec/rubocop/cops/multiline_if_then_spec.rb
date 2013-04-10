# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe MultilineIfThen do
      let(:mit) { MultilineIfThen.new }

      # if

      it 'registers an offence for then in multiline if' do
        inspect_source(mit, '', ['if cond then',
                                 'end',
                                 "if cond then\t",
                                 'end',
                                 'if cond then  ',
                                 'end',
                                 'if cond then # bad',
                                 'end'])
        expect(mit.offences.map(&:line_number)).to eq([1, 3, 5, 7])
      end

      it 'accepts multiline if without then' do
        inspect_source(mit, '', ['if cond',
                                          'end'])
        expect(mit.offences.map(&:message)).to be_empty
      end

      it 'accepts table style if/then/elsif/ends' do
        inspect_source(mit, '',
                       ['if    @io == $stdout then str << "$stdout"',
                        'elsif @io == $stdin  then str << "$stdin"',
                        'elsif @io == $stderr then str << "$stderr"',
                        'else                      str << @io.class.to_s',
                        'end'])
        expect(mit.offences.map(&:message)).to be_empty
      end

      # unless

      it 'registers an offence for then in multiline unless' do
        inspect_source(mit, '', ['unless cond then',
                                 'end'])
        expect(mit.offences.map(&:message)).to eq(
          ['Never use then for multi-line if/unless.'])
      end

      it 'accepts multiline unless without then' do
        inspect_source(mit, '', ['unless cond',
                                 'end'])
        expect(mit.offences.map(&:message)).to be_empty
      end
    end
  end
end
