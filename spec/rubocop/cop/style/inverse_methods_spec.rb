# frozen_string_literal: true

describe RuboCop::Cop::Style::InverseMethods do
  let(:config) do
    RuboCop::Config.new(
      'Style/InverseMethods' => {
        'InverseMethods' => {
          any?: :none?,
          even?: :odd?,
          present?: :blank?,
          include?: :exclude?,
          :== => :!=,
          :=~ => :!~,
          :< => :>=,
          :> => :<=
        },
        'InverseBlocks' => {
          select: :reject,
          select!: :reject!
        }
      }
    )
  end

  subject(:cop) { described_class.new(config) }

  it 'registers an offense for calling !.none? with a symbol proc' do
    inspect_source(cop, '!foo.none?(&:even?)')

    expect(cop.messages).to eq(['Use `any?` instead of inverting `none?`.'])
    expect(cop.highlights).to eq(['!foo.none?(&:even?)'])
  end

  it 'registers an offense for calling !.none? with a block' do
    inspect_source(cop, '!foo.none? { |f| f.even? }')

    expect(cop.messages).to eq(['Use `any?` instead of inverting `none?`.'])
    expect(cop.highlights).to eq(['!foo.none? { |f| f.even? }'])
  end

  it 'allows a method call without a not' do
    inspect_source(cop, 'foo.none?')

    expect(cop.offenses).to be_empty
  end

  context 'auto-correct' do
    it 'corrects !.none? wiht a symbol proc to any?' do
      new_source = autocorrect_source(cop, '!foo.none?(&:even?)')

      expect(new_source).to eq('foo.any?(&:even?)')
    end

    it 'corrects !.none? with a block to any?' do
      new_source = autocorrect_source(cop, '!foo.none? { |f| f.even? }')

      expect(new_source).to eq('foo.any? { |f| f.even? }')
    end
  end

  shared_examples :all_variable_types do |variable|
    it "registers an offense for calling !#{variable}.none?" do
      inspect_source(cop, "!#{variable}.none?")

      expect(cop.messages).to eq(['Use `any?` instead of inverting `none?`.'])
      expect(cop.highlights).to eq(["!#{variable}.none?"])
    end

    it "registers an offense for calling not #{variable}.none?" do
      inspect_source(cop, "not #{variable}.none?")

      expect(cop.messages).to eq(['Use `any?` instead of inverting `none?`.'])
      expect(cop.highlights).to eq(["not #{variable}.none?"])
    end

    it "corrects !#{variable}.none? to #{variable}.any?" do
      new_source = autocorrect_source(cop, "!#{variable}.none?")

      expect(new_source).to eq("#{variable}.any?")
    end

    it "corrects not #{variable}.none? to #{variable}.any?" do
      new_source = autocorrect_source(cop, "not #{variable}.none?")

      expect(new_source).to eq("#{variable}.any?")
    end
  end

  it_behaves_like :all_variable_types, 'foo'
  it_behaves_like :all_variable_types, '$foo'
  it_behaves_like :all_variable_types, '@foo'
  it_behaves_like :all_variable_types, '@@foo'
  it_behaves_like :all_variable_types, 'FOO'
  it_behaves_like :all_variable_types, 'FOO::BAR'
  it_behaves_like :all_variable_types, 'foo["bar"]'
  it_behaves_like :all_variable_types, 'foo.bar'

  { any?: :none?,
    even?: :odd?,
    present?: :blank?,
    include?: :exclude?,
    none?: :any?,
    odd?: :even?,
    blank?: :present?,
    exclude?: :include? }.each do |method, inverse|
      it "registers an offense for !foo.#{method}" do
        inspect_source(cop, "!foo.#{method}")

        expect(cop.messages)
          .to eq(["Use `#{inverse}` instead of inverting `#{method}`."])
      end

      it "corrects #{method} to #{inverse}" do
        new_source = autocorrect_source(cop, "!foo.#{method}")

        expect(new_source).to eq("foo.#{inverse}")
      end
    end

  { :== => :!=,
    :!= => :==,
    :=~ => :!~,
    :!~ => :=~,
    :< => :>=,
    :> => :<= }.each do |method, inverse|
    it "registers an offense for !(foo #{method} bar)" do
      inspect_source(cop, "!(foo #{method} bar)")

      expect(cop.messages)
        .to eq(["Use `#{inverse}` instead of inverting `#{method}`."])
    end

    it "registers an offense for not (foo #{method} bar)" do
      inspect_source(cop, "not (foo #{method} bar)")

      expect(cop.messages)
        .to eq(["Use `#{inverse}` instead of inverting `#{method}`."])
    end

    it "corrects #{method} to #{inverse}" do
      new_source = autocorrect_source(cop, "!(foo #{method} bar)")

      expect(new_source).to eq("foo #{inverse} bar")
    end
  end

  context 'inverse blocks' do
    { select: :reject,
      reject: :select,
      select!: :reject!,
      reject!: :select! }.each do |method, inverse|
      it "registers an offense for foo.#{method} { |e| !e }" do
        inspect_source(cop, "foo.#{method} { |e| !e }")

        expect(cop.messages)
          .to eq(["Use `#{inverse}` instead of inverting `#{method}`."])
      end

      it 'registers an offense for a multiline method call where the last ' \
        'method is inverted' do
        inspect_source(cop, <<-END.strip_indent)
          foo.#{method} do |e|
            something
            !e.bar
          end
        END

        expect(cop.messages)
          .to eq(["Use `#{inverse}` instead of inverting `#{method}`."])
      end

      it 'registers an offense for an inverted equality block' do
        inspect_source(cop, "foo.#{method} { |e| e != 2 }")

        expect(cop.messages)
          .to eq(["Use `#{inverse}` instead of inverting `#{method}`."])
      end

      it 'registers an offense for a multiline inverted equality block' do
        inspect_source(cop, <<-END.strip_indent)
          foo.#{method} do |e|
            something
            something_else
            e != 2
          end
        END

        expect(cop.messages)
          .to eq(["Use `#{inverse}` instead of inverting `#{method}`."])
      end

      it 'corrects a simple inverted block' do
        new_source = autocorrect_source(cop, "foo.#{method} { |e| !e }")

        expect(new_source).to eq("foo.#{inverse} { |e| e }")
      end

      it 'corrects an inverted method call' do
        new_source = autocorrect_source(cop, "foo.#{method} { |e| !e.bar? }")

        expect(new_source).to eq("foo.#{inverse} { |e| e.bar? }")
      end

      it 'corrects a complex inverted method call' do
        source = "puts 1 if !foo.#{method} { |e| !e.bar? }"
        new_source = autocorrect_source(cop, source)

        expect(new_source).to eq("puts 1 if !foo.#{inverse} { |e| e.bar? }")
      end

      it 'corrects an inverted do end method call' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          foo.#{method} do |e|
            !e.bar
          end
        END

        expect(new_source).to eq(<<-END.strip_indent)
          foo.#{inverse} do |e|
            e.bar
          end
        END
      end

      it 'corrects a multiline method call where the last method is inverted' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          foo.#{method} do |e|
            something
            something_else
            !e.bar
          end
        END

        expect(new_source).to eq(<<-END.strip_indent)
          foo.#{inverse} do |e|
            something
            something_else
            e.bar
          end
        END
      end

      it 'corrects an offense for an inverted equality block' do
        new_source = autocorrect_source(cop, "foo.#{method} { |e| e != 2 }")

        expect(new_source).to eq("foo.#{inverse} { |e| e == 2 }")
      end

      it 'corrects an offense for a multiline inverted equality block' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          foo.#{method} do |e|
            something
            something_else
            e != 2
          end
        END

        expect(new_source).to eq(<<-END.strip_indent)
          foo.#{inverse} do |e|
            something
            something_else
            e == 2
          end
        END
      end
    end
  end
end
