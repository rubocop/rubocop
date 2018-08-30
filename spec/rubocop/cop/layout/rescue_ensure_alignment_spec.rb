# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::RescueEnsureAlignment, :config do
  subject(:cop) { described_class.new(config) }

  it 'accepts the modifier form' do
    expect_no_offenses('test rescue nil')
  end

  context 'rescue with begin' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        begin
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `end` at 5, 0.
            error
        end
      RUBY
    end

    it 'corrects the alignment' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        begin
          something
            rescue
            error
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        begin
          something
        rescue
            error
        end
      RUBY
    end
  end

  context 'rescue with def' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def test
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `end` at 5, 0.
            error
        end
      RUBY
    end

    it 'corrects the alignment' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def test
          something
            rescue
            error
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def test
          something
        rescue
            error
        end
      RUBY
    end
  end

  context 'rescue with defs' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def Test.test
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `end` at 5, 0.
            error
        end
      RUBY
    end

    it 'corrects the alignment' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def Test.test
          something
            rescue
            error
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def Test.test
          something
        rescue
            error
        end
      RUBY
    end
  end

  context 'rescue with class' do
    it 'registers an offense when rescue used with class' do
      expect_offense(<<-RUBY.strip_indent)
        class C
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `end` at 5, 0.
            error
        end
      RUBY
    end

    it 'corrects the alignment' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        class C
          something
            rescue
            error
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        class C
          something
        rescue
            error
        end
      RUBY
    end
  end

  context 'rescue with module' do
    it 'registers an offense when rescue used with module' do
      expect_offense(<<-RUBY.strip_indent)
        module M
          something
            rescue
            ^^^^^^ `rescue` at 3, 4 is not aligned with `end` at 5, 0.
            error
        end
      RUBY
    end

    it 'corrects the alignment' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        module M
          something
            rescue
            error
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        module M
          something
        rescue
            error
        end
      RUBY
    end
  end

  context 'ensure with begin' do
    it 'registers an offense when ensure used with begin' do
      expect_offense(<<-RUBY.strip_indent)
        begin
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `end` at 5, 0.
            error
        end
      RUBY
    end

    it 'corrects the alignment' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        begin
          something
            ensure
            error
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        begin
          something
        ensure
            error
        end
      RUBY
    end
  end

  context 'ensure with def' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def test
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `end` at 5, 0.
            error
        end
      RUBY
    end

    it 'corrects the alignment' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def test
          something
            ensure
            error
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def test
          something
        ensure
            error
        end
      RUBY
    end
  end

  context 'ensure with defs' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def Test.test
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `end` at 5, 0.
            error
        end
      RUBY
    end

    it 'corrects the alignment' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def Test.test
          something
            ensure
            error
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def Test.test
          something
        ensure
            error
        end
      RUBY
    end
  end

  context 'ensure with class' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        class C
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `end` at 5, 0.
            error
        end
      RUBY
    end

    it 'corrects the alignment' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        class C
          something
            ensure
            error
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        class C
          something
        ensure
            error
        end
      RUBY
    end
  end

  context 'ensure with module' do
    it 'registers an offense when ensure used with module' do
      expect_offense(<<-RUBY.strip_indent)
        module M
          something
            ensure
            ^^^^^^ `ensure` at 3, 4 is not aligned with `end` at 5, 0.
            error
        end
      RUBY
    end

    it 'corrects the alignment' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        module M
          something
            ensure
            error
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        module M
          something
        ensure
            error
        end
      RUBY
    end
  end

  it 'accepts rescue and ensure on the same line' do
    expect_no_offenses('begin; puts 1; rescue; ensure; puts 2; end')
  end

  it 'accepts correctly aligned rescue' do
    expect_no_offenses(<<-RUBY.strip_indent)
      begin
        something
      rescue
        error
      end
    RUBY
  end

  it 'accepts correctly aligned ensure' do
    expect_no_offenses(<<-RUBY.strip_indent)
      begin
        something
      ensure
        error
      end
    RUBY
  end

  context '>= Ruby 2.5', :ruby25 do
    it 'accepts aligned rescue in do-end block' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [1, 2, 3].each do |el|
          el.to_s
        rescue StandardError => _exception
          next
        end
      RUBY
    end

    it 'accepts aligned rescue in do-end block in a method' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def foo
          [1, 2, 3].each do |el|
            el.to_s
          rescue StandardError => _exception
            next
          end
        end
      RUBY
    end

    context 'rescue with do-end block' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          def foo
            [1, 2, 3].each do |el|
              el.to_s
          rescue StandardError => _exception
          ^^^^^^ `rescue` at 4, 0 is not aligned with `end` at 6, 2.
              next
            end
          end
        RUBY
      end

      it 'corrects the alignment' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          def foo
            [1, 2, 3].each do |el|
              el.to_s
          rescue StandardError => _exception
              next
            end
          end
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          def foo
            [1, 2, 3].each do |el|
              el.to_s
            rescue StandardError => _exception
              next
            end
          end
        RUBY
      end
    end
  end

  describe 'excluded file' do
    subject(:cop) { described_class.new(config) }

    let(:config) do
      RuboCop::Config.new('Layout/RescueEnsureAlignment' =>
                          { 'Enabled' => true,
                            'Exclude' => ['**/**'] })
    end

    it 'processes excluded files with issue' do
      expect_no_offenses(<<-RUBY.strip_indent)
        begin
          foo
        rescue
          bar
        end
      RUBY
    end
  end
end
