# frozen_string_literal: true

describe RuboCop::Cop::Layout::EmptyLinesAroundAccessModifier do
  subject(:cop) { described_class.new }

  %w[private protected public module_function].each do |access_modifier|
    it "requires blank line before #{access_modifier}" do
      inspect_source(<<-RUBY.strip_indent)
        class Test
          something
          #{access_modifier}

          def test; end
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(["Keep a blank line before and after `#{access_modifier}`."])
    end

    it "requires blank line after #{access_modifier}" do
      inspect_source(<<-RUBY.strip_indent)
        class Test
          something

          #{access_modifier}
          def test; end
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(["Keep a blank line before and after `#{access_modifier}`."])
    end

    it "ignores comment line before #{access_modifier}" do
      inspect_source(<<-RUBY.strip_indent)
        class Test
          something

          # This comment is fine
          #{access_modifier}

          def test; end
        end
      RUBY
      expect(cop.offenses).to be_empty
    end

    it "ignores #{access_modifier} inside a method call" do
      inspect_source(<<-RUBY.strip_indent)
        class Test
          def #{access_modifier}?
            #{access_modifier}
          end
        end
      RUBY
      expect(cop.offenses).to be_empty
    end

    it "ignores #{access_modifier} deep inside a method call" do
      inspect_source(<<-RUBY.strip_indent)
        class Test
          def #{access_modifier}?
            if true
              #{access_modifier}
            end
          end
        end
      RUBY
      expect(cop.offenses).to be_empty
    end

    it "ignores #{access_modifier} with a right-hand-side condition" do
      inspect_source(<<-RUBY.strip_indent)
        class Test
          def #{access_modifier}?
            #{access_modifier} if true
          end
        end
      RUBY
      expect(cop.offenses).to be_empty
    end

    it "autocorrects blank line before #{access_modifier}" do
      corrected = autocorrect_source(cop, <<-RUBY.strip_indent)
        class Test
          something
          #{access_modifier}

          def test; end
        end
      RUBY
      expect(corrected).to eq(<<-RUBY.strip_indent)
        class Test
          something

          #{access_modifier}

          def test; end
        end
      RUBY
    end

    it 'autocorrects blank line after #{access_modifier}' do
      corrected = autocorrect_source(cop, <<-RUBY.strip_indent)
        class Test
          something

          #{access_modifier}
          def test; end
        end
      RUBY
      expect(corrected).to eq(<<-RUBY.strip_indent)
        class Test
          something

          #{access_modifier}

          def test; end
        end
      RUBY
    end

    it 'autocorrects blank line after #{access_modifier} with comment' do
      corrected = autocorrect_source(cop, <<-RUBY.strip_indent)
        class Test
          something

          #{access_modifier} # let's modify the rest
          def test; end
        end
      RUBY
      expect(corrected).to eq(<<-RUBY.strip_indent)
        class Test
          something

          #{access_modifier} # let's modify the rest

          def test; end
        end
      RUBY
    end

    it 'accepts missing blank line when at the beginning of class/module' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Test
          #{access_modifier}

          def test; end
        end
      RUBY
    end

    it "requires blank line after, but not before, #{access_modifier} " \
       'when at the beginning of class/module' do
      inspect_source(<<-RUBY.strip_indent)
        class Test
          #{access_modifier}
          def test
          end
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(["Keep a blank line after `#{access_modifier}`."])
    end

    context 'at the beginning of block' do
      context 'for blocks defined with do' do
        it 'accepts missing blank line' do
          expect_no_offenses(<<-RUBY.strip_indent)
            included do
              #{access_modifier}

              def test; end
            end
          RUBY
        end

        it 'accepts missing blank line with arguments' do
          expect_no_offenses(<<-RUBY.strip_indent)
            included do |foo|
              #{access_modifier}

              def test; end
            end
          RUBY
        end

        it "requires blank line after, but not before, #{access_modifier}" do
          inspect_source(<<-RUBY.strip_indent)
            included do
              #{access_modifier}
              def test
              end
            end
          RUBY
          expect(cop.offenses.size).to eq(1)
          expect(cop.messages)
            .to eq(["Keep a blank line after `#{access_modifier}`."])
        end
      end

      context 'for blocks defined with {}' do
        it 'accepts missing blank line' do
          expect_no_offenses(<<-RUBY.strip_indent)
            included {
              #{access_modifier}

              def test; end
            }
          RUBY
        end

        it 'accepts missing blank line with arguments' do
          expect_no_offenses(<<-RUBY.strip_indent)
            included { |foo|
              #{access_modifier}

              def test; end
            }
          RUBY
        end
      end
    end

    it 'accepts missing blank line when at the end of block' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Test
          def test; end

          #{access_modifier}
        end
      RUBY
    end

    it 'recognizes blank lines with DOS style line endings' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Test\r
        \r
          #{access_modifier}\r
        \r
          def test; end\r
        end\r
      RUBY
    end
  end
end
