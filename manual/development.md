## Add a new cop

Use a rake task to generate a cop template.

```sh
$ bundle exec rake new_cop[Category/Name]
created
- lib/rubocop/cop/category/name.rb
- spec/rubocop/cop/category/name_spec.rb

Do 4 steps
- Add an entry to `New feature` section in CHANGELOG.md
  - e.g. Add new `Category/Name` cop. ([@your_id][])
- Add `require 'lib/rubocop/cop/category/name'` into lib/rubocop.rb
- Add an entry into config/enabled.yml or config/disabled.yml
- Implement a new cop to the generated file!
```
