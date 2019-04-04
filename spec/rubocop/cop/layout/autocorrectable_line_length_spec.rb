# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::AutocorrectableLineLength, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      'Layout/AutocorrectableLineLength' => {
        'Max' => 40
      }
    )
  end

  context 'hash' do
    context 'when under limit' do
      it 'does not add any offenses' do
        expect_no_offenses(<<-RUBY.strip_indent)
          {foo: 1, bar: "2"}
        RUBY
      end
    end

    context 'when over limit because of a comment' do
      it 'does not add any offenses' do
        expect_no_offenses(<<-RUBY.strip_indent)
          { # supersupersupersupersupersupersupersupersupersupersupersuperlongcomment
            baz: "10000",
            bar: "10000"}
        RUBY
      end
    end

    context 'when over limit and already on multiple lines' do
      it 'does not add any offenses' do
        expect_no_offenses(<<-RUBY.strip_indent)
          {supersupersupersupersupersupersupersupersupersupersupersuperfirstarg: 10,
            baz: "10000",
            bar: "10000"}
        RUBY
      end
    end

    context 'when over limit' do
      it 'adds an offense' do
        expect_offense(<<-RUBY.strip_indent)
          {abc: "100000", def: "100000", ghi: "100000", jkl: "100000", mno: "100000"}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Autocorrectable long line.
        RUBY
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          {abc: "100000", def: "100000", ghi: "100000", jkl: "100000", mno: "100000"}
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          {abc: "100000",\s
          def: "100000", ghi: "100000", jkl: "100000", mno: "100000"}
        RUBY
      end
    end

    context 'when over limit rocket' do
      it 'adds an offense' do
        expect_offense(<<-RUBY.strip_indent)
          {"abc" => "100000", "def" => "100000", "casd" => "100000", "asdf" => "100000"}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Autocorrectable long line.
        RUBY
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          {"abc" => "100000", "def" => "100000", "casd" => "100000", "asdf" => "100000"}
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          {"abc" => "100000",\s
          "def" => "100000", "casd" => "100000", "asdf" => "100000"}
        RUBY
      end
    end

    context 'when over limit rocket symbol' do
      it 'adds an offense' do
        expect_offense(<<-RUBY.strip_indent)
          {:abc => "100000", :asd => "100000", :asd => "100000", :fds => "100000"}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Autocorrectable long line.
        RUBY
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          {:abc => "100000", :asd => "100000", :asd => "100000", :fds => "100000"}
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          {:abc => "100000",\s
          :asd => "100000", :asd => "100000", :fds => "100000"}
        RUBY
      end
    end

    context 'when nested hashes on same line' do
      it 'adds an offense only to outer' do
        expect_offense(<<-RUBY.strip_indent)
          {abc: "100000", def: "100000", ghi: {abc: "100000"}, jkl: "100000", mno: "100000"}
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Autocorrectable long line.
        RUBY
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          {abc: "100000", def: "100000", ghi: {abc: "100000"}, jkl: "100000", mno: "100000"}
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          {abc: "100000",\s
          def: "100000", ghi: {abc: "100000"}, jkl: "100000", mno: "100000"}
        RUBY
      end
    end

    context 'when hash in method call' do
      it 'adds an offense only to outer' do
        expect_offense(<<-RUBY.strip_indent)
          get(
            :index,
            params: {driver_id: driver.id, from_date: "2017-08-18T15:09:04.000Z", to_date: "2017-09-19T15:09:04.000Z"},
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Autocorrectable long line.
            xhr: true)
        RUBY
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          get(
            :index,
            params: {driver_id: driver.id, from_date: "2017-08-18T15:09:04.000Z", to_date: "2017-09-19T15:09:04.000Z"},
            xhr: true)
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          get(
            :index,
            params: {driver_id: driver.id,\s
          from_date: "2017-08-18T15:09:04.000Z", to_date: "2017-09-19T15:09:04.000Z"},
            xhr: true)
        RUBY
      end
    end
  end

  context 'method call' do
    context 'when under limit' do
      it 'does not add any offenses' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo(foo: 1, bar: "2")
        RUBY
      end
    end

    context 'when two together' do
      it 'does not add any offenses' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def baz(bar)
            foo(shipment, actionable_delivery) &&
              bar(shipment, actionable_delivery)
          end
        RUBY
      end
    end

    context 'when over limit' do
      it 'adds an offense' do
        expect_offense(<<-RUBY.strip_indent)
          foo(abc: "100000", def: "100000", ghi: "100000", jkl: "100000", mno: "100000")
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Autocorrectable long line.
        RUBY
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(abc: "100000", def: "100000", ghi: "100000", jkl: "100000", mno: "100000")
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          foo(abc: "100000",\s
          def: "100000", ghi: "100000", jkl: "100000", mno: "100000")
        RUBY
      end
    end

    context 'when call with hash on same line' do
      it 'adds an offense only to outer' do
        expect_offense(<<-RUBY.strip_indent)
            foo(abc: "100000", def: "100000", ghi: {abc: "100000"}, jkl: "100000", mno: "100000")
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Autocorrectable long line.
        RUBY
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo(abc: "100000", def: "100000", ghi: {abc: "100000"}, jkl: "100000", mno: "100000")
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          foo(abc: "100000",\s
          def: "100000", ghi: {abc: "100000"}, jkl: "100000", mno: "100000")
        RUBY
      end
    end

    context 'when two method calls' do
      it 'adds an offense only to outer' do
        expect_offense(<<-RUBY.strip_indent)
          get(1000000, 30000, foo(44440000, 30000, 39999, 19929120312093))
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Autocorrectable long line.
        RUBY
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          get(1000000, 30000, foo(44440000, 30000, 39999, 19929120312093))
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          get(1000000,\s
          30000, foo(44440000, 30000, 39999, 19929120312093))
        RUBY
      end
    end

    context 'when nested method calls allows outer to get broken up first' do
      it 'adds an offense only to outer' do
        expect_no_offenses(<<-RUBY.strip_indent)
          get(1000000,
          foo(44440000, 30000, 39999, 1992), foo(44440000, 30000, 39999, 12093))
        RUBY
      end
    end
  end

  context 'array' do
    context 'when under limit' do
      it 'does not add any offenses' do
        expect_no_offenses(<<-RUBY.strip_indent)
          [1, "2"]
        RUBY
      end
    end

    context 'when already on two lines' do
      it 'does not add any offenses' do
        expect_no_offenses(<<-RUBY.strip_indent)
          [1, "2",
           "3"]
        RUBY
      end
    end

    context 'when over limit' do
      it 'adds an offense' do
        expect_offense(<<-RUBY.strip_indent)
          ["1111", "100000", "100000", "100000", "100000", "100000"]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Autocorrectable long line.
        RUBY
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          ["1111", "100000", "100000", "100000", "100000", "100000"]
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          ["1111",\s
          "100000", "100000", "100000", "100000", "100000"]
        RUBY
      end
    end

    context 'when has inside array' do
      it 'adds an offense only to outer' do
        expect_offense(<<-RUBY.strip_indent)
          ["1111", "100000", "100000", "100000", {abc: "100000", b: "2"}, "100000", "100000"]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Autocorrectable long line.
        RUBY
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          ["1111", "100000", "100000", "100000", {abc: "100000", b: "2"}, "100000", "100000"]
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          ["1111",\s
          "100000", "100000", "100000", {abc: "100000", b: "2"}, "100000", "100000"]
        RUBY
      end
    end

    context 'when two arrays on two lines allows outer to get broken first' do
      it 'adds an offense only to outer' do
        expect_no_offenses(<<-RUBY.strip_indent)
          [1000000, 3912312312999,
            [44440000, 3912312312999, 3912312312999, 1992912031231232131312093],
          100, 100]
        RUBY
      end
    end
  end
end
