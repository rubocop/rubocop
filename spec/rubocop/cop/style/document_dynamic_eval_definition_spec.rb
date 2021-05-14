# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DocumentDynamicEvalDefinition, :config do
  it 'registers an offense when using eval-type method with string interpolation without comment docs' do
    expect_offense(<<~RUBY)
      class_eval <<-EOT, __FILE__, __LINE__ + 1
      ^^^^^^^^^^ Add a comment block showing its appearance if interpolated.
        def \#{unsafe_method}(*params, &block)
          to_str.\#{unsafe_method}(*params, &block)
        end
      EOT
    RUBY
  end

  it 'does not register an offense when using eval-type method without string interpolation' do
    expect_no_offenses(<<~RUBY)
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def capitalize(*params, &block)
          to_str.capitalize(*params, &block)
        end
      EOT
    RUBY
  end

  it 'does not register an offense when using eval-type method with string interpolation with comment docs' do
    expect_no_offenses(<<~RUBY)
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def \#{unsafe_method}(*params, &block)       # def capitalize(*params, &block)
          to_str.\#{unsafe_method}(*params, &block)  #   to_str.capitalize(*params, &block)
        end                                          # end
      EOT
    RUBY
  end

  it 'registers an offense when using eval-type method with interpolated string ' \
     'that is not heredoc without comment doc' do
    expect_offense(<<~'RUBY')
      stringio.instance_eval("def original_filename; 'stringio#{n}.txt'; end")
               ^^^^^^^^^^^^^ Add a comment block showing its appearance if interpolated.
    RUBY
  end

  it 'does not register an offense when using eval-type method with interpolated string ' \
     'that is not heredoc with comment doc' do
    expect_no_offenses(<<~'RUBY')
      stringio.instance_eval("def original_filename; 'stringio#{n}.txt'; end # def original_filename; 'stringiofoo.txt'; end")
    RUBY
  end

  context 'block comment in heredoc' do
    it 'does not register an offense for a matching block comment' do
      expect_no_offenses(<<~RUBY)
        class_eval <<-EOT, __FILE__, __LINE__ + 1
          # def capitalize(*params, &block)
          #   to_str.capitalize(*params, &block)
          # end

          def \#{unsafe_method}(*params, &block)
            to_str.\#{unsafe_method}(*params, &block)
          end
        EOT
      RUBY
    end

    it 'does not evaluate comments if there is no interpolation' do
      expect(cop).not_to receive(:comment_block_docs?)

      expect_no_offenses(<<~RUBY)
        class_eval <<-EOT, __FILE__, __LINE__ + 1
          def capitalize(*params, &block)
            to_str.capitalize(*params, &block)
          end
        EOT
      RUBY
    end

    it 'does not register an offense when using inline comments' do
      expect_no_offenses(<<~RUBY)
        class_eval <<-EOT, __FILE__, __LINE__ + 1
          # def capitalize(*params, &block)
          #   to_str.capitalize(*params, &block)
          # end

          def \#{unsafe_method}(*params, &block)
            to_str.\#{unsafe_method}(*params, &block) # { note: etc. }
          end
        EOT
      RUBY
    end

    it 'does not register an offense when using other text' do
      expect_no_offenses(<<~RUBY)
        class_eval <<-EOT, __FILE__, __LINE__ + 1
          # EXAMPLE: def capitalize(*params, &block)
          #   to_str.capitalize(*params, &block)
          # end

          def \#{unsafe_method}(*params, &block)
            to_str.\#{unsafe_method}(*params, &block)
          end
        EOT
      RUBY
    end

    it 'does not register an offense when using multiple methods' do
      expect_no_offenses(<<~RUBY)
        class_eval <<-EOT, __FILE__, __LINE__ + 1
          # def capitalize(*params, &block)
          #   to_str.capitalize(*params, &block)
          # end
          #
          # def capitalize!(*params)
          #   @dirty = true
          #   super
          # end

          def \#{unsafe_method}(*params, &block)
            to_str.\#{unsafe_method}(*params, &block)
          end

          def \#{unsafe_method}!(*params)
            @dirty = true
            super
          end
        EOT
      RUBY
    end

    it 'does not register an offense when using multiple methods with split comments' do
      expect_no_offenses(<<~RUBY)
        class_eval <<-EOT, __FILE__, __LINE__ + 1
          # def capitalize(*params, &block)
          #   to_str.capitalize(*params, &block)
          # end
          def \#{unsafe_method}(*params, &block)
            to_str.\#{unsafe_method}(*params, &block)
          end

          # def capitalize!(*params)
          #   @dirty = true
          #   super
          # end
          def \#{unsafe_method}!(*params)
            @dirty = true
            super
          end
        EOT
      RUBY
    end

    it 'registers an offense if the comment does not match the method' do
      expect_offense(<<~RUBY)
        class_eval <<-EOT, __FILE__, __LINE__ + 1
        ^^^^^^^^^^ Add a comment block showing its appearance if interpolated.
          # def capitalize(*params, &block)
          #   str.capitalize(*params, &block)
          # end

          def \#{unsafe_method}(*params, &block)
            to_str.\#{unsafe_method}(*params, &block)
          end
        EOT
      RUBY
    end
  end

  context 'block comment outside heredoc' do
    it 'does not register an offense for a matching block comment before the heredoc' do
      expect_no_offenses(<<~RUBY)
        class_eval(
          # def capitalize(*params, &block)
          #   to_str.capitalize(*params, &block)
          # end

          <<-EOT, __FILE__, __LINE__ + 1
            def \#{unsafe_method}(*params, &block)
              to_str.\#{unsafe_method}(*params, &block)
            end
          EOT
        )
      RUBY
    end

    it 'does not register an offense for a matching block comment after the heredoc' do
      expect_no_offenses(<<~RUBY)
        class_eval(
          <<-EOT, __FILE__, __LINE__ + 1
            def \#{unsafe_method}(*params, &block)
              to_str.\#{unsafe_method}(*params, &block)
            end
          EOT
          # def capitalize(*params, &block)
          #   to_str.capitalize(*params, &block)
          # end
        )
      RUBY
    end

    it 'does not register an offense when using inline comments' do
      expect_no_offenses(<<~RUBY)
        class_eval(
          # def capitalize(*params, &block)
          #   to_str.capitalize(*params, &block)
          # end

          <<-EOT, __FILE__, __LINE__ + 1
            def \#{unsafe_method}(*params, &block)
              to_str.\#{unsafe_method}(*params, &block) # { note: etc. }
            end
          EOT
        )
      RUBY
    end

    it 'does not register an offense when using other text' do
      expect_no_offenses(<<~RUBY)
        class_eval(
          # EXAMPLE: def capitalize(*params, &block)
          #   to_str.capitalize(*params, &block)
          # end

          <<-EOT, __FILE__, __LINE__ + 1
            def \#{unsafe_method}(*params, &block)
              to_str.\#{unsafe_method}(*params, &block)
            end
          EOT
        )
      RUBY
    end

    it 'registers an offense if the comment does not match the method' do
      expect_offense(<<~RUBY)
        class_eval(
        ^^^^^^^^^^ Add a comment block showing its appearance if interpolated.
          # def capitalize(*params, &block)
          #   str.capitalize(*params, &block)
          # end

          <<-EOT, __FILE__, __LINE__ + 1
            def \#{unsafe_method}(*params, &block)
              to_str.\#{unsafe_method}(*params, &block)
            end
          EOT
        )
      RUBY
    end

    it 'does not register an offense when using multiple methods' do
      expect_no_offenses(<<~RUBY)
        class_eval(
          # def capitalize(*params, &block)
          #   to_str.capitalize(*params, &block)
          # end
          #
          # def capitalize!(*params)
          #   @dirty = true
          #   super
          # end

          <<-EOT, __FILE__, __LINE__ + 1
            def \#{unsafe_method}(*params, &block)
              to_str.\#{unsafe_method}(*params, &block)
            end

            def \#{unsafe_method}!(*params)
              @dirty = true
              super
            end
          EOT
        )
      RUBY
    end
  end
end
