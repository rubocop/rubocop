# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe MultilineIfThen do
        let(:mit) { MultilineIfThen.new }

        # if

        it 'registers an offence for then in multiline if' do
          inspect_source(mit, ['if cond then',
                               'end',
                               "if cond then\t",
                               'end',
                               'if cond then  ',
                               'end',
                               'if cond',
                               'then',
                               'end',
                               'if cond then # bad',
                               'end'])
          expect(mit.offences.map(&:line)).to eq([1, 3, 5, 7, 10])
        end

        it 'accepts multiline if without then' do
          inspect_source(mit, ['if cond',
                               'end'])
          expect(mit.offences).to be_empty
        end

        it 'accepts table style if/then/elsif/ends' do
          inspect_source(mit,
                         ['if    @io == $stdout then str << "$stdout"',
                          'elsif @io == $stdin  then str << "$stdin"',
                          'elsif @io == $stderr then str << "$stderr"',
                          'else                      str << @io.class.to_s',
                          'end'])
          expect(mit.offences).to be_empty
        end

        it 'does not get confused by a then in a when' do
          inspect_source(mit,
                         ['if a',
                          '  case b',
                          '  when c then',
                          '  end',
                          'end'])
          expect(mit.offences).to be_empty
        end

        it 'does not get confused by a commented-out then' do
          inspect_source(mit,
                         ['if a # then',
                          '  b',
                          'end',
                          'if c # then',
                          'end'])
          expect(mit.offences).to be_empty
        end

        # unless

        it 'registers an offence for then in multiline unless' do
          inspect_source(mit, ['unless cond then',
                               'end'])
          expect(mit.offences.map(&:message)).to eq(
            ['Never use then for multi-line if/unless.'])
        end

        it 'accepts multiline unless without then' do
          inspect_source(mit, ['unless cond',
                               'end'])
          expect(mit.offences).to be_empty
        end

        it 'does not get confused by a postfix unless' do
          inspect_source(mit,
                         ['two unless one',
                         ])
          expect(mit.offences).to be_empty
        end

        it 'does not get confused by a nested postfix unless' do
          inspect_source(mit,
                         ['if two',
                          '  puts 1',
                          'end unless two'
                         ])
          expect(mit.offences).to be_empty
        end
      end
    end
  end
end
