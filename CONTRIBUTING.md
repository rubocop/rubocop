# Contributing

If you discover issues, have ideas for improvements or new features,
please report them to the [issue tracker][1] of the repository or
submit a pull request. Please, try to follow these guidelines when you
do so.

## Issue reporting

* Check that the issue has not already been reported.
* Check that the issue has not already been fixed in the latest code
  (a.k.a. `master`).
* Be clear, concise and precise in your description of the problem.
* Open an issue with a descriptive title and a summary in grammatically correct,
  complete sentences.
* Include the output of `rubocop -V`:

```console
$ rubocop -V
1.51.0 (using Parser 2.7.2.0, rubocop-ast 1.1.1, running on ruby 2.7.2) [x86_64-linux]
  - rubocop-performance 1.9.1
  - rubocop-rspec 2.0.0
```

* Include any relevant code to the issue summary.

## Pull requests

* Read [how to properly contribute to open source projects on GitHub][2].
* Fork the project.
* If you're adding or making changes to cops, read the [Development docs](https://docs.rubocop.org/rubocop/development.html)
* Use a topic/feature branch to easily amend a pull request later, if necessary.
* Write [good commit messages][3].
* Use the same coding conventions as the rest of the project.
* Commit and push until you are happy with your contribution.
* If your change has a corresponding open GitHub issue, prefix the commit message with `[Fix #github-issue-number]`.
* Make sure to add tests for it. This is important so I don't break it
  in a future version unintentionally.
* Add an entry to the [Changelog](CHANGELOG.md) by creating a file `changelog/{type}_{some_description}.md`. See [changelog entry format](#changelog-entry-format) for details.
* Please try not to mess with the Rakefile, version, or history. If
  you want to have your own version, or is otherwise necessary, that
  is fine, but please isolate to its own commit so I can cherry-pick
  around it.
* Make sure the test suite is passing and the code you wrote doesn't produce
  RuboCop offenses (usually this is as simple as running `bundle exec rake`).
* [Squash related commits together][5].
* Open a [pull request][4] that relates to *only* one subject with a clear title
  and description in grammatically correct, complete sentences.

### Spell Checking

We are running [misspell](https://github.com/client9/misspell) which is mainly written in
[Golang](https://golang.org/) to check spelling with [GitHub Actions](https://github.com/rubocop/rubocop/blob/master/.github/workflows/spell_checking.yml).
Correct commonly misspelled English words quickly with `misspell`. `misspell` is different from most other spell checkers
because it doesn't use a custom dictionary. You can run `misspell` locally against all files with:

```console
$ find . -type f | xargs ./misspell -i 'enviromnent' -error
```

Notable `misspell` help options or flags are:

* `-i` string: ignore the following corrections, comma separated
* `-w`: Overwrite file with corrections (default is just to display)

We also run [codespell](https://github.com/codespell-project/codespell) with GitHub Actions to check spelling and
[codespell](https://pypi.org/project/codespell/) runs against a [small custom dictionary](https://github.com/rubocop/rubocop/blob/master/codespell.txt).
`codespell` is written in [Python](https://www.python.org/) and you can run it with:

```console
$ codespell --ignore-words=codespell.txt
```

### Linting YAML files

We are running [yamllint](https://github.com/adrienverge/yamllint) for linting YAML files. This is also run by [GitHub Actions](https://github.com/rubocop/rubocop/blob/master/.github/workflows/linting.yml).
`yamllint` is written in [Python](https://www.python.org/) and you can run it with:

```console
$ yamllint .
```

### Creating changelog entries

Changelog entries are just files under the `changelog/` folder that will be merged
into `CHANGELOG.md` at release time. You can create new changelog entries like this:

```console
$ bundle exec rake changelog:new
$ bundle exec rake changelog:fix
$ bundle exec rake changelog:change
```

Those commands correspond to "new feature", "bug-fix" and "changed" entries in the changelog.

Of course, you can also create the changelog entries files manually as well.
Just make sure they are properly named.

### Changelog entry format

Here are a few examples:

```markdown
* [#716](https://github.com/rubocop/rubocop/issues/716): Fixed a regression in the autocorrection logic of `MethodDefParentheses`. ([@bbatsov][])
* [#7542](https://github.com/rubocop/rubocop/pull/7542): **(Breaking)** Move `LineLength` cop from `Metrics` department to `Layout` department. ([@koic][])
```

* Create one file `changelog/{type}_{some_description}.md`, where `type` is `new` (New feature), `fix` or `change`, and `some_description` is unique to avoid conflicts. Task `changelog:fix` (or `:new` or `:change`) can help you.
* Mark it up in [Markdown syntax][6].
* The entry should be a single line, starting with `* ` (an asterisk and a space).
* If the change has a related GitHub issue (e.g. a bug fix for a reported issue), put a link to the issue as `[#123](https://github.com/rubocop/rubocop/issues/123): `.
* Describe the brief of the change. The sentence should end with a punctuation.
* If this is a breaking change, mark it with `**(Breaking)**`.
* At the end of the entry, add an implicit link to your GitHub user page as `([@username][])`.

[1]: https://github.com/rubocop/rubocop/issues
[2]: https://www.gun.io/blog/how-to-github-fork-branch-and-pull-request
[3]: https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[4]: https://help.github.com/articles/about-pull-requests
[5]: http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html
[6]: https://daringfireball.net/projects/markdown/syntax
