# Rails

## Rails/ActionFilter

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.19 | -

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

## Rails/ActiveRecordAliases

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.53 | -

Checks that ActiveRecord aliases are not used. The direct method names
are more clear and easier to read.

### Examples

```ruby
#bad
Book.update_attributes!(author: 'Alice')

#good
Book.update!(author: 'Alice')
```

## Rails/ActiveSupportAliases

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.48 | -

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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.49 | -

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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.49 | -

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

## Rails/AssertNot

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.56 | -

Use `assert_not` instead of `assert !`.

### Examples

```ruby
# bad
assert !x

# good
assert_not x
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `**/test/**/*` | Array

## Rails/BelongsTo

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.62 | -

This cop looks for belongs_to associations where we control whether the
association is required via the deprecated `required` option instead.

Since Rails 5, belongs_to associations are required by default and this
can be controlled through the use of `optional: true`.

From the release notes:

    belongs_to will now trigger a validation error by default if the
    association is not present. You can turn this off on a
    per-association basis with optional: true. Also deprecate required
    option in favor of optional for belongs_to. (Pull Request)

In the case that the developer is doing `required: false`, we
definitely want to autocorrect to `optional: true`.

However, without knowing whether they've set overridden the default
value of `config.active_record.belongs_to_required_by_default`, we
can't say whether it's safe to remove `required: true` or whether we
should replace it with `optional: false` (or, similarly, remove a
superfluous `optional: false`). Therefore, in the cases we're using
`required: true`, we'll simply invert it to `optional: false` and the
user can remove depending on their defaults.

### Examples

```ruby
# bad
class Post < ApplicationRecord
  belongs_to :blog, required: false
end

# good
class Post < ApplicationRecord
  belongs_to :blog, optional: true
end

# bad
class Post < ApplicationRecord
  belongs_to :blog, required: true
end

# good
class Post < ApplicationRecord
  belongs_to :blog, optional: false
end
```

## Rails/Blank

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.48 | -

This cop checks for code that can be written with simpler conditionals
using `Object#blank?` defined by Active Support.

### Examples

#### NilOrEmpty: true (default)

```ruby
# Converts usages of `nil? || empty?` to `blank?`

# bad
foo.nil? || foo.empty?
foo == nil || foo.empty?

# good
foo.blank?
```
#### NotPresent: true (default)

```ruby
# Converts usages of `!present?` to `blank?`

# bad
!foo.present?

# good
foo.blank?
```
#### UnlessPresent: true (default)

```ruby
# Converts usages of `unless present?` to `if blank?`

# bad
something unless foo.present?

# good
something if foo.blank?

# bad
unless foo.present?
  something
end

# good
if foo.blank?
  something
end

# good
def blank?
  !present?
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
NilOrEmpty | `true` | Boolean
NotPresent | `true` | Boolean
UnlessPresent | `true` | Boolean

## Rails/BulkChangeTable

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.57 | -

This Cop checks whether alter queries are combinable.
If combinable queries are detected, it suggests to you
to use `change_table` with `bulk: true` instead.
This option causes the migration to generate a single
ALTER TABLE statement combining multiple column alterations.

The `bulk` option is only supported on the MySQL and
the PostgreSQL (5.2 later) adapter; thus it will
automatically detect an adapter from `development` environment
in `config/database.yml` when the `Database` option is not set.
If the adapter is not `mysql2` or `postgresql`,
this Cop ignores offenses.

### Examples

```ruby
# bad
def change
  add_column :users, :name, :string, null: false
  add_column :users, :nickname, :string

  # ALTER TABLE `users` ADD `name` varchar(255) NOT NULL
  # ALTER TABLE `users` ADD `nickname` varchar(255)
end

# good
def change
  change_table :users, bulk: true do |t|
    t.string :name, null: false
    t.string :nickname
  end

  # ALTER TABLE `users` ADD `name` varchar(255) NOT NULL,
  #                     ADD `nickname` varchar(255)
end
```
```ruby
# bad
def change
  change_table :users do |t|
    t.string :name, null: false
    t.string :nickname
  end
end

# good
def change
  change_table :users, bulk: true do |t|
    t.string :name, null: false
    t.string :nickname
  end
end

# good
# When you don't want to combine alter queries.
def change
  change_table :users, bulk: false do |t|
    t.string :name, null: false
    t.string :nickname
  end
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Database | `<none>` | `mysql`, `postgresql`
Include | `db/migrate/*.rb` | Array

## Rails/CreateTableWithTimestamps

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.52 | -

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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.30 | 0.33

This cop checks for the correct use of Date methods,
such as Date.today, Date.current etc.

Using `Date.today` is dangerous, because it doesn't know anything about
Rails time zone. You must use `Time.zone.today` instead.

The cop also reports warnings when you are using `to_time` method,
because it doesn't know about Rails time zone either.

Two styles are supported for this cop. When EnforcedStyle is 'strict'
then the Date methods `today`, `current`, `yesterday`, and `tomorrow`
are prohibited and the usage of both `to_time`
and 'to_time_in_current_zone' are reported as warning.

When EnforcedStyle is 'flexible' then only `Date.today` is prohibited
and only `to_time` is reported as warning.

### Examples

#### EnforcedStyle: strict

```ruby
# bad
Date.current
Date.yesterday
Date.today
date.to_time

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
date.in_time_zone
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `flexible` | `strict`, `flexible`

## Rails/Delegate

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.21 | 0.50

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
```
#### EnforceForPrefixed: true (default)

```ruby
# bad
def foo_bar
  foo.bar
end

# good
delegate :bar, to: :foo, prefix: true
```
#### EnforceForPrefixed: false

```ruby
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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.44 | -

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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.44 | -

This cop checks dynamic `find_by_*` methods.
Use `find_by` instead of dynamic method.
See. https://github.com/rubocop-hq/rails-style-guide#find_by

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

* [https://github.com/rubocop-hq/rails-style-guide#find_by](https://github.com/rubocop-hq/rails-style-guide#find_by)

## Rails/EnumUniqueness

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.46 | -

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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.52 | -

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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.41 | -

This cop enforces that `exit` calls are not used within a rails app.
Valid options are instead to raise an error, break, return, or some
other form of stopping execution of current request.

There are two obvious cases where `exit` is particularly harmful:

- Usage in library code for your application. Even though Rails will
rescue from a `SystemExit` and continue on, unit testing that library
code will result in specs exiting (potentially silently if `exit(0)`
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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.47 | 0.57

This cop is used to identify usages of file path joining process
to use `Rails.root.join` clause. It is used to add uniformity when
joining paths.

### Examples

#### EnforcedStyle: arguments (default)

```ruby
# bad
Rails.root.join('app/models/goober')
File.join(Rails.root, 'app/models/goober')
"#{Rails.root}/app/models/goober"

# good
Rails.root.join('app', 'models', 'goober')
```
#### EnforcedStyle: slashes

```ruby
# bad
Rails.root.join('app', 'models', 'goober')
File.join(Rails.root, 'app/models/goober')
"#{Rails.root}/app/models/goober"

# good
Rails.root.join('app/models/goober')
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `arguments` | `slashes`, `arguments`

## Rails/FindBy

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.30 | -

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

* [https://github.com/rubocop-hq/rails-style-guide#find_by](https://github.com/rubocop-hq/rails-style-guide#find_by)

## Rails/FindEach

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.30 | -

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

* [https://github.com/rubocop-hq/rails-style-guide#find-each](https://github.com/rubocop-hq/rails-style-guide#find-each)

## Rails/HasAndBelongsToMany

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.12 | -

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

* [https://github.com/rubocop-hq/rails-style-guide#has-many-through](https://github.com/rubocop-hq/rails-style-guide#has-many-through)

## Rails/HasManyOrHasOneDependent

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.50 | -

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

* [https://github.com/rubocop-hq/rails-style-guide#has_many-has_one-dependent-option](https://github.com/rubocop-hq/rails-style-guide#has_many-has_one-dependent-option)

## Rails/HttpPositionalArguments

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.44 | -

This cop is used to identify usages of http methods like `get`, `post`,
`put`, `patch` without the usage of keyword arguments in your tests and
change them to use keyword args. This cop only applies to Rails >= 5.
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

## Rails/HttpStatus

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.54 | -

Enforces use of symbolic or numeric value to define HTTP status.

### Examples

#### EnforcedStyle: symbolic (default)

```ruby
# bad
render :foo, status: 200
render json: { foo: 'bar' }, status: 200
render plain: 'foo/bar', status: 304
redirect_to root_url, status: 301

# good
render :foo, status: :ok
render json: { foo: 'bar' }, status: :ok
render plain: 'foo/bar', status: :not_modified
redirect_to root_url, status: :moved_permanently
```
#### EnforcedStyle: numeric

```ruby
# bad
render :foo, status: :ok
render json: { foo: 'bar' }, status: :not_found
render plain: 'foo/bar', status: :not_modified
redirect_to root_url, status: :moved_permanently

# good
render :foo, status: 200
render json: { foo: 'bar' }, status: 404
render plain: 'foo/bar', status: 304
redirect_to root_url, status: 301
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `symbolic` | `numeric`, `symbolic`

## Rails/IgnoredSkipActionFilterOption

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.63 | -

This cop checks that `if` and `only` (or `except`) are not used together
as options of `skip_*` action filter.

The `if` option will be ignored when `if` and `only` are used together.
Similarly, the `except` option will be ignored when `if` and `except`
are used together.

### Examples

```ruby
# bad
class MyPageController < ApplicationController
  skip_before_action :login_required,
    only: :show, if: :trusted_origin?
end

# good
class MyPageController < ApplicationController
  skip_before_action :login_required,
    if: -> { trusted_origin? && action_name == "show" }
end
```
```ruby
# bad
class MyPageController < ApplicationController
  skip_before_action :login_required,
    except: :admin, if: :trusted_origin?
end

# good
class MyPageController < ApplicationController
  skip_before_action :login_required,
    if: -> { trusted_origin? && action_name != "admin" }
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/controllers/**/*.rb` | Array

### References

* [https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-_normalize_callback_options](https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-_normalize_callback_options)

## Rails/InverseOf

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.52 | -

This cop looks for has_(one|many) and belongs_to associations where
Active Record can't automatically determine the inverse association
because of a scope or the options used. Using the blog with order scope
example below, traversing the a Blog's association in both directions
with `blog.posts.first.blog` would cause the `blog` to be loaded from
the database twice.

`:inverse_of` must be manually specified for Active Record to use the
associated object in memory, or set to `false` to opt-out. Note that
setting `nil` does not stop Active Record from trying to determine the
inverse automatically, and is not considered a valid value for this.

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
           inverse_of: :blog)
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

# good
# When you don't want to use the inverse association.
class Blog < ApplicationRecord
  has_many(:posts,
           -> { order(published_at: :desc) },
           inverse_of: false)
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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.52 | -

This cop checks that methods specified in the filter's `only` or
`except` options are defined within the same class or module.

You can technically specify methods of superclass or methods added
by mixins on the filter, but these confuse developers. If you
specify methods that are defined in other classes or modules, you
should define the filter in that class or module.

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
```ruby
# bad
module FooMixin
  extend ActiveSupport::Concern

  included do
    before_action proc { authenticate }, only: :foo
  end
end

# good
module FooMixin
  extend ActiveSupport::Concern

  included do
    before_action proc { authenticate }, only: :foo
  end

  def foo
    # something
  end
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/controllers/**/*.rb` | Array

### References

* [https://github.com/rubocop-hq/rails-style-guide#lexically-scoped-action-filter](https://github.com/rubocop-hq/rails-style-guide#lexically-scoped-action-filter)

## Rails/LinkToBlank

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.62 | -

This cop checks for calls to `link_to` that contain a
`target: '_blank'` but no `rel: 'noopener'`. This can be a security
risk as the loaded page will have control over the previous page
and could change its location for phishing purposes.

### Examples

```ruby
# bad
link_to 'Click here', url, target: '_blank'

# good
link_to 'Click here', url, target: '_blank', rel: 'noopener'
```

### References

* [https://mathiasbynens.github.io/rel-noopener/](https://mathiasbynens.github.io/rel-noopener/)

## Rails/NotNullColumn

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.43 | -

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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.15 | 0.19

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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.41 | -

This cop checks for the use of output safety calls like `html_safe`,
`raw`, and `safe_concat`. These methods do not escape content. They
simply return a SafeBuffer containing the content as is. Instead,
use `safe_join` to join content and escape it and concat to
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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.35 | -

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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.52 | -

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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.48 | -

This cop checks for code that can be written with simpler conditionals
using `Object#present?` defined by Active Support.

simpler conditionals.

### Examples

#### NotNilAndNotEmpty: true (default)

```ruby
# Converts usages of `!nil? && !empty?` to `present?`

# bad
!foo.nil? && !foo.empty?

# bad
foo != nil && !foo.empty?

# good
foo.present?
```
#### NotBlank: true (default)

```ruby
# Converts usages of `!blank?` to `present?`

# bad
!foo.blank?

# bad
not foo.blank?

# good
foo.present?
```
#### UnlessBlank: true (default)

```ruby
# Converts usages of `unless blank?` to `if present?`

# bad
something unless foo.blank?

# good
something if foo.present?
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
NotNilAndNotEmpty | `true` | Boolean
NotBlank | `true` | Boolean
UnlessBlank | `true` | Boolean

## Rails/ReadWriteAttribute

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.20 | 0.29

This cop checks for the use of the `read_attribute` or `write_attribute`
methods and recommends square brackets instead.

If an attribute is missing from the instance (for example, when
initialized by a partial `select`) then `read_attribute`
will return nil, but square brackets will raise
an `ActiveModel::MissingAttributeError`.

Explicitly raising an error in this situation is preferable, and that
is why rubocop recommends using square brackets.

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

* [https://github.com/rubocop-hq/rails-style-guide#read-attribute](https://github.com/rubocop-hq/rails-style-guide#read-attribute)

## Rails/RedundantReceiverInWithOptions

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.52 | -

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

## Rails/ReflectionClassName

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.64 | -

This cop checks if the value of the option `class_name`, in
the definition of a reflection is a string.

### Examples

```ruby
# bad
has_many :accounts, class_name: Account
has_many :accounts, class_name: Account.name

# good
has_many :accounts, class_name: 'Account'
```

## Rails/RefuteMethods

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.56 | -

Use `assert_not` methods instead of `refute` methods.

### Examples

```ruby
# bad
refute false
refute_empty [1, 2, 3]
refute_equal true, false

# good
assert_not false
assert_not_empty [1, 2, 3]
assert_not_equal true, false
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `**/test/**/*` | Array

## Rails/RelativeDateConstant

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.48 | 0.59

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

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
AutoCorrect | `false` | Boolean

## Rails/RequestReferer

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.41 | -

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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.47 | -

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

* [https://github.com/rubocop-hq/rails-style-guide#reversible-migration](https://github.com/rubocop-hq/rails-style-guide#reversible-migration)
* [https://api.rubyonrails.org/classes/ActiveRecord/Migration/CommandRecorder.html](https://api.rubyonrails.org/classes/ActiveRecord/Migration/CommandRecorder.html)

## Rails/SafeNavigation

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.43 | -

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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Disabled | Yes | Yes  | 0.42 | 0.59

This cop identifies possible cases where Active Record save! or related
should be used instead of save because the model might have failed to
save and an exception is better than unhandled failure.

This will allow:
- update or save calls, assigned to a variable,
  or used as a condition in an if/unless/case statement.
- create calls, assigned to a variable that then has a
  call to `persisted?`.
- calls if the result is explicitly returned from methods and blocks,
  or provided as arguments.
- calls whose signature doesn't look like an ActiveRecord
  persistence method.

By default it will also allow implicit returns from methods and blocks.
that behavior can be turned off with `AllowImplicitReturn: false`.

You can permit receivers that are giving false positives with
`AllowedReceivers: []`

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

def save_user
  return user.save
end
```
#### AllowImplicitReturn: true (default)

```ruby
# good
users.each { |u| u.save }

def save_user
  user.save
end
```
#### AllowImplicitReturn: false

```ruby
# bad
users.each { |u| u.save }
def save_user
  user.save
end

# good
users.each { |u| u.save! }

def save_user
  user.save!
end

def save_user
  return user.save
end
```
#### AllowedReceivers: ['merchant.customers', 'Service::Mailer']

```ruby
# bad
merchant.create
customers.builder.save
Mailer.create

module Service::Mailer
  self.create
end

# good
merchant.customers.create
MerchantService.merchant.customers.destroy
Service::Mailer.update(message: 'Message')
::Service::Mailer.update
Services::Service::Mailer.update(message: 'Message')
Service::Mailer::update
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
AllowImplicitReturn | `true` | Boolean
AllowedReceivers | `[]` | Array

### References

* [https://github.com/rubocop-hq/rails-style-guide#save-bang](https://github.com/rubocop-hq/rails-style-guide#save-bang)

## Rails/ScopeArgs

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.19 | -

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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.47 | 0.60

This cop checks for the use of methods which skip
validations which are listed in
https://guides.rubyonrails.org/active_record_validations.html#skipping-validations

Methods may be ignored from this rule by configuring a `Whitelist`.

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
user.update_attribute(:website, 'example.com')
user.update_columns(last_request_at: Time.current)
Post.update_counters 5, comment_count: -1, action_count: 1

# good
user.update(website: 'example.com')
FileUtils.touch('file')
```
#### Whitelist: ["touch"]

```ruby
# bad
DiscussionBoard.decrement_counter(:post_count, 5)
DiscussionBoard.increment_counter(:post_count, 5)
person.toggle :active

# good
user.touch
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Blacklist | `decrement!`, `decrement_counter`, `increment!`, `increment_counter`, `toggle!`, `touch`, `update_all`, `update_attribute`, `update_column`, `update_columns`, `update_counters` | Array
Whitelist | `[]` | Array

### References

* [https://guides.rubyonrails.org/active_record_validations.html#skipping-validations](https://guides.rubyonrails.org/active_record_validations.html#skipping-validations)

## Rails/TimeZone

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.30 | 0.33

This cop checks for the use of Time methods without zone.

Built on top of Ruby on Rails style guide (https://github.com/rubocop-hq/rails-style-guide#time)
and the article http://danilenko.org/2012/7/6/rails_timezones/ .

Two styles are supported for this cop. When EnforcedStyle is 'strict'
then only use of Time.zone is allowed.

When EnforcedStyle is 'flexible' then it's also allowed
to use Time.in_time_zone.

### Examples

#### EnforcedStyle: strict

```ruby
# `strict` means that `Time` should be used with `zone`.

# bad
Time.now
Time.parse('2015-03-02 19:05:37')

# bad
Time.current
Time.at(timestamp).in_time_zone

# good
Time.zone.now
Time.zone.parse('2015-03-02 19:05:37')
```
#### EnforcedStyle: flexible (default)

```ruby
# `flexible` allows usage of `in_time_zone` instead of `zone`.

# bad
Time.now
Time.parse('2015-03-02 19:05:37')

# good
Time.zone.now
Time.zone.parse('2015-03-02 19:05:37')

# good
Time.current
Time.at(timestamp).in_time_zone
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `flexible` | `strict`, `flexible`

### References

* [https://github.com/rubocop-hq/rails-style-guide#time](https://github.com/rubocop-hq/rails-style-guide#time)
* [http://danilenko.org/2012/7/6/rails_timezones](http://danilenko.org/2012/7/6/rails_timezones)

## Rails/UniqBeforePluck

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.40 | 0.47

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

#### EnforcedStyle: conservative (default)

```ruby
# bad
Model.pluck(:id).uniq

# good
Model.uniq.pluck(:id)
```
#### EnforcedStyle: aggressive

```ruby
# bad
# this will return a Relation that pluck is called on
Model.where(cond: true).pluck(:id).uniq

# bad
# an association on an instance will return a CollectionProxy
instance.assoc.pluck(:id).uniq

# bad
Model.pluck(:id).uniq

# good
Model.uniq.pluck(:id)
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `conservative` | `conservative`, `aggressive`
AutoCorrect | `false` | Boolean

## Rails/UnknownEnv

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.51 | -

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

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.9 | 0.41

This cop checks for the use of old-style attribute validation macros.

### Examples

```ruby
# bad
validates_acceptance_of :foo
validates_confirmation_of :foo
validates_exclusion_of :foo
validates_format_of :foo
validates_inclusion_of :foo
validates_length_of :foo
validates_numericality_of :foo
validates_presence_of :foo
validates_size_of :foo
validates_uniqueness_of :foo

# good
validates :foo, acceptance: true
validates :foo, confirmation: true
validates :foo, exclusion: true
validates :foo, format: true
validates :foo, inclusion: true
validates :foo, length: true
validates :foo, numericality: true
validates :foo, presence: true
validates :foo, size: true
validates :foo, uniqueness: true
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/models/**/*.rb` | Array
