## Add a new cop

Use a rake task to generate a cop template.

```sh
$ bundle exec rake new_cop[Department/Name]
Files created:
  - lib/rubocop/cop/department/name.rb
  - spec/rubocop/cop/department/name_spec.rb
File modified:
  - `require 'rubocop/cop/department/name_cop'` added into lib/rubocop.rb

Do 3 steps:
  1. Add an entry to the "New features" section in CHANGELOG.md,
     e.g. "Add new `Department/Name` cop. ([@your_id][])"
  2. Add an entry into config/enabled.yml or config/disabled.yml
  3. Implement your new cop in the generated file!
```
