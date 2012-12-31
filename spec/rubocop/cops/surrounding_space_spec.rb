# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SurroundingSpace do
      let (:space) { SurroundingSpace.new }

      it 'registers an offence for assignment without space on both sides' do
        inspect_source(space, 'file.rb', ['x=0', 'y= 0', 'z =0'])
        space.offences.size.should == 3
        space.offences.first.message.should ==
          "Surrounding space missing for operator '='."
      end

      it 'registers an offence for binary operators that could be unary' do
        inspect_source(space, 'file.rb', ['a-3', 'x&0xff', 'z+0'])
        space.offences.map(&:message).should ==
          ["Surrounding space missing for operator '-'.",
           "Surrounding space missing for operator '&'.",
           "Surrounding space missing for operator '+'."]
      end

      it 'registers an offence for left brace without spaces' do
        inspect_source(space, 'file.rb', ['each{ puts }'])
        space.offences.map(&:message).should ==
          ["Surrounding space missing for '{'."]
      end

      it 'registers an offence for right brace without inner space' do
        inspect_source(space, 'file.rb', ['each { puts}'])
        space.offences.map(&:message).should ==
          ["Space missing to the left of '}'."]
      end

      it 'accepts an empty hash literal with no space inside' do
        inspect_source(space, 'file.rb',
                       ['view_hash.each do |view_key|',
                        'end',
                        '@views = {}',
                        ''])
        space.offences.map(&:message).should == []
      end

      it 'registers an offence for arguments to a method' do
        inspect_source(space, 'file.rb', ['puts 1+2'])
        space.offences.map(&:message).should ==
          ["Surrounding space missing for operator '+'."]
      end

      it 'registers an offence for an array literal with spaces inside' do
        inspect_source(space, 'file.rb', ['a = [1, 2 ]',
                                         'b = [ 1, 2]'])
        space.offences.map(&:message).should ==
          ['Space inside square brackets detected.',
           'Space inside square brackets detected.']
      end

      it 'accepts space inside square brackets if on its own row' do
        inspect_source(space, 'file.rb', ['a = [',
                                         '     1, 2',
                                         '    ]'])
        space.offences.map(&:message).should == []
      end

      it 'registers an offence for spaces inside parens' do
        inspect_source(space, 'file.rb', ['f( 3)',
                                         'g(3 )'])
        space.offences.map(&:message).should ==
          ['Space inside parentheses detected.',
           'Space inside parentheses detected.']
      end

      it 'accepts parentheses in block parameter list' do
        inspect_source(space, 'file.rb',
                       ['list.inject(Tms.new) { |sum, (label, item)|',
                        '}'])
        space.offences.map(&:message).should == []
      end

      it 'accepts operator symbols' do
        inspect_source(space, 'file.rb', ['func(:-)'])
        space.offences.map(&:message).should == []
      end

      it 'accepts ranges' do
        inspect_source(space, 'file.rb', ['a, b = (1..2), (1...3)'])
        space.offences.map(&:message).should == []
      end

      it 'accepts scope operator' do
        source = ['@io.class == Zlib::GzipWriter']
        inspect_source(space, 'file.rb', source)
        space.offences.map(&:message).should == []
      end

      it 'accepts ::Kernel::raise' do
        source = ['::Kernel::raise IllegalBlockError.new']
        inspect_source(space, 'file.rb', source)
        space.offences.map(&:message).should == []
      end

      it 'accepts exclamation point negation' do
        inspect_source(space, 'file.rb', ['x = !a&&!b'])
        space.offences.map(&:message).should ==
          ["Surrounding space missing for operator '&&'."]
      end

      it 'accepts exclamation point definition' do
        inspect_source(space, 'file.rb', ['  def !',
                                         '    !__getobj__',
                                         '  end'])
        space.offences.should == []
        space.offences.map(&:message).should == []
      end

      it 'accepts a unary' do
        inspect_source(space, 'file.rb',
                       ['  def bm(label_width = 0, *labels, &blk)',
                        '    benchmark(CAPTION, label_width, FORMAT,',
                        '              *labels, &blk)',
                        '  end',
                        ''])
        space.offences.map(&:message).should == []
      end

      it 'accepts splat operator' do
        inspect_source(space, 'file.rb', ['return *list if options'])
        space.offences.map(&:message).should == []
      end

      it 'accepts square brackets as method name' do
        inspect_source(space, 'file.rb', ['def Vector.[](*array)',
                                         'end'])
        space.offences.map(&:message).should == []
      end

      it 'accepts def of operator' do
        inspect_source(space, 'file.rb', ['def +(other); end'])
        space.offences.map(&:message).should == []
      end

      it 'accepts an assignment with spaces' do
        inspect_source(space, 'file.rb', ['x = 0'])
        space.offences.size.should == 0
      end

      it "accepts some operators that are exceptions and don't need spaces" do
        inspect_source(space, 'file.rb', ['(1..3)',
                                         'ActionController::Base',
                                         'each { |s, t| }'])
        space.offences.map(&:message).should == []
      end

      it 'accepts an assignment followed by newline' do
        inspect_source(space, 'file.rb', ['x =\n  0'])
        space.offences.size.should == 0
      end

      it 'registers an offences for exponent operator with spaces' do
        inspect_source(space, 'file.rb', ['x = a * b ** 2'])
        space.offences.map(&:message).should ==
          ["Space around operator ** detected."]
      end

      it 'accepts exponent operator without spaces' do
        inspect_source(space, 'file.rb', ['x = a * b**2'])
        space.offences.size.should == 0
      end

      it 'accepts unary operators without space' do
        inspect_source(space, 'file.rb', ['[].map(&:size)',
                                         '-3',
                                         'x = +2'])
        space.offences.map(&:message).should == []
      end

      it 'accepts square brackets called with method call syntax' do
        inspect_source(space, 'file.rb', ['subject.[](0)'])
        space.offences.map(&:message).should == []
      end

      it 'only reports a single space once' do
        inspect_source(space, 'file.rb', ['[ ]'])
        space.offences.map(&:message).should ==
          ['Space inside square brackets detected.']
      end
    end
  end
end
