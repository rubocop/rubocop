**Replace this text with a summary of the changes in your PR.
The more detailed you are, the better.**

-----------------

Before submitting the PR make sure the following are checked:

* [ ] The PR relates to *only* one subject with a clear title and description in grammatically correct, complete sentences.
* [ ] Wrote [good commit messages][1].
* [ ] Commit message starts with `[Fix #issue-number]` (if the related issue exists).
* [ ] Feature branch is up-to-date with `master` (if not - rebase it).
* [ ] Squashed related commits together.
* [ ] Added tests.
* [ ] Ran `bundle exec rake default`. It executes all tests and runs RuboCop on its own code.
* [ ] Added an entry (file) to the [changelog folder](https://github.com/rubocop/rubocop/blob/master/changelog/) named `{change_type}_{change_description}.md` if the new code introduces user-observable changes. See [changelog entry format](https://github.com/rubocop/rubocop/blob/master/CONTRIBUTING.md#changelog-entry-format) for details.

[1]: https://chris.beams.io/posts/git-commit/
