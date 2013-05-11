# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SpaceAroundOperators do
      let(:space) { SpaceAroundOperators.new }

      it 'registers an offence for assignment without space on both sides' do
        inspect_source(space, 'file.rb', ['x=0', 'y= 0', 'z =0'])
        expect(space.offences.map(&:message)).to eq(
          ["Surrounding space missing for operator '='."] * 3)
      end

      it 'registers an offence for ternary operator without space' do
        inspect_source(space, 'file.rb', ['x == 0?1:2'])
        expect(space.offences.map(&:message)).to eq(
          ["Surrounding space missing for operator '?'.",
           "Surrounding space missing for operator ':'."])
      end

      it 'registers an offence in presence of modifier if statement' do
        check_modifier('if')
      end

      it 'registers an offence in presence of modifier unless statement' do
        check_modifier('unless')
      end

      it 'registers an offence in presence of modifier while statement' do
        check_modifier('unless')
      end

      it 'registers an offence in presence of modifier until statement' do
        check_modifier('unless')
      end

      def check_modifier(keyword)
        src = ["a=1 #{keyword} condition",
               'c=2']
        inspect_source(space, 'file.rb', src)
        expect(space.offences.map(&:line_number)).to eq([1, 2])
        expect(space.offences.map(&:message)).to eq(
          ["Surrounding space missing for operator '='."] * 2)
      end

      it 'registers an offence for binary operators that could be unary' do
        inspect_source(space, 'file.rb', ['a-3', 'x&0xff', 'z+0'])
        expect(space.offences.map(&:message)).to eq(
          ["Surrounding space missing for operator '-'.",
           "Surrounding space missing for operator '&'.",
           "Surrounding space missing for operator '+'."])
      end

      it 'registers an offence for arguments to a method' do
        inspect_source(space, 'file.rb', ['puts 1+2'])
        expect(space.offences.map(&:message)).to eq(
          ["Surrounding space missing for operator '+'."])
      end

      it 'accepts operator symbols' do
        inspect_source(space, 'file.rb', ['func(:-)'])
        expect(space.offences.map(&:message)).to be_empty
      end

      it 'accepts ranges' do
        inspect_source(space, 'file.rb', ['a, b = (1..2), (1...3)'])
        expect(space.offences.map(&:message)).to be_empty
      end

      it 'accepts scope operator' do
        source = ['@io.class == Zlib::GzipWriter']
        inspect_source(space, 'file.rb', source)
        expect(space.offences.map(&:message)).to be_empty
      end

      it 'accepts ::Kernel::raise' do
        source = ['::Kernel::raise IllegalBlockError.new']
        inspect_source(space, 'file.rb', source)
        expect(space.offences.map(&:message)).to be_empty
      end

      it 'accepts exclamation point negation' do
        inspect_source(space, 'file.rb', ['x = !a&&!b'])
        expect(space.offences.map(&:message)).to eq(
          ["Surrounding space missing for operator '&&'."])
      end

      it 'accepts exclamation point definition' do
        inspect_source(space, 'file.rb', ['  def !',
                                         '    !__getobj__',
                                         '  end'])
        expect(space.offences).to be_empty
        expect(space.offences.map(&:message)).to be_empty
      end

      it 'accepts a unary' do
        inspect_source(space, 'file.rb',
                       ['  def bm(label_width = 0, *labels, &blk)',
                        '    benchmark(CAPTION, label_width, FORMAT,',
                        '              *labels, &blk)',
                        '  end',
                        ''])
        expect(space.offences.map(&:message)).to be_empty
      end

      it 'accepts splat operator' do
        inspect_source(space, 'file.rb', ['return *list if options'])
        expect(space.offences.map(&:message)).to be_empty
      end

      it 'accepts def of operator' do
        inspect_source(space, 'file.rb', ['def +(other); end'])
        expect(space.offences.map(&:message)).to be_empty
      end

      it 'accepts an assignment with spaces' do
        inspect_source(space, 'file.rb', ['x = 0'])
        expect(space.offences).to be_empty
      end

      it "accepts some operators that are exceptions and don't need spaces" do
        inspect_source(space, 'file.rb', ['(1..3)',
                                         'ActionController::Base',
                                         'each { |s, t| }'])
        expect(space.offences.map(&:message)).to be_empty
      end

      it 'accepts an assignment followed by newline' do
        inspect_source(space, 'file.rb', ['x =', '0'])
        expect(space.offences).to be_empty
      end

      it 'registers an offences for exponent operator with spaces' do
        inspect_source(space, 'file.rb', ['x = a * b ** 2'])
        expect(space.offences.map(&:message)).to eq(
          ['Space around operator ** detected.'])
      end

      it 'accepts exponent operator without spaces' do
        inspect_source(space, 'file.rb', ['x = a * b**2'])
        expect(space.offences).to be_empty
      end

      it 'accepts unary operators without space' do
        inspect_source(space, 'file.rb', ['[].map(&:size)',
                                         '-3',
                                         'x = +2'])
        expect(space.offences.map(&:message)).to be_empty
      end
    end
  end
end
