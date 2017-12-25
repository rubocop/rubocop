# Rails

## Rails/ActionFilter

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop enforces the consistent use of action filter methods.

The cop is configurable and can enforce the use of the older
something_filter methods or the newer something_action methods.

If the TargetRailsVersion is set to less than 4.0, the cop will enforce
the use of filter methods.

### Examples

#### EnforcedStyle: action (default)

```ruby
# bad
after_filter :do_stuff
append_around_filter :do_stuff
skip_after_filter :do_stuff

# good
after_action :do_stuff
append_around_action :do_stuff
skip_after_action :do_stuff
```
#### EnforcedStyle: filter

```ruby
# bad
after_action :do_stuff
append_around_action :do_stuff
skip_after_action :do_stuff

# good
after_filter :do_stuff
append_around_filter :do_stuff
skip_after_filter :do_stuff
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `action` | `action`, `filter`
Include | `app/controllers/**/*.rb` | Array

## Rails/ActiveSupportAliases

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks that ActiveSupport aliases to core ruby methods
are not used.

### Examples

```ruby
# good
'some_string'.start_with?('prefix')
'some_string'.end_with?('suffix')
[1, 2, 'a'] << 'b'
[1, 2, 'a'].unshift('b')

# bad
'some_string'.starts_with?('prefix')
'some_string'.ends_with?('suffix')
[1, 2, 'a'].append('b')
[1, 2, 'a'].prepend('b')
```

## Rails/ApplicationJob

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks that jobs subclass ApplicationJob with Rails 5.0.

### Examples

```ruby
# good
class Rails5Job < ApplicationJob
  # ...
end

# bad
class Rails4Job < ActiveJob::Base
  # ...
end
```

## Rails/ApplicationRecord

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks that models subclass ApplicationRecord with Rails 5.0.

### Examples

```ruby
# good
class Rails5Model < ApplicationRecord
  # ...
end

# bad
class Rails4Model < ActiveRecord::Base
  # ...
end
```

## Rails/Blank

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks for code that can be changed to `blank?`.
Settings:
  NilOrEmpty: Convert checks for `nil` or `empty?` to `blank?`
  NotPresent: Convert usages of not `present?` to `blank?`
  UnlessPresent: Convert usages of `unless` `present?` to `blank?`

### Examples

```ruby
# NilOrEmpty: true
  # bad
  foo.nil? || foo.empty?
  foo == nil || foo.empty?

  # good
  foo.blank?

# NotPresent: true
  # bad
  !foo.present?

  # good
  foo.blank?

# UnlessPresent: true
  # bad
  something unless foo.present?
  unless foo.present?
    something
  end

  # good
  something if foo.blank?
  if foo.blank?
    something
  end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
NilOrEmpty | `true` | Boolean
NotPresent | `true` | Boolean
UnlessPresent | `true` | Boolean

## Rails/CreateTableWithTimestamps

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks the migration for which timestamps are not included
when creating a new table.
In many cases, timestamps are useful information and should be added.

### Examples

```ruby
# bad
create_table :users

# bad
create_table :users do |t|
  t.string :name
  t.string :email
end

# good
create_table :users do |t|
  t.string :name
  t.string :email

  t.timestamps
end

# good
create_table :users do |t|
  t.string :name
  t.string :email

  t.datetime :created_at, default: -> { 'CURRENT_TIMESTAMP' }
end

# good
create_table :users do |t|
  t.string :name
  t.string :email

  t.datetime :updated_at, default: -> { 'CURRENT_TIMESTAMP' }
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `db/migrate/*.rb` | Array

## Rails/Date

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

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

### Examples

#### EnforcedStyle: strict

```ruby
# bad
Date.current
Date.yesterday
Date.today
date.to_time
date.to_time_in_current_zone

# good
Time.zone.today
Time.zone.today - 1.day
```
#### EnforcedStyle: flexible (default)

```ruby
# bad
Date.today
date.to_time

# good
Time.zone.today
Time.zone.today - 1.day
Date.current
Date.yesterday
date.to_time_in_current_zone
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `flexible` | `strict`, `flexible`

## Rails/Delegate

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop looks for delegations that could have been created
automatically with the `delegate` method.

Safe navigation `&.` is ignored because Rails' `allow_nil`
option checks not just for nil but also delegates if nil
responds to the delegated method.

The `EnforceForPrefixed` option (defaulted to `true`) means that
using the target object as a prefix of the method name
without using the `delegate` method will be a violation.
When set to `false`, this case is legal.

### Examples

```ruby
# bad
def bar
  foo.bar
end

# good
delegate :bar, to: :foo

# good
def bar
  foo&.bar
end

# good
private
def bar
  foo.bar
end

# EnforceForPrefixed: true
# bad
def foo_bar
  foo.bar
end

# good
delegate :bar, to: :foo, prefix: true

# EnforceForPrefixed: false
# good
def foo_bar
  foo.bar
end

# good
delegate :bar, to: :foo, prefix: true
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforceForPrefixed | `true` | Boolean

## Rails/DelegateAllowBlank

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop looks for delegations that pass :allow_blank as an option
instead of :allow_nil. :allow_blank is not a valid option to pass
to ActiveSupport#delegate.

### Examples

```ruby
# bad
delegate :foo, to: :bar, allow_blank: true

# good
delegate :foo, to: :bar, allow_nil: true
```

## Rails/DynamicFindBy

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks dynamic `find_by_*` methods.
Use `find_by` instead of dynamic method.
See. https://github.com/bbatsov/rails-style-guide#find_by

### Examples

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

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Whitelist | `find_by_sql` | Array

### References

* [https://github.com/bbatsov/rails-style-guide#find_by](https://github.com/bbatsov/rails-style-guide#find_by)

## Rails/EnumUniqueness

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop looks for duplicate values in enum declarations.

### Examples

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

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/models/**/*.rb` | Array

## Rails/EnvironmentComparison

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks that Rails.env is compared using `.production?`-like
methods instead of equality against a string or symbol.

### Examples

```ruby
# bad
Rails.env == 'production'

# bad, always returns false
Rails.env == :test

# good
Rails.env.production?
```

## Rails/Exit

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

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

### Examples

```ruby
# bad
exit(0)

# good
raise 'a bad error has happened'
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/**/*.rb`, `config/**/*.rb`, `lib/**/*.rb` | Array
Exclude | `lib/**/*.rake` | Array

## Rails/FilePath

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop is used to identify usages of file path joining process
to use `Rails.root.join` clause.

### Examples

```ruby
# bad
Rails.root.join('app/models/goober')
File.join(Rails.root, 'app/models/goober')
"#{Rails.root}/app/models/goober"

# good
Rails.root.join('app', 'models', 'goober')
```

## Rails/FindBy

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop is used to identify usages of `where.first` and
change them to use `find_by` instead.

### Examples

```ruby
# bad
User.where(name: 'Bruce').first
User.where(name: 'Bruce').take

# good
User.find_by(name: 'Bruce')
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/models/**/*.rb` | Array

### References

* [https://github.com/bbatsov/rails-style-guide#find_by](https://github.com/bbatsov/rails-style-guide#find_by)

## Rails/FindEach

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop is used to identify usages of `all.each` and
change them to use `all.find_each` instead.

### Examples

```ruby
# bad
User.all.each

# good
User.all.find_each
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/models/**/*.rb` | Array

### References

* [https://github.com/bbatsov/rails-style-guide#find-each](https://github.com/bbatsov/rails-style-guide#find-each)

## Rails/HasAndBelongsToMany

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for the use of the has_and_belongs_to_many macro.

### Examples

```ruby
# bad
# has_and_belongs_to_many :ingredients

# good
# has_many :ingredients, through: :recipe_ingredients
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/models/**/*.rb` | Array

### References

* [https://github.com/bbatsov/rails-style-guide#has-many-through](https://github.com/bbatsov/rails-style-guide#has-many-through)

## Rails/HasManyOrHasOneDependent

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop looks for `has_many` or `has_one` associations that don't
specify a `:dependent` option.
It doesn't register an offense if `:through` option was specified.

### Examples

```ruby
# bad
class User < ActiveRecord::Base
  has_many :comments
  has_one :avatar
end

# good
class User < ActiveRecord::Base
  has_many :comments, dependent: :restrict_with_exception
  has_one :avatar, dependent: :destroy
  has_many :patients, through: :appointments
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/models/**/*.rb` | Array

### References

* [https://github.com/bbatsov/rails-style-guide#has_many-has_one-dependent-option](https://github.com/bbatsov/rails-style-guide#has_many-has_one-dependent-option)

## Rails/HttpPositionalArguments

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop is used to identify usages of http methods like `get`, `post`,
`put`, `patch` without the usage of keyword arguments in your tests and
change them to use keyword args.  This cop only applies to Rails >= 5 .
If you are running Rails < 5 you should disable the
Rails/HttpPositionalArguments cop or set your TargetRailsVersion in your
.rubocop.yml file to 4.0, etc.

### Examples

```ruby
# bad
get :new, { user_id: 1}

# good
get :new, params: { user_id: 1 }
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `spec/**/*`, `test/**/*` | Array

## Rails/InverseOf

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop looks for has_(one|many) and belongs_to associations where
ActiveRecord can't automatically determine the inverse association
because of a scope or the options used. This can result in unnecessary
queries in some circumstances. `:inverse_of` must be manually specified
for associations to work in both ways, or set to `false` to opt-out.

### Examples

```ruby
# good
class Blog < ApplicationRecord
  has_many :posts
end

class Post < ApplicationRecord
  belongs_to :blog
end
```
```ruby
# bad
class Blog < ApplicationRecord
  has_many :posts, -> { order(published_at: :desc) }
end

class Post < ApplicationRecord
  belongs_to :blog
end

# good
class Blog < ApplicationRecord
  has_many(:posts,
    -> { order(published_at: :desc) },
    inverse_of: :blog
  )
end

class Post < ApplicationRecord
  belongs_to :blog
end

# good
class Blog < ApplicationRecord
  with_options inverse_of: :blog do
    has_many :posts, -> { order(published_at: :desc) }
  end
end

class Post < ApplicationRecord
  belongs_to :blog
end
```
```ruby
# bad
class Picture < ApplicationRecord
  belongs_to :imageable, polymorphic: true
end

class Employee < ApplicationRecord
  has_many :pictures, as: :imageable
end

class Product < ApplicationRecord
  has_many :pictures, as: :imageable
end

# good
class Picture < ApplicationRecord
  belongs_to :imageable, polymorphic: true
end

class Employee < ApplicationRecord
  has_many :pictures, as: :imageable, inverse_of: :imageable
end

class Product < ApplicationRecord
  has_many :pictures, as: :imageable, inverse_of: :imageable
end
```
```ruby
# bad
# However, RuboCop can not detect this pattern...
class Physician < ApplicationRecord
  has_many :appointments
  has_many :patients, through: :appointments
end

class Appointment < ApplicationRecord
  belongs_to :physician
  belongs_to :patient
end

class Patient < ApplicationRecord
  has_many :appointments
  has_many :physicians, through: :appointments
end

# good
class Physician < ApplicationRecord
  has_many :appointments
  has_many :patients, through: :appointments
end

class Appointment < ApplicationRecord
  belongs_to :physician, inverse_of: :appointments
  belongs_to :patient, inverse_of: :appointments
end

class Patient < ApplicationRecord
  has_many :appointments
  has_many :physicians, through: :appointments
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/models/**/*.rb` | Array

## Rails/LexicallyScopedActionFilter

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks that methods specified in the filter's `only`
or `except` options are explicitly defined in the controller.

You can specify methods of superclass or methods added by mixins
on the filter, but these confuse developers. If you specify methods
where are defined on another controller, you should define the filter
in that controller.

### Examples

```ruby
# bad
class LoginController < ApplicationController
  before_action :require_login, only: %i[index settings logout]

  def index
  end
end

# good
class LoginController < ApplicationController
  before_action :require_login, only: %i[index settings logout]

  def index
  end

  def settings
  end

  def logout
  end
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/controllers/**/*.rb` | Array

### References

* [https://github.com/bbatsov/rails-style-guide#lexically-scoped-action-filter](https://github.com/bbatsov/rails-style-guide#lexically-scoped-action-filter)

## Rails/NotNullColumn

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for add_column call with NOT NULL constraint
in migration file.

### Examples

```ruby
# bad
add_column :users, :name, :string, null: false
add_reference :products, :category, null: false

# good
add_column :users, :name, :string, null: true
add_column :users, :name, :string, null: false, default: ''
add_reference :products, :category
add_reference :products, :category, null: false, default: 1
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `db/migrate/*.rb` | Array

## Rails/Output

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for the use of output calls like puts and print

### Examples

```ruby
# bad
puts 'A debug message'
pp 'A debug message'
print 'A debug message'

# good
Rails.logger.debug 'A debug message'
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/**/*.rb`, `config/**/*.rb`, `db/**/*.rb`, `lib/**/*.rb` | Array

## Rails/OutputSafety

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for the use of output safety calls like html_safe,
raw, and safe_concat. These methods do not escape content. They
simply return a SafeBuffer containing the content as is. Instead,
use safe_join to join content and escape it and concat to
concatenate content and escape it, ensuring its safety.

### Examples

```ruby
user_content = "<b>hi</b>"

# bad
"<p>#{user_content}</p>".html_safe
# => ActiveSupport::SafeBuffer "<p><b>hi</b></p>"

# good
content_tag(:p, user_content)
# => ActiveSupport::SafeBuffer "<p>&lt;b&gt;hi&lt;/b&gt;</p>"

# bad
out = ""
out << "<li>#{user_content}</li>"
out << "<li>#{user_content}</li>"
out.html_safe
# => ActiveSupport::SafeBuffer "<li><b>hi</b></li><li><b>hi</b></li>"

# good
out = []
out << content_tag(:li, user_content)
out << content_tag(:li, user_content)
safe_join(out)
# => ActiveSupport::SafeBuffer
#    "<li>&lt;b&gt;hi&lt;/b&gt;</li><li>&lt;b&gt;hi&lt;/b&gt;</li>"

# bad
out = "<h1>trusted content</h1>".html_safe
out.safe_concat(user_content)
# => ActiveSupport::SafeBuffer "<h1>trusted_content</h1><b>hi</b>"

# good
out = "<h1>trusted content</h1>".html_safe
out.concat(user_content)
# => ActiveSupport::SafeBuffer
#    "<h1>trusted_content</h1>&lt;b&gt;hi&lt;/b&gt;"

# safe, though maybe not good style
out = "trusted content"
result = out.concat(user_content)
# => String "trusted content<b>hi</b>"
# because when rendered in ERB the String will be escaped:
# <%= result %>
# => trusted content&lt;b&gt;hi&lt;/b&gt;

# bad
(user_content + " " + content_tag(:span, user_content)).html_safe
# => ActiveSupport::SafeBuffer "<b>hi</b> <span><b>hi</b></span>"

# good
safe_join([user_content, " ", content_tag(:span, user_content)])
# => ActiveSupport::SafeBuffer
#    "&lt;b&gt;hi&lt;/b&gt; <span>&lt;b&gt;hi&lt;/b&gt;</span>"
```

## Rails/PluralizationGrammar

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for correct grammar when using ActiveSupport's
core extensions to the numeric classes.

### Examples

```ruby
# bad
3.day.ago
1.months.ago

# good
3.days.ago
1.month.ago
```

## Rails/Presence

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks code that can be written more easily using
`Object#presence` defined by Active Support.

### Examples

```ruby
# bad
a.present? ? a : nil

# bad
!a.present? ? nil : a

# bad
a.blank? ? nil : a

# bad
!a.blank? ? a : nil

# good
a.presence
```
```ruby
# bad
a.present? ? a : b

# bad
!a.present? ? b : a

# bad
a.blank? ? b : a

# bad
!a.blank? ? a : b

# good
a.presence || b
```

## Rails/Present

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks for code that can be changed to `blank?`.
Settings:
  NotNilAndNotEmpty: Convert checks for not `nil` and `not empty?`
                     to `present?`
  NotBlank: Convert usages of not `blank?` to `present?`
  UnlessBlank: Convert usages of `unless` `blank?` to `if` `present?`

### Examples

```ruby
# NotNilAndNotEmpty: true
  # bad
  !foo.nil? && !foo.empty?
  foo != nil && !foo.empty?
  !foo.blank?

  # good
  foo.present?

# NotBlank: true
  # bad
  !foo.blank?
  not foo.blank?

  # good
  foo.present?

# UnlessBlank: true
  # bad
  something unless foo.blank?

  # good
  something if  foo.present?
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
NotNilAndNotEmpty | `true` | Boolean
NotBlank | `true` | Boolean
UnlessBlank | `true` | Boolean

## Rails/ReadWriteAttribute

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for the use of the read_attribute or
write_attribute methods.

### Examples

```ruby
# bad
x = read_attribute(:attr)
write_attribute(:attr, val)

# good
x = self[:attr]
self[:attr] = val
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/models/**/*.rb` | Array

### References

* [https://github.com/bbatsov/rails-style-guide#read-attribute](https://github.com/bbatsov/rails-style-guide#read-attribute)

## Rails/RedundantReceiverInWithOptions

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for redundant receiver in `with_options`.
Receiver is implicit from Rails 4.2 or higher.

### Examples

```ruby
# bad
class Account < ApplicationRecord
  with_options dependent: :destroy do |assoc|
    assoc.has_many :customers
    assoc.has_many :products
    assoc.has_many :invoices
    assoc.has_many :expenses
  end
end

# good
class Account < ApplicationRecord
  with_options dependent: :destroy do
    has_many :customers
    has_many :products
    has_many :invoices
    has_many :expenses
  end
end
```
```ruby
# bad
with_options options: false do |merger|
  merger.invoke(merger.something)
end

# good
with_options options: false do
  invoke(something)
end

# good
client = Client.new
with_options options: false do |merger|
  client.invoke(merger.something, something)
end

# ok
# When `with_options` includes a block, all scoping scenarios
# cannot be evaluated. Thus, it is ok to include the explicit
# receiver.
with_options options: false do |merger|
  merger.invoke
  with_another_method do |another_receiver|
    merger.invoke(another_receiver)
  end
end
```

## Rails/RelativeDateConstant

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks whether constant value isn't relative date.
Because the relative date will be evaluated only once.

### Examples

```ruby
# bad
class SomeClass
  EXPIRED_AT = 1.week.since
end

# good
class SomeClass
  def self.expired_at
    1.week.since
  end
end
```

## Rails/RequestReferer

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for consistent uses of `request.referer` or
`request.referrer`, depending on the cop's configuration.

### Examples

#### EnforcedStyle: referer (default)

```ruby
# bad
request.referrer

# good
request.referer
```
#### EnforcedStyle: referrer

```ruby
# bad
request.referer

# good
request.referrer
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `referer` | `referer`, `referrer`

## Rails/ReversibleMigration

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks whether the change method of the migration file is
reversible.

### Examples

```ruby
# bad
def change
  change_table :users do |t|
    t.remove :name
  end
end

# good
def change
  create_table :users do |t|
    t.string :name
  end
end

# good
def change
  reversible do |dir|
    change_table :users do |t|
      dir.up do
        t.column :name, :string
      end

      dir.down do
        t.remove :name
      end
    end
  end
end
```
```ruby
# drop_table

# bad
def change
  drop_table :users
end

# good
def change
  drop_table :users do |t|
    t.string :name
  end
end
```
```ruby
# change_column_default

# bad
def change
  change_column_default(:suppliers, :qualification, 'new')
end

# good
def change
  change_column_default(:posts, :state, from: nil, to: "draft")
end
```
```ruby
# remove_column

# bad
def change
  remove_column(:suppliers, :qualification)
end

# good
def change
  remove_column(:suppliers, :qualification, :string)
end
```
```ruby
# remove_foreign_key

# bad
def change
  remove_foreign_key :accounts, column: :owner_id
end

# good
def change
  remove_foreign_key :accounts, :branches
end
```
```ruby
# change_table

# bad
def change
  change_table :users do |t|
    t.remove :name
    t.change_default :authorized, 1
    t.change :price, :string
  end
end

# good
def change
  change_table :users do |t|
    t.string :name
  end
end

# good
def change
  reversible do |dir|
    change_table :users do |t|
      dir.up do
        t.change :price, :string
      end

      dir.down do
        t.change :price, :integer
      end
    end
  end
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `db/migrate/*.rb` | Array

### References

* [https://github.com/bbatsov/rails-style-guide#reversible-migration](https://github.com/bbatsov/rails-style-guide#reversible-migration)
* [http://api.rubyonrails.org/classes/ActiveRecord/Migration/CommandRecorder.html](http://api.rubyonrails.org/classes/ActiveRecord/Migration/CommandRecorder.html)

## Rails/SafeNavigation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop converts usages of `try!` to `&.`. It can also be configured
to convert `try`. It will convert code to use safe navigation if the
target Ruby version is set to 2.3+

### Examples

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

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
ConvertTry | `false` | Boolean

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

### Examples

```ruby
# bad
user.save
user.update(name: 'Joe')
user.find_or_create_by(name: 'Joe')
user.destroy

# good
unless user.save
  # ...
end
user.save!
user.update!(name: 'Joe')
user.find_or_create_by!(name: 'Joe')
user.destroy!

user = User.find_or_create_by(name: 'Joe')
unless user.persisted?
  # ...
end
```

### References

* [https://github.com/bbatsov/rails-style-guide#save-bang](https://github.com/bbatsov/rails-style-guide#save-bang)

## Rails/ScopeArgs

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for scope calls where it was passed
a method (usually a scope) instead of a lambda/proc.

### Examples

```ruby
# bad
scope :something, where(something: true)

# good
scope :something, -> { where(something: true) }
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/models/**/*.rb` | Array

## Rails/SkipsModelValidations

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for the use of methods which skip
validations which are listed in
http://guides.rubyonrails.org/active_record_validations.html#skipping-validations

### Examples

```ruby
# bad
Article.first.decrement!(:view_count)
DiscussionBoard.decrement_counter(:post_count, 5)
Article.first.increment!(:view_count)
DiscussionBoard.increment_counter(:post_count, 5)
person.toggle :active
product.touch
Billing.update_all("category = 'authorized', author = 'David'")
user.update_attribute(website: 'example.com')
user.update_columns(last_request_at: Time.current)
Post.update_counters 5, comment_count: -1, action_count: 1

# good
user.update_attributes(website: 'example.com')
FileUtils.touch('file')
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Blacklist | `decrement!`, `decrement_counter`, `increment!`, `increment_counter`, `toggle!`, `touch`, `update_all`, `update_attribute`, `update_column`, `update_columns`, `update_counters` | Array

### References

* [http://guides.rubyonrails.org/active_record_validations.html#skipping-validations](http://guides.rubyonrails.org/active_record_validations.html#skipping-validations)

## Rails/TimeZone

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for the use of Time methods without zone.

Built on top of Ruby on Rails style guide (https://github.com/bbatsov/rails-style-guide#time)
and the article http://danilenko.org/2012/7/6/rails_timezones/ .

Two styles are supported for this cop. When EnforcedStyle is 'strict'
then only use of Time.zone is allowed.

When EnforcedStyle is 'flexible' then it's also allowed
to use Time.in_time_zone.

### Examples

```ruby
# always offense
Time.now
Time.parse('2015-03-02 19:05:37')

# no offense
Time.zone.now
Time.zone.parse('2015-03-02 19:05:37')

# no offense only if style is 'flexible'
Time.current
DateTime.strptime(str, "%Y-%m-%d %H:%M %Z").in_time_zone
Time.at(timestamp).in_time_zone
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `flexible` | `strict`, `flexible`

### References

* [https://github.com/bbatsov/rails-style-guide#time](https://github.com/bbatsov/rails-style-guide#time)
* [http://danilenko.org/2012/7/6/rails_timezones](http://danilenko.org/2012/7/6/rails_timezones)

## Rails/UniqBeforePluck

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

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

### Examples

```ruby
# bad
Model.pluck(:id).uniq

# good
Model.uniq.pluck(:id)
```
```ruby
# this will return a Relation that pluck is called on
Model.where(cond: true).pluck(:id).uniq

# an association on an instance will return a CollectionProxy
instance.assoc.pluck(:id).uniq
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `conservative` | `conservative`, `aggressive`
AutoCorrect | `false` | Boolean

## Rails/UnknownEnv

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks that environments called with `Rails.env` predicates
exist.

### Examples

```ruby
# bad
Rails.env.proudction?

# good
Rails.env.production?
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Environments | `development`, `test`, `production` | Array

## Rails/Validation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for the use of old-style attribute validation macros.

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/models/**/*.rb` | Array
