# frozen_string_literal: true

describe RuboCop::Cop::Style::UnlessElse do
  subject(:cop) { described_class.new }

  context 'unless with else' do
    let(:source) do
      <<-RUBY.strip_indent
        unless x # negative 1
          a = 1 # negative 2
        else # positive 1
          a = 0 # positive 2
        end
      RUBY
    end

    it 'registers an offense' do
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects' do
      corrected = autocorrect_source(source)
      expect(corrected).to eq(<<-RUBY.strip_indent)
        if x # positive 1
          a = 0 # positive 2
        else # negative 1
          a = 1 # negative 2
        end
      RUBY
    end
  end

  context 'unless with nested if-else' do
    let(:source) do
      <<-RUBY.strip_indent
        unless(x)
          if(y == 0)
            a = 0
          elsif(z == 0)
            a = 1
          else
            a = 2
          end
        else
          a = 3
        end
      RUBY
    end

    it 'registers an offense' do
      inspect_source(source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects' do
      corrected = autocorrect_source(source)
      expect(corrected).to eq(<<-RUBY.strip_indent)
        if(x)
          a = 3
        else
          if(y == 0)
            a = 0
          elsif(z == 0)
            a = 1
          else
            a = 2
          end
        end
      RUBY
    end
  end

  context 'unless without else' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        unless x
          a = 1
        end
      RUBY
    end
  end
end
