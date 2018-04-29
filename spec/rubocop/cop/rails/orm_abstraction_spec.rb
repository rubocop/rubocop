# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ORMAbstraction do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when breaking ORM abstraction in a where clause' do
    expect_offense(<<-RUBY.strip_indent)
      users.where(baz: 'cow', role_id: role.id, foo: 'bar')
                              ^^^^^^^^^^^^^^^^ prefer `role: role`.
    RUBY
  end

  it 'registers an offense when breaking ORM abstraction in a create clause' do
    expect_offense(<<-RUBY.strip_indent)
      users.create(baz: 'cow', role_id: role.id, foo: 'bar')
                               ^^^^^^^^^^^^^^^^ prefer `role: role`.
    RUBY
  end

  it 'registers an offense when breaking ORM abstraction in a new clause' do
    expect_offense(<<-RUBY.strip_indent)
      users.new(baz: 'cow', role_id: role.id, foo: 'bar')
                            ^^^^^^^^^^^^^^^^ prefer `role: role`.
    RUBY
  end

  it 'registers an offense when breaking ORM abstraction using string interpolation' do
    expect_offense(<<-RUBY.strip_indent)
      users.new(baz: 'cow', "\#{foo}_id" => role.id, foo: 'bar')
                            ^^^^^^^^^^^^^^^^^^^^^^ prefer `"\#{foo}" => role`.
    RUBY
  end

  it 'registers an offense when chaining methods on the receiver' do
    expect_offense(<<-RUBY.strip_indent)
      users.new(baz: 'cow', role_id: user2.role.id, foo: 'bar')
                            ^^^^^^^^^^^^^^^^^^^^^^ prefer `role: user2.role`.
    RUBY
  end

  it 'does not register an offense otherwise' do
    expect_no_offenses(<<-RUBY.strip_indent)
      users.where(
        baz_id: baz_id,
        role: role,
        foo_id: params[:foo_id],
        foo_uuid: uuid
      )
    RUBY
  end

  it 'autocorrect `role_id: role.id` to `role: role`' do
    source = "users.where(baz_id: cow.id, role_id: role.id, foo: 'bar')"
    autocorrect = "users.where(baz: cow, role: role, foo: 'bar')"

    expect(autocorrect_source(source)).to eq(autocorrect)
  end

  it 'autocorrect `role_id => role.id` to `role => role`' do
    source = "users.where('baz_id' => cow.id, \"x_\#{role}_id\" => role.id, 'foo' => 'bar')"
    autocorrect = "users.where('baz' => cow, \"x_\#{role}\" => role, 'foo' => 'bar')"

    expect(autocorrect_source(source)).to eq(autocorrect)
  end
end
