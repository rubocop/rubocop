# frozen_string_literal: true

describe RuboCop::Cop::Style::RescueModifier do
  let(:config) do
    RuboCop::Config.new('Layout/IndentationWidth' => {
                          'Width' => 2
                        })
  end

  subject(:cop) { described_class.new(config) }

  it 'registers an offense for modifier rescue' do
    expect_offense(<<-RUBY.strip_indent)
      method rescue handle
      ^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
    RUBY
  end

  it 'registers an offense for modifier rescue around parallel assignment' do
    expect_offense(<<-RUBY.strip_indent)
      a, b = 1, 2 rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
    RUBY
  end

  it 'handles more complex expression with modifier rescue' do
    expect_offense(<<-RUBY.strip_indent)
      method1 or method2 rescue handle
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
    RUBY
  end

  it 'handles modifier rescue in normal rescue' do
    inspect_source(cop, <<-END.strip_indent)
      begin
        test rescue modifier_handle
      rescue
        normal_handle
      end
    END

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.first.line).to eq(2)
    expect(cop.highlights).to eq(['test rescue modifier_handle'])
  end

  it 'handles modifier rescue in a method' do
    inspect_source(cop, <<-END.strip_indent)
      def a_method
        test rescue nil
      end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.first.line).to eq(2)
  end

  it 'does not register an offense for normal rescue' do
    expect_no_offenses(<<-END.strip_indent)
      begin
        test
      rescue
        handle
      end
    END
  end

  it 'does not register an offense for normal rescue with ensure' do
    expect_no_offenses(<<-END.strip_indent)
      begin
        test
      rescue
        handle
      ensure
        cleanup
      end
    END
  end

  it 'does not register an offense for nested normal rescue' do
    expect_no_offenses(<<-END.strip_indent)
      begin
        begin
          test
        rescue
          handle_inner
        end
      rescue
        handle_outer
      end
    END
  end

  context 'when an instance method has implicit begin' do
    it 'accepts normal rescue' do
      expect_no_offenses(<<-END.strip_indent)
        def some_method
          test
        rescue
          handle
        end
      END
    end

    it 'handles modifier rescue in body of implicit begin' do
      inspect_source(cop, <<-END.strip_indent)
        def some_method
          test rescue modifier_handle
        rescue
          normal_handle
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['test rescue modifier_handle'])
    end
  end

  context 'when a singleton method has implicit begin' do
    it 'accepts normal rescue' do
      expect_no_offenses(<<-END.strip_indent)
        def self.some_method
          test
        rescue
          handle
        end
      END
    end

    it 'handles modifier rescue in body of implicit begin' do
      inspect_source(cop, <<-END.strip_indent)
        def self.some_method
          test rescue modifier_handle
        rescue
          normal_handle
        end
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['test rescue modifier_handle'])
    end
  end

  context 'autocorrect' do
    it 'corrects basic rescue modifier' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        foo rescue bar
      END

      expect(new_source).to eq(<<-END.strip_indent)
        begin
          foo
        rescue
          bar
        end
      END
    end

    it 'corrects complex rescue modifier' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        foo || bar rescue bar
      END

      expect(new_source).to eq(<<-END.strip_indent)
        begin
          foo || bar
        rescue
          bar
        end
      END
    end

    it 'corrects rescue modifier nested inside of def' do
      source = <<-END.strip_indent
        def foo
          test rescue modifier_handle
        end
      END
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(<<-END.strip_indent)
        def foo
          begin
            test
          rescue
            modifier_handle
          end
        end
      END
    end

    it 'corrects nested rescue modifier' do
      source = <<-END.strip_indent
        begin
          test rescue modifier_handle
        rescue
          normal_handle
        end
      END
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(<<-END.strip_indent)
        begin
          begin
            test
          rescue
            modifier_handle
          end
        rescue
          normal_handle
        end
      END
    end

    it 'corrects doubled rescue modifiers' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        blah rescue 1 rescue 2
      END

      # Another round of autocorrection is needed
      new_source = autocorrect_source(described_class.new(config), new_source)

      expect(new_source).to eq(<<-END.strip_indent)
        begin
          begin
            blah
          rescue
            1
          end
        rescue
          2
        end
      END
    end
  end

  describe 'excluded file' do
    let(:config) do
      RuboCop::Config.new('Style/RescueModifier' =>
                          { 'Enabled' => true,
                            'Exclude' => ['**/**'] })
    end

    subject(:cop) { described_class.new(config) }

    it 'processes excluded files with issue' do
      inspect_source_file(cop, 'foo rescue bar')

      expect(cop.messages).to be_empty
    end
  end
end
