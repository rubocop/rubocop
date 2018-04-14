# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Performance::RegexpMatch, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples :offense do |name, code, correction|
    it "registers an offense for #{name}" do
      inspect_source(code)

      expect(cop.offenses.size).to eq(1)
    end

    it "corrects #{name}" do
      new_source = autocorrect_source(code)

      expect(new_source).to eq(correction)
    end
  end

  shared_examples :all_legacy_match_methods do |name, cond, correction|
    include_examples :offense, "#{name} in if condition", <<-RUBY, <<-RUBY2
      if #{cond}
        do_something
      end
    RUBY
      if #{correction}
        do_something
      end
    RUBY2

    include_examples :offense, "#{name} in unless condition", <<-RUBY, <<-RUBY2
      unless #{cond}
        do_something
      end
    RUBY
      unless #{correction}
        do_something
      end
    RUBY2

    include_examples :offense, "#{name} in elsif condition", <<-RUBY, <<-RUBY2
      if cond
        do_something
      elsif #{cond}
        do_something2
      end
    RUBY
      if cond
        do_something
      elsif #{correction}
        do_something2
      end
    RUBY2

    include_examples :offense, "#{name} in case condition", <<-RUBY, <<-RUBY2
      case
      when #{cond}
        do_something
      end
    RUBY
      case
      when #{correction}
        do_something
      end
    RUBY2

    include_examples :offense, "#{name} in ternary operator", <<-RUBY, <<-RUBY2
      #{cond} ? do_something : do_something2
    RUBY
      #{correction} ? do_something : do_something2
    RUBY2

    include_examples :offense, "#{name} in method definition",
                     <<-RUBY, <<-RUBY2
      def foo
        if #{cond}
          do_something
        end
      end
    RUBY
      def foo
        if #{correction}
          do_something
        end
      end
    RUBY2

    %w[
      $& $' $` $~ $1 $2 $100
      $MATCH
      Regexp.last_match Regexp.last_match(1)
    ].each do |var|
      it "accepts #{name} in method with #{var}" do
        expect_no_offenses(<<-RUBY)
          def foo
            if #{cond}
              do_something(#{var})
            end
          end
        RUBY
      end

      it "accepts #{name} in a class method with #{var}" do
        expect_no_offenses(<<-RUBY)
          def self.foo
            if #{cond}
              do_something(#{var})
            end
          end
        RUBY
      end

      it "accepts #{name} in method with #{var} before if" do
        expect_no_offenses(<<-RUBY)
          def foo
            return #{var} if #{cond}
          end
        RUBY
      end

      it "accepts #{name} in method with #{var} before unless" do
        expect_no_offenses(<<-RUBY)
          def foo
            return #{var} unless #{cond}
          end
        RUBY
      end

      it "accepts #{name} in method with #{var} in block" do
        expect_no_offenses(<<-RUBY)
          def foo
            bar do
              if #{cond}
                do_something
              end
            end
            puts #{var}
          end
        RUBY
      end

      include_examples :offense,
                       "#{name} in method before `#{var}`", <<-RUBY, <<-RUBY2
        def foo
          do_something(#{var})
          if #{cond}
            do_something2
          end
        end
      RUBY
        def foo
          do_something(#{var})
          if #{correction}
            do_something2
          end
        end
      RUBY2

      include_examples :offense,
                       "#{name} in method, `#{var}` is in other method",
                       <<-RUBY, <<-RUBY2
        def foo
          if #{cond}
            do_something2
          end
        end

        def bar
          do_something(#{var})
        end
      RUBY
        def foo
          if #{correction}
            do_something2
          end
        end

        def bar
          do_something(#{var})
        end
      RUBY2

      include_examples :offense,
                       "#{name} in class method, `#{var}` is in other method",
                       <<-RUBY, <<-RUBY2
        def self.foo
          if #{cond}
            do_something2
          end
        end

        def self.bar
          do_something(#{var})
        end
      RUBY
        def self.foo
          if #{correction}
            do_something2
          end
        end

        def self.bar
          do_something(#{var})
        end
      RUBY2

      include_examples :offense,
                       "#{name} in class, `#{var}` is in method",
                       <<-RUBY, <<-RUBY2
        class Foo
          if #{cond}
            do_something
          end

          def foo
            #{var}
          end
        end
      RUBY
        class Foo
          if #{correction}
            do_something
          end

          def foo
            #{var}
          end
        end
      RUBY2

      include_examples :offense,
                       "#{name} in module, `#{var}` is in method",
                       <<-RUBY, <<-RUBY2
        module Foo
          if #{cond}
            do_something
          end

          def foo
            #{var}
          end
        end
      RUBY
        module Foo
          if #{correction}
            do_something
          end

          def foo
            #{var}
          end
        end
      RUBY2

      include_examples :offense, "#{name}, #{var} reference is overrided",
                       <<-RUBY, <<-RUBY2
        if #{cond}
          do_something
          #{cond}
          #{var}
        end
      RUBY
        if #{correction}
          do_something
          #{cond}
          #{var}
        end
      RUBY2
    end
  end

  context 'target ruby version < 2.4', :ruby23 do
    it 'accepts match method call in if condition' do
      expect_no_offenses(<<-RUBY)
        if foo.match(/re/)
          do_something
        end
      RUBY
    end

    it 'accepts match method call in elsif condition' do
      expect_no_offenses(<<-RUBY)
        if cond
          do_something
        elsif foo.match(/re/)
          do_something2
        end
      RUBY
    end
  end

  context 'target ruby version >= 2.4', :ruby24 do
    it_behaves_like(:all_legacy_match_methods, 'String#match method call',
                    '"foo".match(re)', '"foo".match?(re)')
    it_behaves_like(:all_legacy_match_methods,
                    'String#match method call with position',
                    '"foo".match(re, 1)', '"foo".match?(re, 1)')
    it_behaves_like(:all_legacy_match_methods, 'Regexp#match method call',
                    '/re/.match(foo)', '/re/.match?(foo)')
    it_behaves_like(:all_legacy_match_methods,
                    'Regexp#match method call with position',
                    '/re/.match(foo, 1)', '/re/.match?(foo, 1)')
    it_behaves_like(:all_legacy_match_methods, 'Symbol#match method call',
                    ':foo.match(re)', ':foo.match?(re)')
    it_behaves_like(:all_legacy_match_methods,
                    'Symbol#match method call with position',
                    ':foo.match(re, 1)', ':foo.match?(re, 1)')
    it_behaves_like(:all_legacy_match_methods,
                    'match method call for a variable',
                    'foo.match(/re/)', 'foo.match?(/re/)')
    it_behaves_like(:all_legacy_match_methods,
                    'match method call for a variable with position',
                    'foo.match(/re/, 1)', 'foo.match?(/re/, 1)')
    it_behaves_like(:all_legacy_match_methods, 'matching by =~`',
                    '/re/ =~ foo', '/re/.match?(foo)')
    it_behaves_like(:all_legacy_match_methods, 'matching by =~`',
                    'foo =~ /re/', '/re/.match?(foo)')
    it_behaves_like(:all_legacy_match_methods, 'matching by =~`',
                    '"foo" =~ re', '"foo".match?(re)')
    it_behaves_like(:all_legacy_match_methods, 'matching by =~`',
                    're =~ "foo"', '"foo".match?(re)')
    it_behaves_like(:all_legacy_match_methods, 'matching by =~`',
                    ':foo =~ re', ':foo.match?(re)')
    it_behaves_like(:all_legacy_match_methods, 'matching by =~`',
                    're =~ :foo', ':foo.match?(re)')
    it_behaves_like(:all_legacy_match_methods, 'matching by =~`',
                    're =~ foo', 're&.match?(foo)')
    it_behaves_like(:all_legacy_match_methods, 'matching by =~`',
                    're =~ FOO', 'FOO.match?(re)')
    it_behaves_like(:all_legacy_match_methods, 'matching by =~`',
                    'FOO =~ re', 'FOO.match?(re)')
    it_behaves_like(:all_legacy_match_methods, 'matching by !~`',
                    '/re/ !~ foo', '!/re/.match?(foo)')
    it_behaves_like(:all_legacy_match_methods, 'matching by !~`',
                    'foo !~ /re/', '!/re/.match?(foo)')
    it_behaves_like(:all_legacy_match_methods, 'matching by !~`',
                    '"foo" !~ re', '!"foo".match?(re)')
    it_behaves_like(:all_legacy_match_methods, 'matching by !~`',
                    're !~ "foo"', '!"foo".match?(re)')
    it_behaves_like(:all_legacy_match_methods, 'matching by !~`',
                    ':foo !~ re', '!:foo.match?(re)')
    it_behaves_like(:all_legacy_match_methods, 'matching by !~`',
                    're !~ :foo', '!:foo.match?(re)')
    it_behaves_like(:all_legacy_match_methods, 'matching by !~`',
                    're !~ foo', '!re&.match?(foo)')
    it_behaves_like(:all_legacy_match_methods, 'matching by !~`',
                    're !~ FOO', '!FOO.match?(re)')
    it_behaves_like(:all_legacy_match_methods, 'matching by !~`',
                    'FOO !~ re', '!FOO.match?(re)')
    it_behaves_like(:all_legacy_match_methods, 'matching by ===`',
                    '/re/ === foo', '/re/.match?(foo)')
    it_behaves_like(:all_legacy_match_methods, 'matching by ===`',
                    '/re/i === foo', '/re/i.match?(foo)')

    it 'accepts Regexp#match? method call' do
      expect_no_offenses(<<-RUBY)
        if /re/.match?(str)
          do_something
        end
      RUBY
    end

    it 'accepts String#match? method call' do
      expect_no_offenses(<<-RUBY)
        if str.match?(/re/)
          do_something
        end
      RUBY
    end

    it 'accepts match without arguments' do
      expect_no_offenses(<<-RUBY)
        code if match
      RUBY
    end

    it 'accepts =~ with assignment' do
      expect_no_offenses(<<-RUBY)
        if /alias_(?<alias_id>.*)/ =~ something
          do_something
        end
      RUBY
    end
  end
end
