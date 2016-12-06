# Rails

## Rails/ActionFilter

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop enforces the consistent use of action filter methods.

The cop is configurable and can enforce the use of the older
something_filter methods or the newer something_action methods.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | action
SupportedStyles | action, filter
Include | app/controllers/\*\*/\*.rb


## Rails/Date

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for the correct use of Date methods,
such as Date.today, Date.current etc.

Using Date.today is dangerous, because it doesn't know anything about
Rails time zone. You must use Time.zone.today instead.

The cop also reports warnings when you are using 'to_time' method,
because it doesn't know about Rails time zone either.

Two styles are supported for this cop. When EnforcedStyle is 'strict'
then the Date methods (today, current, yesterday, tomorrow)
are prohibited and the usage of both 'to_time'
and 'to_time_in_current_zone' is reported as warning.

When EnforcedStyle is 'flexible' then only 'Date.today' is prohibited
and only 'to_time' is reported as warning.

### Example

```ruby
# no offense
Time.zone.today
Time.zone.today - 1.day

# acceptable
Date.current
Date.yesterday

# always reports offense
Date.today
date.to_time

# reports offense only when style is 'strict'
date.to_time_in_current_zone
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | flexible
SupportedStyles | strict, flexible


## Rails/Delegate

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop looks for delegations, that could have been created
automatically with delegate method.

### Example

```ruby
# bad
def bar
  foo.bar
end

# good
delegate :bar, to: :foo

# bad
def foo_bar
  foo.bar
end

# good
delegate :bar, to: :foo, prefix: true

# good
private
def bar
  foo.bar
end
```

## Rails/DelegateAllowBlank

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop looks for delegations that pass :allow_blank as an option
instead of :allow_nil. :allow_blank is not a valid option to pass
to ActiveSupport#delegate.

### Example

```ruby
# bad
delegate :foo, to: :bar, allow_blank: true

# good
delegate :foo, to: :bar, allow_nil: true
```

## Rails/DynamicFindBy

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop checks dynamic `find_by_*` methods.
Use `find_by` instead of dynamic method.
See. https://github.com/bbatsov/rails-style-guide#find_by

### Example

```ruby
# bad
User.find_by_name(name)

# bad
User.find_by_name_and_email(name)

# bad
User.find_by_email!(name)

# good
User.find_by(name: name)

# good
User.find_by(name: name, email: email)

# good
User.find_by!(email: email)
```

### Important attributes

Attribute | Value
--- | ---
Whitelist | find_by_sql


## Rails/EnumUniqueness

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop looks for duplicate values in enum declarations.

### Example

```ruby
# bad
enum status: { active: 0, archived: 0 }

# good
enum status: { active: 0, archived: 1 }

# bad
enum status: [:active, :archived, :active]

# good
enum status: [:active, :archived]
```

### Important attributes

Attribute | Value
--- | ---
Include | app/models/\*\*/\*.rb


## Rails/Exit

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop enforces that 'exit' calls are not used within a rails app.
Valid options are instead to raise an error, break, return or some
other form of stopping execution of current request.

There are two obvious cases where 'exit' is particularly harmful:

- Usage in library code for your application. Even though rails will
rescue from a SystemExit and continue on, unit testing that library
code will result in specs exiting (potentially silently if exit(0)
is used.)
- Usage in application code outside of the web process could result in
the program exiting, which could result in the code failing to run and
do its job.

### Important attributes

Attribute | Value
--- | ---
Include | app/\*\*/\*.rb, config/\*\*/\*.rb, lib/\*\*/\*.rb
Exclude | lib/\*\*/\*.rake


## Rails/FindBy

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop is used to identify usages of `where.first` and
change them to use `find_by` instead.

### Example

```ruby
# bad
User.where(name: 'Bruce').first
User.where(name: 'Bruce').take

# good
User.find_by(name: 'Bruce')
```

### Important attributes

Attribute | Value
--- | ---
Include | app/models/\*\*/\*.rb


## Rails/FindEach

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop is used to identify usages of `all.each` and
change them to use `all.find_each` instead.

### Example

```ruby
# bad
User.all.each

# good
User.all.find_each
```

### Important attributes

Attribute | Value
--- | ---
Include | app/models/\*\*/\*.rb


## Rails/HasAndBelongsToMany

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for the use of the has_and_belongs_to_many macro.

### Important attributes

Attribute | Value
--- | ---
Include | app/models/\*\*/\*.rb


## Rails/HttpPositionalArguments

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop is used to identify usages of http methods
like `get`, `post`, `put`, `path` without the usage of keyword arguments
in your tests and change them to use keyword arguments.

### Example

```ruby
# bad
get :new, { user_id: 1}

# good
get :new, params: { user_id: 1 }
```

### Important attributes

Attribute | Value
--- | ---
Include | spec/\*\*/\*, test/\*\*/\*


## Rails/NotNullColumn

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for add_column call with NOT NULL constraint
in migration file.

### Example

```ruby
# bad
add_column :users, :name, :string, null: false

# good
add_column :users, :name, :string, null: true
add_column :users, :name, :string, null: false, default: ''
```

### Important attributes

Attribute | Value
--- | ---
Include | db/migrate/\*.rb


## Rails/Output

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for the use of output calls like puts and print

### Important attributes

Attribute | Value
--- | ---
Include | app/\*\*/\*.rb, config/\*\*/\*.rb, db/\*\*/\*.rb, lib/\*\*/\*.rb


## Rails/OutputSafety

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for the use of output safety calls like html_safe and
raw.

### Example

```ruby
# bad
"<p>#{text}</p>".html_safe

# good
content_tag(:p, text)

# bad
out = ""
out << content_tag(:li, "one")
out << content_tag(:li, "two")
out.html_safe

# good
out = []
out << content_tag(:li, "one")
out << content_tag(:li, "two")
safe_join(out)
```

## Rails/PluralizationGrammar

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop checks for correct grammar when using ActiveSupport's
core extensions to the numeric classes.

### Example

```ruby
# bad
3.day.ago
1.months.ago

# good
3.days.ago
1.month.ago
```

## Rails/ReadWriteAttribute

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop checks for the use of the read_attribute or
write_attribute methods.

### Example

```ruby
# bad
x = read_attribute(:attr)
write_attribute(:attr, val)

# good
x = self[:attr]
self[:attr] = val
```

### Important attributes

Attribute | Value
--- | ---
Include | app/models/\*\*/\*.rb


## Rails/RequestReferer

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop checks for consistent uses of request.referrer or
request.referrer, depending on configuration.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | referer
SupportedStyles | referer, referrer


## Rails/SafeNavigation

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop converts usages of `try!` to `&.`. It can also be configured
to convert `try`. It will convert code to use safe navigation if the
target Ruby version is set to 2.3+

### Example

```ruby
# ConvertTry: false
  # bad
  foo.try!(:bar)
  foo.try!(:bar, baz)
  foo.try!(:bar) { |e| e.baz }

  foo.try!(:[], 0)

  # good
  foo.try(:bar)
  foo.try(:bar, baz)
  foo.try(:bar) { |e| e.baz }

  foo&.bar
  foo&.bar(baz)
  foo&.bar { |e| e.baz }

# ConvertTry: true
  # bad
  foo.try!(:bar)
  foo.try!(:bar, baz)
  foo.try!(:bar) { |e| e.baz }
  foo.try(:bar)
  foo.try(:bar, baz)
  foo.try(:bar) { |e| e.baz }

  # good
  foo&.bar
  foo&.bar(baz)
  foo&.bar { |e| e.baz }
```

### Important attributes

Attribute | Value
--- | ---
ConvertTry | false


## Rails/SaveBang

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop identifies possible cases where Active Record save! or related
should be used instead of save because the model might have failed to
save and an exception is better than unhandled failure.

This will ignore calls that return a boolean for success if the result
is assigned to a variable or used as the condition in an if/unless
statement.  It will also ignore calls that return a model assigned to a
variable that has a call to `persisted?`. Finally, it will ignore any
call with more than 2 arguments as that is likely not an Active Record
call or a Model.update(id, attributes) call.

### Example

```ruby
# bad
user.save
user.update(name: 'Joe')
user.find_or_create_by(name: 'Joe')
user.destroy

# good
unless user.save
   . . .
end
user.save!
user.update!(name: 'Joe')
user.find_or_create_by!(name: 'Joe')
user.destroy!

user = User.find_or_create_by(name: 'Joe')
unless user.persisted?
   . . .
end
```

## Rails/ScopeArgs

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for scope calls where it was passed
a method (usually a scope) instead of a lambda/proc.

### Example

```ruby
# bad
scope :something, where(something: true)

# good
scope :something, -> { where(something: true) }
```

### Important attributes

Attribute | Value
--- | ---
Include | app/models/\*\*/\*.rb


## Rails/TimeZone

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for the use of Time methods without zone.

Built on top of Ruby on Rails style guide (https://github.com/bbatsov/rails-style-guide#time)
and the article http://danilenko.org/2012/7/6/rails_timezones/ .

Two styles are supported for this cop. When EnforcedStyle is 'strict'
then only use of Time.zone is allowed.

When EnforcedStyle is 'flexible' then it's also allowed
to use Time.in_time_zone.

### Example

```ruby
# always offense
Time.now
Time.parse('2015-03-02 19:05:37')

# no offense
Time.zone.now
Time.zone.parse('2015-03-02 19:05:37')

# no offense only if style is 'acceptable'
Time.current
DateTime.strptime(str, "%Y-%m-%d %H:%M %Z").in_time_zone
Time.at(timestamp).in_time_zone
```

### Important attributes

Attribute | Value
--- | ---
Reference | http://danilenko.org/2012/7/6/rails_timezones
EnforcedStyle | flexible
SupportedStyles | strict, flexible


## Rails/UniqBeforePluck

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

Prefer the use of uniq (or distinct), before pluck instead of after.

The use of uniq before pluck is preferred because it executes within
the database.

This cop has two different enforcement modes. When the EnforcedStyle
is conservative (the default) then only calls to pluck on a constant
(i.e. a model class) before uniq are added as offenses.

When the EnforcedStyle is aggressive then all calls to pluck before
uniq are added as offenses. This may lead to false positives as the cop
cannot distinguish between calls to pluck on an ActiveRecord::Relation
vs a call to pluck on an ActiveRecord::Associations::CollectionProxy.

Autocorrect is disabled by default for this cop since it may generate
false positives.

### Example

```ruby
# bad
Model.pluck(:id).uniq

# good
Model.uniq.pluck(:id)
```
```ruby
# this will return a Relation that pluck is called on
Model.where(...).pluck(:id).uniq

# an association on an instance will return a CollectionProxy
instance.assoc.pluck(:id).uniq
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | conservative
SupportedStyles | conservative, aggressive
AutoCorrect | false


## Rails/Validation

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop checks for the use of old-style attribute validation macros.

### Important attributes

Attribute | Value
--- | ---
Include | app/models/\*\*/\*.rb

