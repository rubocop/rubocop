# frozen_string_literal: true

describe RuboCop::Cop::InternalAffairs::DeprecatedPositionalArguments do
  subject(:cop) { described_class.new }

  shared_examples 'auto-correction' do |old_source, new_source|
    it 'auto-corrects' do
      corrected_source = autocorrect_source(old_source)

      expect(corrected_source).to eq(new_source)
    end
  end

  shared_examples 'not correctable' do |source|
    it 'does not auto-correct' do
      corrected_source = autocorrect_source(source)

      expect(corrected_source).to eq(source)
    end
  end

  context 'when #add_offense called with no arguments but node' do
    it "doesn't register an offense" do
      expect_no_offenses(<<-RUBY, 'example_cop.rb')
        add_offense(node)
      RUBY
    end

    context 'when block argument is passed' do
      it "doesn't register an offense" do
        expect_no_offenses(<<-RUBY, 'example_cop.rb')
          add_offense(node, &block)
        RUBY
      end
    end
  end

  context 'when #add_offense called with positional arguments only' do
    it 'registers an offense' do
      expect_offense(<<-RUBY, 'example_cop.rb')
        add_offense(node, :expression, 'message')
                          ^^^^^^^^^^^^^^^^^^^^^^ Use of positional arguments on `#add_offense` is deprecated.
      RUBY
    end

    it_behaves_like(
      'auto-correction',
      "add_offense(node, :selector, 'message')",
      "add_offense(node, location: :selector, message: 'message')"
    )

    context 'when block argument is passed' do
      it 'registers an offense' do
        expect_offense(<<-RUBY, 'example_cop.rb')
          add_offense(node, :expression, 'message', :error, &block)
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use of positional arguments on `#add_offense` is deprecated.
        RUBY
      end

      it_behaves_like(
        'auto-correction',
        "add_offense(node, :selector, 'message', &block)",
        "add_offense(node, location: :selector, message: 'message', &block)"
      )
    end

    context 'when splat argument is passed' do
      it 'registers an offense' do
        expect_offense(<<-RUBY, 'example_cop.rb')
          add_offense(node, :expression, *args, &block)
                            ^^^^^^^^^^^^^^^^^^ Use of positional arguments on `#add_offense` is deprecated.
        RUBY
      end

      it_behaves_like('not correctable',
                      'add_offense(node, :expression, *args, &block)')
    end
  end

  context 'when #add_offense called with keyword arguments only' do
    it "doesn't register an offense" do
      expect_no_offenses(<<-RUBY, 'example_cop.rb')
        add_offense(node, location: :selector, message: 'message')
      RUBY
    end

    context 'when block argument is passed' do
      it "doesn't register an offense" do
        expect_no_offenses(<<-RUBY, 'example_cop.rb')
          add_offense(node, location: :selector, message: 'message', &block)
        RUBY
      end
    end
  end

  context 'when #add_offense called with positional args and kwargs' do
    it 'registers an offense' do
      expect_offense(<<-RUBY, 'example_cop.rb')
        add_offense(node, :selector, message: 'message', severity: :error)
                          ^^^^^^^^^ Use of positional arguments on `#add_offense` is deprecated.
      RUBY
    end

    it_behaves_like(
      'auto-correction',
      "add_offense(node, :selector, message: 'message', severity: :error)",
      "add_offense(node, location: :selector, message: 'message'" \
      ', severity: :error)'
    )

    context 'when block argument is passed' do
      it 'registers an offense' do
        expect_offense(<<-RUBY, 'example_cop.rb')
          add_offense(node, :selector, message: 'message', severity: :error, &block)
                            ^^^^^^^^^ Use of positional arguments on `#add_offense` is deprecated.
        RUBY
      end

      it_behaves_like(
        'auto-correction',
        "add_offense(node, :selector, message: 'message', &block)",
        "add_offense(node, location: :selector, message: 'message', &block)"
      )
    end

    context 'when splat argument is passed' do
      it 'registers an offense' do
        expect_offense(<<-RUBY, 'example_cop.rb')
          add_offense(node, :expression, *args, message: 'message', &block)
                            ^^^^^^^^^^^^^^^^^^ Use of positional arguments on `#add_offense` is deprecated.
        RUBY
      end

      it_behaves_like(
        'not correctable',
        "add_offense(node, :expression, *args, message: 'message', &block)"
      )
    end
  end
end
