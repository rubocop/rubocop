# frozen_string_literal: true

describe RuboCop::Cop::Style::MixinUsage do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  context 'include' do
    it 'registers an offense when using outside class' do
      expect_offense(<<-RUBY.strip_indent)
        include M
        ^^^^^^^^^ `include` is used at the top level. Use inside `class` or `module`.
        class C
        end
      RUBY
    end

    it 'does not register an offense when using inside class' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class C
          include M
        end
      RUBY
    end
  end

  context 'extend' do
    it 'registers an offense when using outside class' do
      expect_offense(<<-RUBY.strip_indent)
        extend M
        ^^^^^^^^ `extend` is used at the top level. Use inside `class` or `module`.
        class C
        end
      RUBY
    end

    it 'does not register an offense when using inside class' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class C
          extend M
        end
      RUBY
    end
  end

  context 'prepend' do
    it 'registers an offense when using outside class' do
      expect_offense(<<-RUBY.strip_indent)
        prepend M
        ^^^^^^^^^ `prepend` is used at the top level. Use inside `class` or `module`.
        class C
        end
      RUBY
    end

    it 'does not register an offense when using inside class' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class C
          prepend M
        end
      RUBY
    end
  end

  it 'does not register an offense when using inside nested module' do
    expect_no_offenses(<<-RUBY.strip_indent)
      module M1
        include M2

        class C
          include M3
        end
      end
    RUBY
  end
end
