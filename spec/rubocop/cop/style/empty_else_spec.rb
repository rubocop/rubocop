# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::EmptyElse do
  subject(:cop) { described_class.new(config) }

  context 'configured to warn on empty else' do
    let(:config) do
      RuboCop::Config.new('Style/EmptyElse' => {
                            'EnforcedStyle' => 'empty',
                            'SupportedStyles' => %w(empty nil both)
                          })
    end

    context 'given an if-statement' do
      context 'with a completely empty else-clause' do
        it 'registers an offense' do
          inspect_source(cop, 'if a; foo else end')
          expect(cop.messages).to eq(['Redundant `else`-clause.'])
        end
      end

      context 'with an else-clause containing only the literal nil' do
        it "doesn't register an offense" do
          inspect_source(cop, 'if a; foo elsif b; bar else nil end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          inspect_source(cop, 'if cond; foo else bar; nil end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          inspect_source(cop, 'if cond; foo end')
          expect(cop.messages).to be_empty
        end
      end
    end

    context 'given an unless-statement' do
      context 'with a completely empty else-clause' do
        it 'registers an offense' do
          inspect_source(cop, 'unless cond; foo else end')
          expect(cop.messages).to eq(['Redundant `else`-clause.'])
        end
      end

      context 'with an else-clause containing only the literal nil' do
        it "doesn't register an offense" do
          inspect_source(cop, 'unless cond; foo else nil end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          inspect_source(cop, 'unless cond; foo else bar; nil end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          inspect_source(cop, 'unless cond; foo end')
          expect(cop.messages).to be_empty
        end
      end
    end

    context 'given a case statement' do
      context 'with a completely empty else-clause' do
        it 'registers an offense' do
          inspect_source(cop, 'case v; when a; foo else end')
          expect(cop.messages).to eq(['Redundant `else`-clause.'])
        end
      end

      context 'with an else-clause containing only the literal nil' do
        it "doesn't register an offense" do
          inspect_source(cop, 'case v; when a; foo; when b; bar; else nil end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          inspect_source(cop, 'case v; when a; foo; else b; nil end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          inspect_source(cop, 'case v; when a; foo; when b; bar; end')
          expect(cop.messages).to be_empty
        end
      end
    end
  end

  context 'configured to warn on nil in else' do
    let(:config) do
      RuboCop::Config.new('Style/EmptyElse' => {
                            'EnforcedStyle' => 'nil',
                            'SupportedStyles' => %w(empty nil both)
                          })
    end

    context 'given an if-statement' do
      context 'with a completely empty else-clause' do
        it "doesn't register an offense" do
          inspect_source(cop, 'if a; foo else end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with an else-clause containing only the literal nil' do
        it 'registers an offense' do
          inspect_source(cop, 'if a; foo elsif b; bar else nil end')
          expect(cop.messages).to eq(['Redundant `else`-clause.'])
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          inspect_source(cop, 'if cond; foo else bar; nil end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          inspect_source(cop, 'if cond; foo end')
          expect(cop.messages).to be_empty
        end
      end
    end

    context 'given an unless-statement' do
      context 'with a completely empty else-clause' do
        it "doesn't register an offense" do
          inspect_source(cop, 'unless cond; foo else end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with an else-clause containing only the literal nil' do
        it 'registers an offense' do
          inspect_source(cop, 'unless cond; foo else nil end')
          expect(cop.messages).to eq(['Redundant `else`-clause.'])
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          inspect_source(cop, 'unless cond; foo else bar; nil end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          inspect_source(cop, 'unless cond; foo end')
          expect(cop.messages).to be_empty
        end
      end
    end

    context 'given a case statement' do
      context 'with a completely empty else-clause' do
        it "doesn't register an offense" do
          inspect_source(cop, 'case v; when a; foo else end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with an else-clause containing only the literal nil' do
        it 'registers an offense' do
          inspect_source(cop, 'case v; when a; foo; when b; bar; else nil end')
          expect(cop.messages).to eq(['Redundant `else`-clause.'])
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          inspect_source(cop, 'case v; when a; foo; else b; nil end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          inspect_source(cop, 'case v; when a; foo; when b; bar; end')
          expect(cop.messages).to be_empty
        end
      end
    end
  end

  context 'configured to warn on empty else and nil in else' do
    let(:config) do
      RuboCop::Config.new('Style/EmptyElse' => {
                            'EnforcedStyle' => 'both',
                            'SupportedStyles' => %w(empty nil both)
                          })
    end

    context 'given an if-statement' do
      context 'with a completely empty else-clause' do
        it 'registers an offense' do
          inspect_source(cop, 'if a; foo else end')
          expect(cop.messages).to eq(['Redundant `else`-clause.'])
        end
      end

      context 'with an else-clause containing only the literal nil' do
        it 'registers an offense' do
          inspect_source(cop, 'if a; foo elsif b; bar else nil end')
          expect(cop.messages).to eq(['Redundant `else`-clause.'])
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          inspect_source(cop, 'if cond; foo else bar; nil end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          inspect_source(cop, 'if cond; foo end')
          expect(cop.messages).to be_empty
        end
      end
    end

    context 'given an unless-statement' do
      context 'with a completely empty else-clause' do
        it 'registers an offense' do
          inspect_source(cop, 'unless cond; foo else end')
          expect(cop.messages).to eq(['Redundant `else`-clause.'])
        end
      end

      context 'with an else-clause containing only the literal nil' do
        it 'registers an offense' do
          inspect_source(cop, 'unless cond; foo else nil end')
          expect(cop.messages).to eq(['Redundant `else`-clause.'])
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          inspect_source(cop, 'unless cond; foo else bar; nil end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          inspect_source(cop, 'unless cond; foo end')
          expect(cop.messages).to be_empty
        end
      end
    end

    context 'given a case statement' do
      context 'with a completely empty else-clause' do
        it 'registers an offense' do
          inspect_source(cop, 'case v; when a; foo else end')
          expect(cop.messages).to eq(['Redundant `else`-clause.'])
        end
      end

      context 'with an else-clause containing only the literal nil' do
        it 'registers an offense' do
          inspect_source(cop, 'case v; when a; foo; when b; bar; else nil end')
          expect(cop.messages).to eq(['Redundant `else`-clause.'])
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          inspect_source(cop, 'case v; when a; foo; else b; nil end')
          expect(cop.messages).to be_empty
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          inspect_source(cop, 'case v; when a; foo; when b; bar; end')
          expect(cop.messages).to be_empty
        end
      end
    end
  end
end
