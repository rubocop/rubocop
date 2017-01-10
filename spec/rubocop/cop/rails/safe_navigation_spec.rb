# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::SafeNavigation, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples :accepts do |name, code|
    it "accepts usages of #{name}" do
      inspect_source(cop, "[1, 2].#{code}")

      expect(cop.offenses).to be_empty
    end
  end

  shared_examples :offense do |name, method, params|
    it "registers an offense for #{name}" do
      inspect_source(cop, "[1, 2].#{method}#{params}")

      expect(cop.messages)
        .to eq([format('Use safe navigation (`&.`) instead of `%s`.', method)])
    end
  end

  shared_examples :autocorrect do |name, source, correction|
    it "corrects #{name}" do
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(correction)
    end
  end

  context 'only convert try!' do
    let(:cop_config) { { 'ConvertTry' => false } }

    it_behaves_like :accepts, 'non try! method calls', 'join'

    context 'target_ruby_version < 2.3', :ruby19 do
      it_behaves_like :accepts, 'try! with a single parameter', 'try!(:join)'
      it_behaves_like :accepts, 'try! with a multiple parameters',
                      'try!(:join, ",")'
      it_behaves_like :accepts, 'try! with a block',
                      'try!(:map) { |e| e.some_method }'
      it_behaves_like :accepts, 'try! with params and a block',
                      ['try!(:each_with_object, []) do |e, acc|',
                       '  acc << e.some_method',
                       'end'].join("\n")
    end

    context 'target_ruby_version > 2.3', :ruby23 do
      context 'try!' do
        it_behaves_like :offense, 'try! with a single parameter', 'try!',
                        '(:join)'
        it_behaves_like :offense, 'try! with a multiple parameters', 'try!',
                        '(:join, ",")'
        it_behaves_like :offense, 'try! with a block', 'try!',
                        '(:map) { |e| e.some_method }'
        it_behaves_like :offense, 'try! with params and a block', 'try!',
                        ['(:each_with_object, []) do |e, acc|',
                         '  acc << e.some_method',
                         'end'].join("\n")
        it_behaves_like :offense, 'try! with a question method', 'try!',
                        '(:something?)'
        it_behaves_like :offense, 'try! with a bang method', 'try!',
                        '(:something!)'

        it_behaves_like :accepts, 'try! used to call an enumerable accessor',
                        'foo.try!(:[], :bar)'
        it_behaves_like :accepts, 'try! with ==', 'foo.try!(:==, bar)'
        it_behaves_like :accepts, 'try! with an operator', 'foo.try!(:+, bar)'
        it_behaves_like :accepts, 'try! with a method stored as a variable',
                        ['bar = :==',
                         'foo.try!(baz, bar)'].join("\n")

        it 'accepts usages of try! without receiver' do
          inspect_source(cop, 'try!(:something)')

          expect(cop.offenses).to be_empty
        end
      end

      context 'try' do
        it_behaves_like :accepts, 'try with a single parameter', 'try(:join)'
        it_behaves_like :accepts, 'try with a multiple parameters',
                        'try(:join, ",")'
        it_behaves_like :accepts, 'try with a block',
                        'try(:map) { |e| e.some_method }'
        it_behaves_like :accepts, 'try with params and a block',
                        ['try(:each_with_object, []) do |e, acc|',
                         '  acc << e.some_method',
                         'end'].join("\n")
      end

      it_behaves_like :autocorrect, 'try! a single parameter',
                      'foo.try!(:thing=, bar)', 'foo&.thing = bar'
      it_behaves_like :autocorrect, 'try! a single parameter',
                      '[1, 2].try!(:join)', '[1, 2]&.join'
      it_behaves_like :autocorrect, 'try! with 2 parameters',
                      '[1, 2].try!(:join, ",")', '[1, 2]&.join(",")'
      it_behaves_like :autocorrect, 'try! with multiple parameters',
                      '[1, 2].try!(:join, bar, baz)', '[1, 2]&.join(bar, baz)'
      it_behaves_like :autocorrect, 'try! with a block',
                      ['[foo, bar].try!(:map) do |e|',
                       '  e.some_method',
                       'end'].join("\n"),
                      ['[foo, bar]&.map do |e|',
                       '  e.some_method',
                       'end'].join("\n")
      it_behaves_like :autocorrect, 'try! with params and a block',
                      ['[foo, bar].try!(:each_with_object, []) do |e, acc|',
                       '  acc << e.some_method',
                       'end'].join("\n"),
                      ['[foo, bar]&.each_with_object([]) do |e, acc|',
                       '  acc << e.some_method',
                       'end'].join("\n")
    end
  end

  context 'convert try and try!' do
    let(:cop_config) { { 'ConvertTry' => true } }

    context 'target_ruby_version < 2.3', :ruby19 do
      it_behaves_like :accepts, 'try! with a single parameter', 'try!(:join)'
      it_behaves_like :accepts, 'try! with a multiple parameters',
                      'try!(:join, ",")'
      it_behaves_like :accepts, 'try! with a block',
                      'try!(:map) { |e| e.some_method }'
      it_behaves_like :accepts, 'try! with params and a block',
                      ['try!(:each_with_object, []) do |e, acc|',
                       '  acc << e.some_method',
                       'end'].join("\n")
    end

    context 'target_ruby_version > 2.3', :ruby23 do
      context 'try!' do
        it_behaves_like :offense, 'try! with a single parameter', 'try!',
                        '(:join)'
        it_behaves_like :offense, 'try! with a multiple parameters', 'try!',
                        '(:join, ",")'
        it_behaves_like :offense, 'try! with a block', 'try!',
                        '(:map) { |e| e.some_method }'
        it_behaves_like :offense, 'try! with params and a block', 'try!',
                        ['(:each_with_object, []) do |e, acc|',
                         '  acc << e.some_method',
                         'end'].join("\n")

        it_behaves_like :accepts, 'try! used to call an enumerable accessor',
                        'foo.try!(:[], :bar)'

        it_behaves_like :autocorrect, 'try! a single parameter',
                        '[1, 2].try!(:join)', '[1, 2]&.join'
        it_behaves_like :autocorrect, 'try! with 2 parameters',
                        '[1, 2].try!(:join, ",")', '[1, 2]&.join(",")'
        it_behaves_like :autocorrect, 'try! with multiple parameters',
                        '[1, 2].try!(:join, bar, baz)', '[1, 2]&.join(bar, baz)'
        it_behaves_like :autocorrect, 'try! with a block',
                        ['[foo, bar].try!(:map) do |e|',
                         '  e.some_method',
                         'end'].join("\n"),
                        ['[foo, bar]&.map do |e|',
                         '  e.some_method',
                         'end'].join("\n")
        it_behaves_like :autocorrect, 'try! with params and a block',
                        ['[foo, bar].try!(:each_with_object, []) do |e, acc|',
                         '  acc << e.some_method',
                         'end'].join("\n"),
                        ['[foo, bar]&.each_with_object([]) do |e, acc|',
                         '  acc << e.some_method',
                         'end'].join("\n")
      end

      context 'try' do
        it_behaves_like :offense, 'try with a single parameter', 'try',
                        '(:join)'
        it_behaves_like :offense, 'try with a multiple parameters', 'try',
                        '(:join, ",")'
        it_behaves_like :offense, 'try with a block', 'try',
                        '(:map) { |e| e.some_method }'
        it_behaves_like :offense, 'try with params and a block', 'try',
                        ['(:each_with_object, []) do |e, acc|',
                         '  acc << e.some_method',
                         'end'].join("\n")

        it_behaves_like :accepts, 'try! used to call an enumerable accessor',
                        'foo.try!(:[], :bar)'

        it_behaves_like :autocorrect, 'try a single parameter',
                        '[1, 2].try(:join)', '[1, 2]&.join'
        it_behaves_like :autocorrect, 'try with 2 parameters',
                        '[1, 2].try(:join, ",")', '[1, 2]&.join(",")'
        it_behaves_like :autocorrect, 'try with multiple parameters',
                        '[1, 2].try(:join, bar, baz)', '[1, 2]&.join(bar, baz)'
        it_behaves_like :autocorrect, 'try with a block',
                        ['[foo, bar].try(:map) do |e|',
                         '  e.some_method',
                         'end'].join("\n"),
                        ['[foo, bar]&.map do |e|',
                         '  e.some_method',
                         'end'].join("\n")
        it_behaves_like :autocorrect, 'try with params and a block',
                        ['[foo, bar].try(:each_with_object, []) do |e, acc|',
                         '  acc << e.some_method',
                         'end'].join("\n"),
                        ['[foo, bar]&.each_with_object([]) do |e, acc|',
                         '  acc << e.some_method',
                         'end'].join("\n")
      end
    end
  end
end
