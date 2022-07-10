# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyElse, :config do
  let(:missing_else_config) { {} }

  shared_examples 'autocorrect' do |keyword|
    context 'MissingElse is disabled' do
      it 'does autocorrection' do
        expect_offense(source)

        expect_correction(corrected_source)
      end
    end

    %w[both if case].each do |missing_else_style|
      context "MissingElse is #{missing_else_style}" do
        let(:missing_else_config) do
          { 'Enabled' => true,
            'EnforcedStyle' => missing_else_style }
        end

        if ['both', keyword].include? missing_else_style
          it 'does not autocorrect' do
            expect_offense(source)

            expect_no_corrections
          end
        else
          it 'does autocorrection' do
            expect_offense(source)

            expect_correction(corrected_source)
          end
        end
      end
    end
  end

  context 'configured to warn on empty else' do
    let(:config) do
      RuboCop::Config.new('Style/EmptyElse' => {
                            'EnforcedStyle' => 'empty',
                            'SupportedStyles' => %w[empty nil both]
                          },
                          'Style/MissingElse' => missing_else_config)
    end

    context 'given an if-statement' do
      context 'with a completely empty else-clause' do
        context 'using semicolons' do
          let(:source) { <<~RUBY }
            if a; foo else end
                      ^^^^ Redundant `else`-clause.
          RUBY
          let(:corrected_source) { <<~RUBY }
            if a; foo end
          RUBY

          it_behaves_like 'autocorrect', 'if'
        end

        context 'not using semicolons' do
          let(:source) { <<~RUBY }
            if a
              foo
            else
            ^^^^ Redundant `else`-clause.
            end
          RUBY
          let(:corrected_source) { <<~RUBY }
            if a
              foo
            end
          RUBY

          it_behaves_like 'autocorrect', 'if'
        end
      end

      context 'with an else-clause containing only the literal nil' do
        it "doesn't register an offense" do
          expect_no_offenses('if a; foo elsif b; bar else nil end')
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          expect_no_offenses('if cond; foo else bar; nil end')
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses('if cond; foo end')
        end
      end

      context 'in an if-statement' do
        let(:source) { <<~RUBY }
          if cond
            if cond2
              something
            else
            ^^^^ Redundant `else`-clause.
            end
          end
        RUBY
        let(:corrected_source) { <<~RUBY }
          if cond
            if cond2
              something
            end
          end
        RUBY

        it_behaves_like 'autocorrect', 'if'
      end

      context 'with an empty comment' do
        it 'does not autocorrect' do
          expect_offense(<<~RUBY)
            if cond
              something
            else
            ^^^^ Redundant `else`-clause.
              # TODO
            end
          RUBY

          expect_no_corrections
        end
      end
    end

    context 'given an unless-statement' do
      context 'with a completely empty else-clause' do
        let(:source) { <<~RUBY }
          unless cond; foo else end
                           ^^^^ Redundant `else`-clause.
        RUBY
        let(:corrected_source) { <<~RUBY }
          unless cond; foo end
        RUBY

        it_behaves_like 'autocorrect', 'if'
      end

      context 'with an else-clause containing only the literal nil' do
        it "doesn't register an offense" do
          expect_no_offenses('unless cond; foo else nil end')
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          expect_no_offenses('unless cond; foo else bar; nil end')
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses('unless cond; foo end')
        end
      end
    end

    context 'given a case statement' do
      context 'with a completely empty else-clause' do
        let(:source) { <<~RUBY }
          case v; when a; foo else end
                              ^^^^ Redundant `else`-clause.
        RUBY
        let(:corrected_source) { <<~RUBY }
          case v; when a; foo end
        RUBY

        it_behaves_like 'autocorrect', 'case'
      end

      context 'with an else-clause containing only the literal nil' do
        it "doesn't register an offense" do
          expect_no_offenses('case v; when a; foo; when b; bar; else nil end')
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          expect_no_offenses('case v; when a; foo; else b; nil end')
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses('case v; when a; foo; when b; bar; end')
        end
      end
    end
  end

  context 'configured to warn on nil in else' do
    let(:config) do
      RuboCop::Config.new('Style/EmptyElse' => {
                            'EnforcedStyle' => 'nil',
                            'SupportedStyles' => %w[empty nil both]
                          },
                          'Style/MissingElse' => missing_else_config)
    end

    context 'given an if-statement' do
      context 'with a completely empty else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses('if a; foo else end')
        end
      end

      context 'with an else-clause containing only the literal nil' do
        context 'when standalone' do
          let(:source) { <<~RUBY }
            if a
              foo
            elsif b
              bar
            else
            ^^^^ Redundant `else`-clause.
              nil
            end
          RUBY

          let(:corrected_source) { <<~RUBY }
            if a
              foo
            elsif b
              bar
            end
          RUBY

          it_behaves_like 'autocorrect', 'if'
        end

        context 'when the result is assigned to a variable' do
          let(:source) { <<~RUBY }
            foobar = if a
                       foo
                     elsif b
                       bar
                     else
                     ^^^^ Redundant `else`-clause.
                       nil
                     end
          RUBY

          let(:corrected_source) { <<~RUBY }
            foobar = if a
                       foo
                     elsif b
                       bar
                     end
          RUBY

          it_behaves_like 'autocorrect', 'if'
        end
      end

      context 'with an else-clause containing only the literal nil using semicolons' do
        context 'with one elsif' do
          let(:source) { <<~RUBY }
            if a; foo elsif b; bar else nil end
                                   ^^^^ Redundant `else`-clause.
          RUBY
          let(:corrected_source) { <<~RUBY }
            if a; foo elsif b; bar end
          RUBY

          it_behaves_like 'autocorrect', 'if'
        end

        context 'with multiple elsifs' do
          let(:source) { <<~RUBY }
            if a; foo elsif b; bar; elsif c; bar else nil end
                                                 ^^^^ Redundant `else`-clause.
          RUBY
          let(:corrected_source) { <<~RUBY }
            if a; foo elsif b; bar; elsif c; bar end
          RUBY

          it_behaves_like 'autocorrect', 'if'
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          expect_no_offenses('if cond; foo else bar; nil end')
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses('if cond; foo end')
        end
      end
    end

    context 'given an unless-statement' do
      context 'with a completely empty else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses('unless cond; foo else end')
        end
      end

      context 'with an else-clause containing only the literal nil' do
        let(:source) { <<~RUBY }
          unless cond; foo else nil end
                           ^^^^ Redundant `else`-clause.
        RUBY
        let(:corrected_source) { <<~RUBY }
          unless cond; foo end
        RUBY

        it_behaves_like 'autocorrect', 'if'
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          expect_no_offenses('unless cond; foo else bar; nil end')
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses('unless cond; foo end')
        end
      end
    end

    context 'given a case statement' do
      context 'with a completely empty else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses('case v; when a; foo else end')
        end
      end

      context 'with an else-clause containing only the literal nil' do
        context 'using semicolons' do
          let(:source) { <<~RUBY }
            case v; when a; foo; when b; bar; else nil end
                                              ^^^^ Redundant `else`-clause.
          RUBY
          let(:corrected_source) { <<~RUBY }
            case v; when a; foo; when b; bar; end
          RUBY

          it_behaves_like 'autocorrect', 'case'
        end

        context 'when the result is assigned to a variable' do
          let(:source) { <<~RUBY }
            foobar = case v
                     when a
                       foo
                     when b
                       bar
                     else
                     ^^^^ Redundant `else`-clause.
                       nil
                     end
          RUBY

          let(:corrected_source) { <<~RUBY }
            foobar = case v
                     when a
                       foo
                     when b
                       bar
                     end
          RUBY

          it_behaves_like 'autocorrect', 'case'
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          expect_no_offenses('case v; when a; foo; else b; nil end')
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses('case v; when a; foo; when b; bar; end')
        end
      end
    end
  end

  context 'configured to warn on empty else and nil in else' do
    let(:config) do
      RuboCop::Config.new('Style/EmptyElse' => {
                            'EnforcedStyle' => 'both',
                            'SupportedStyles' => %w[empty nil both]
                          },
                          'Style/MissingElse' => missing_else_config)
    end

    context 'given an if-statement' do
      context 'with a completely empty else-clause' do
        let(:source) { <<~RUBY }
          if a; foo else end
                    ^^^^ Redundant `else`-clause.
        RUBY
        let(:corrected_source) { <<~RUBY }
          if a; foo end
        RUBY

        it_behaves_like 'autocorrect', 'if'
      end

      context 'with an else-clause containing only the literal nil' do
        context 'with one elsif' do
          let(:source) { <<~RUBY }
            if a; foo elsif b; bar else nil end
                                   ^^^^ Redundant `else`-clause.
          RUBY
          let(:corrected_source) { <<~RUBY }
            if a; foo elsif b; bar end
          RUBY

          it_behaves_like 'autocorrect', 'if'
        end

        context 'with multiple elsifs' do
          let(:source) { <<~RUBY }
            if a; foo elsif b; bar; elsif c; bar else nil end
                                                 ^^^^ Redundant `else`-clause.
          RUBY
          let(:corrected_source) { <<~RUBY }
            if a; foo elsif b; bar; elsif c; bar end
          RUBY

          it_behaves_like 'autocorrect', 'if'
        end
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          expect_no_offenses('if cond; foo else bar; nil end')
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses('if cond; foo end')
        end
      end
    end

    context 'given an unless-statement' do
      context 'with a completely empty else-clause' do
        let(:source) { <<~RUBY }
          unless cond; foo else end
                           ^^^^ Redundant `else`-clause.
        RUBY
        let(:corrected_source) { <<~RUBY }
          unless cond; foo end
        RUBY

        it_behaves_like 'autocorrect', 'if'
      end

      context 'with an else-clause containing only the literal nil' do
        let(:source) { <<~RUBY }
          unless cond; foo else nil end
                           ^^^^ Redundant `else`-clause.
        RUBY
        let(:corrected_source) { <<~RUBY }
          unless cond; foo end
        RUBY

        it_behaves_like 'autocorrect', 'if'
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          expect_no_offenses('unless cond; foo else bar; nil end')
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses('unless cond; foo end')
        end
      end
    end

    context 'given a case statement' do
      context 'with a completely empty else-clause' do
        let(:source) { <<~RUBY }
          case v; when a; foo else end
                              ^^^^ Redundant `else`-clause.
        RUBY
        let(:corrected_source) { <<~RUBY }
          case v; when a; foo end
        RUBY

        it_behaves_like 'autocorrect', 'case'
      end

      context 'with an else-clause containing only the literal nil' do
        let(:source) { <<~RUBY }
          case v; when a; foo; when b; bar; else nil end
                                            ^^^^ Redundant `else`-clause.
        RUBY
        let(:corrected_source) { <<~RUBY }
          case v; when a; foo; when b; bar; end
        RUBY

        it_behaves_like 'autocorrect', 'case'
      end

      context 'with an else-clause with side-effects' do
        it "doesn't register an offense" do
          expect_no_offenses('case v; when a; foo; else b; nil end')
        end
      end

      context 'with no else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses('case v; when a; foo; when b; bar; end')
        end
      end
    end
  end

  context 'when `AllowComments: true`' do
    let(:config) do
      RuboCop::Config.new('Style/EmptyElse' => {
                            'AllowComments' => true,
                            'EnforcedStyle' => 'both',
                            'SupportedStyles' => %w[empty nil both]
                          },
                          'Style/MissingElse' => missing_else_config)
    end

    context 'given an if-statement' do
      context 'with not comment and empty else-clause' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            if condition
              statement
            else
            ^^^^ Redundant `else`-clause.
            end
          RUBY
        end
      end

      context 'with not comment and nil else-clause' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            if condition
              statement
            else
            ^^^^ Redundant `else`-clause.
              nil
            end
          RUBY
        end
      end

      context 'with comment and empty else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses(<<~RUBY)
            if condition
              statement
            else
              # some comment
            end
          RUBY
        end
      end

      context 'with comment and nil else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses(<<~RUBY)
            if condition
              statement
            else
              nil # some comment
            end
          RUBY
        end
      end
    end

    context 'given an unless-statement' do
      context 'with not comment and empty else-clause' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            unless condition
              statement
            else
            ^^^^ Redundant `else`-clause.
            end
          RUBY
        end
      end

      context 'with not comment and nil else-clause' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            unless condition
              statement
            else
            ^^^^ Redundant `else`-clause.
              nil
            end
          RUBY
        end
      end

      context 'with comment and empty else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses(<<~RUBY)
            unless condition
              statement
            else
              # some comment
            end
          RUBY
        end
      end

      context 'with comment and nil else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses(<<~RUBY)
            unless condition
              statement
            else
              nil # some comment
            end
          RUBY
        end
      end
    end

    context 'given a case statement' do
      context 'with not comment and empty else-clause' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            case a
            when condition
              statement
            else
            ^^^^ Redundant `else`-clause.
            end
          RUBY
        end
      end

      context 'with not comment and nil else-clause' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            case a
            when condition
              statement
            else
            ^^^^ Redundant `else`-clause.
              nil
            end
          RUBY
        end
      end

      context 'with comment and empty else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses(<<~RUBY)
            case a
            when condition
              statement
            else
              # some comment
            end
          RUBY
        end
      end

      context 'with comment and nil else-clause' do
        it "doesn't register an offense" do
          expect_no_offenses(<<~RUBY)
            case a
            when condition
              statement
            else
              nil # some comment
            end
          RUBY
        end
      end
    end
  end

  context 'with nested if and case statement' do
    let(:config) do
      RuboCop::Config.new('Style/EmptyElse' => {
                            'EnforcedStyle' => 'nil',
                            'SupportedStyles' => %w[empty nil both]
                          },
                          'Style/MissingElse' => missing_else_config)
    end

    let(:source) { <<~RUBY }
      def foo
        if @params
          case @params[:x]
          when :a
            :b
          else
          ^^^^ Redundant `else`-clause.
            nil
          end
        else
          :c
        end
      end
    RUBY

    let(:corrected_source) { <<~RUBY }
      def foo
        if @params
          case @params[:x]
          when :a
            :b
          end
        else
          :c
        end
      end
    RUBY

    it_behaves_like 'autocorrect', 'case'
  end
end
