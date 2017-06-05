# frozen_string_literal: true

describe RuboCop::Cop::Style::MixinGrouping, :config do
  subject(:cop) { described_class.new(config) }

  before do
    inspect_source(cop, source)
  end

  shared_examples 'code with offense' do |code, expected|
    context "when checking #{code}" do
      let(:source) { code }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(offenses)
        expect(cop.messages).to eq([message] * offenses)
      end

      if expected
        it 'auto-corrects' do
          expect(autocorrect_source(cop, code)).to eq(expected)
        end
      else
        it 'does not auto-correct' do
          expect(autocorrect_source(cop, code)).to eq(code)
        end
      end
    end
  end

  shared_examples 'code without offense' do |code|
    let(:source) { code }

    it 'does not register an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'when configured with separated style' do
    let(:cop_config) { { 'EnforcedStyle' => 'separated' } }

    let(:offenses) { 1 }

    context 'when using `include`' do
      let(:message) { 'Put `include` mixins in separate statements.' }

      context 'with several mixins in one call' do
        it_behaves_like 'code with offense',
                        ['class Foo',
                         '  include Bar, Qux',
                         'end'].join("\n"),
                        ['class Foo',
                         '  include Qux',
                         '  include Bar',
                         'end'].join("\n")
      end

      context 'with single mixins in separate calls' do
        it_behaves_like 'code without offense', <<-RUBY.strip_indent
          class Foo
            include Bar
            include Qux
          end
        RUBY
      end

      context 'when include call is an argument to another method' do
        it_behaves_like 'code without offense',
                        'expect(foo).to include(bar, baz)'
      end

      context 'with several mixins in seperate calls' do
        it_behaves_like 'code with offense',
                        ['class Foo',
                         '  include Bar, Baz',
                         '  include Qux',
                         'end'].join("\n"),
                        ['class Foo',
                         '  include Baz',
                         '  include Bar',
                         '  include Qux',
                         'end'].join("\n")
      end
    end

    context 'when using `extend`' do
      let(:message) { 'Put `extend` mixins in separate statements.' }

      context 'with several mixins in one call' do
        it_behaves_like 'code with offense',
                        ['class Foo',
                         '  extend Bar, Qux',
                         'end'].join("\n"),
                        ['class Foo',
                         '  extend Qux',
                         '  extend Bar',
                         'end'].join("\n")
      end

      context 'with single mixins in separate calls' do
        it_behaves_like 'code without offense', <<-RUBY.strip_indent
          class Foo
            extend Bar
            extend Qux
          end
        RUBY
      end
    end

    context 'when using `prepend`' do
      let(:message) { 'Put `prepend` mixins in separate statements.' }

      context 'with several mixins in one call' do
        it_behaves_like 'code with offense',
                        ['class Foo',
                         '  prepend Bar, Qux',
                         'end'].join("\n"),
                        ['class Foo',
                         '  prepend Qux',
                         '  prepend Bar',
                         'end'].join("\n")
      end

      context 'with single mixins in separate calls' do
        it_behaves_like 'code without offense', <<-RUBY.strip_indent
          class Foo
            prepend Bar
            prepend Qux
          end
        RUBY
      end
    end

    context 'when using a mix of diffent methods' do
      context 'with some calls having several mixins' do
        let(:message) { 'Put `include` mixins in separate statements.' }

        it_behaves_like 'code with offense',
                        ['class Foo',
                         '  include Bar, Baz',
                         '  extend Qux',
                         'end'].join("\n"),
                        ['class Foo',
                         '  include Baz',
                         '  include Bar',
                         '  extend Qux',
                         'end'].join("\n")
      end

      context 'with all calls having one mixin' do
        it_behaves_like 'code without offense', <<-RUBY.strip_indent
          class Foo
            include Bar
            prepend Baz
            extend Baz
          end
        RUBY
      end
    end
  end

  context 'when configured with grouped style' do
    let(:cop_config) { { 'EnforcedStyle' => 'grouped' } }

    context 'when using include' do
      context 'with single mixins in separate calls' do
        let(:offenses) { 3 }
        let(:message) { 'Put `include` mixins in a single statement.' }

        it_behaves_like 'code with offense',
                        ['class Foo',
                         '  include Bar',
                         '  include Baz',
                         '  include Qux',
                         'end'].join("\n"),
                        ['class Foo',
                         '  include Qux, Baz, Bar',
                         'end'].join("\n")
      end

      context 'with several mixins in one call' do
        it_behaves_like 'code without offense', <<-RUBY.strip_indent
          class Foo
            include Bar, Qux
          end
        RUBY
      end

      context 'when include has an explicit receiver' do
        it_behaves_like 'code without offense', <<-RUBY.strip_indent
          config.include Foo
          config.include Bar
        RUBY
      end

      context 'with several mixins in seperate calls' do
        let(:offenses) { 3 }
        let(:message) { 'Put `include` mixins in a single statement.' }

        it_behaves_like 'code with offense',
                        ['class Foo',
                         '  include Bar, Baz',
                         '  include FooBar, FooBaz',
                         '  include Qux, FooBarBaz',
                         'end'].join("\n"),
                        ['class Foo',
                         '  include Qux, FooBarBaz, FooBar, FooBaz, Bar, Baz',
                         'end'].join("\n")
      end
    end

    context 'when using `extend`' do
      context 'with single mixins in seperate calls' do
        let(:offenses) { 2 }
        let(:message) { 'Put `extend` mixins in a single statement.' }

        it_behaves_like 'code with offense',
                        ['class Foo',
                         '  extend Bar',
                         '  extend Baz',
                         'end'].join("\n"),
                        ['class Foo',
                         '  extend Baz, Bar',
                         'end'].join("\n")
      end

      context 'with several mixins in one call' do
        it_behaves_like 'code without offense', <<-RUBY.strip_indent
          class Foo
            extend Bar, Qux
          end
        RUBY
      end
    end

    context 'when using `prepend`' do
      context 'with single mixins in separate calls' do
        let(:offenses) { 2 }
        let(:message) { 'Put `prepend` mixins in a single statement.' }

        it_behaves_like 'code with offense',
                        ['class Foo',
                         '  prepend Bar',
                         '  prepend Baz',
                         'end'].join("\n"),
                        ['class Foo',
                         '  prepend Baz, Bar',
                         'end'].join("\n")
      end

      context 'with several mixins in one call' do
        it_behaves_like 'code without offense', <<-RUBY.strip_indent
          class Foo
            prepend Bar, Qux
          end
        RUBY
      end
    end

    context 'when using a mix of diffent methods' do
      context 'with some duplicated mixin methods' do
        let(:offenses) { 2 }
        let(:message) { 'Put `include` mixins in a single statement.' }

        it_behaves_like 'code with offense',
                        ['class Foo',
                         '  include Bar',
                         '  include Baz',
                         '  extend Baz',
                         'end'].join("\n"),
                        ['class Foo',
                         '  include Baz, Bar',
                         '  extend Baz',
                         'end'].join("\n")
      end

      context 'with all different mixin methods' do
        it_behaves_like 'code without offense', <<-RUBY.strip_indent
          class Foo
            include Bar
            prepend Baz
            extend Baz
          end
        RUBY
      end
    end
  end
end
