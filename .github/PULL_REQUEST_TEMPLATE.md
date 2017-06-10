**Replace this text with a summary of the changes in your PR.
The more detailed you are, the better.**

-----------------

Before submitting the PR make sure the following are checked:

* [ ] Wrote [good commit messages][1].
* [ ] Commit message starts with `[Fix #issue-number]` (if the related issue exists).
* [ ] Used the same coding conventions as the rest of the project.
* [ ] Feature branch is up-to-date with `master` (if not - rebase it).
* [ ] Squashed related commits together.
* [ ] Added tests.
* [ ] Added an entry to the [Changelog](../blob/master/CHANGELOG.md) if the new code introduces user-observable changes. See [changelog entry format](../blob/master/CONTRIBUTING.md#changelog-entry-format).
* [ ] All tests(`rake spec`) are passing.
* [ ] The new code doesn't generate RuboCop offenses that are checked by `rake internal_investigation`.
* [ ] The PR relates to *only* one subject with a clear title
  and description in grammatically correct, complete sentences.
* [ ] Updated cop documentation with `rake generate_cops_documentation` (required only when you've added a new cop or changed the configuration/documentation of an existing cop).

[1]: http://chris.beams.io/posts/git-commit/
