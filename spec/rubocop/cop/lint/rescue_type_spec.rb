# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RescueType, :config do
  it 'accepts rescue modifier' do
    expect_no_offenses('foo rescue nil')
  end

  it 'accepts rescuing nothing' do
    expect_no_offenses(<<-RUBY)
      begin
        foo
      rescue
        bar
      end
    RUBY
  end

  it 'accepts rescuing a single exception' do
    expect_no_offenses(<<-RUBY)
      def foobar
        foo
      rescue NameError
        bar
      end
    RUBY
  end

  it 'accepts rescuing nothing within a method definition' do
    expect_no_offenses(<<-RUBY)
     def foobar
        foo
      rescue
        bar
      end
    RUBY
  end

  shared_examples 'offenses' do |rescues|
    context 'begin rescue' do
      context "rescuing from #{rescues}" do
        it 'registers an offense and autocorrects' do
          expect_offense(<<~RUBY, rescues: rescues)
            begin
              foo
            rescue %{rescues}
            ^^^^^^^^{rescues} Rescuing from `#{rescues}` will raise a `TypeError` instead of catching the actual exception.
              bar
            end
          RUBY

          expect_correction(<<~RUBY)
            begin
              foo
            rescue
              bar
            end
          RUBY
        end
      end

      context "rescuing from #{rescues} before another exception" do
        it 'registers an offense and autocorrects' do
          expect_offense(<<~RUBY, rescues: rescues)
            begin
              foo
            rescue %{rescues}, StandardError
            ^^^^^^^^{rescues}^^^^^^^^^^^^^^^ Rescuing from `#{rescues}` will raise a `TypeError` instead of catching the actual exception.
              bar
            end
          RUBY

          expect_correction(<<~RUBY)
            begin
              foo
            rescue StandardError
              bar
            end
          RUBY
        end
      end

      context "rescuing from #{rescues} after another exception" do
        it 'registers an offense and autocorrects' do
          expect_offense(<<~RUBY, rescues: rescues)
            begin
              foo
            rescue StandardError, %{rescues}
            ^^^^^^^^^^^^^^^^^^^^^^^{rescues} Rescuing from `#{rescues}` will raise a `TypeError` instead of catching the actual exception.
              bar
            end
          RUBY

          expect_correction(<<~RUBY)
            begin
              foo
            rescue StandardError
              bar
            end
          RUBY
        end
      end
    end

    context 'begin rescue ensure' do
      context "rescuing from #{rescues}" do
        it 'registers an offense and autocorrects' do
          expect_offense(<<~RUBY, rescues: rescues)
            begin
              foo
            rescue %{rescues}
            ^^^^^^^^{rescues} Rescuing from `#{rescues}` will raise a `TypeError` instead of catching the actual exception.
              bar
            ensure
              baz
            end
          RUBY

          expect_correction(<<~RUBY)
            begin
              foo
            rescue
              bar
            ensure
              baz
            end
          RUBY
        end
      end
    end

    context 'def rescue' do
      context "rescuing from #{rescues}" do
        it 'registers an offense and autocorrects' do
          expect_offense(<<~RUBY, rescues: rescues)
            def foobar
              foo
            rescue %{rescues}
            ^^^^^^^^{rescues} Rescuing from `#{rescues}` will raise a `TypeError` instead of catching the actual exception.
              bar
            end
          RUBY

          expect_correction(<<~RUBY)
            def foobar
              foo
            rescue
              bar
            end
          RUBY
        end
      end
    end

    context 'def rescue ensure' do
      context "rescuing from #{rescues}" do
        it 'registers an offense and autocorrects' do
          expect_offense(<<~RUBY, rescues: rescues)
            def foobar
              foo
            rescue %{rescues}
            ^^^^^^^^{rescues} Rescuing from `#{rescues}` will raise a `TypeError` instead of catching the actual exception.
              bar
            ensure
              baz
            end
          RUBY

          expect_correction(<<~RUBY)
            def foobar
              foo
            rescue
              bar
            ensure
              baz
            end
          RUBY
        end
      end
    end
  end

  it_behaves_like 'offenses', 'nil'
  it_behaves_like 'offenses', "'string'"
  it_behaves_like 'offenses', '"#{string}"'
  it_behaves_like 'offenses', '0'
  it_behaves_like 'offenses', '0.0'
  it_behaves_like 'offenses', '[]'
  it_behaves_like 'offenses', '{}'
  it_behaves_like 'offenses', ':symbol'
end
