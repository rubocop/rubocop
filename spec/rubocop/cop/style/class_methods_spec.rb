# frozen_string_literal: true

describe RuboCop::Cop::Style::ClassMethods do
  subject(:cop) { described_class.new }

  it 'registers an offense for methods using a class name' do
    inspect_source(cop, <<-END.strip_indent)
      class Test
        def Test.some_method
          do_something
        end
      end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use `self.some_method` instead of `Test.some_method`.'])
    expect(cop.highlights).to eq(['Test'])
  end

  it 'registers an offense for methods using a module name' do
    inspect_source(cop, <<-END.strip_indent)
      module Test
        def Test.some_method
          do_something
        end
      end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use `self.some_method` instead of `Test.some_method`.'])
    expect(cop.highlights).to eq(['Test'])
  end

  it 'does not register an offense for methods using self' do
    inspect_source(cop, <<-END.strip_indent)
      module Test
        def self.some_method
          do_something
        end
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for other top-level singleton methods' do
    inspect_source(cop, <<-END.strip_indent)
      class Test
        X = Something.new

        def X.some_method
          do_something
        end
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense outside class/module bodies' do
    inspect_source(cop, <<-END.strip_indent)
      def Test.some_method
        do_something
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'autocorrects class name to self' do
    src = <<-END.strip_indent
      class Test
        def Test.some_method
          do_something
        end
      end
    END

    correct_source = <<-END.strip_indent
      class Test
        def self.some_method
          do_something
        end
      end
    END

    new_source = autocorrect_source(cop, src)
    expect(new_source).to eq(correct_source)
  end
end
