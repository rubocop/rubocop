[![Gem Version](https://badge.fury.io/rb/rubocop.svg)](http://badge.fury.io/rb/rubocop)
[![Dependency Status](https://gemnasium.com/bbatsov/rubocop.svg)](https://gemnasium.com/bbatsov/rubocop)
[![Build Status](https://travis-ci.org/bbatsov/rubocop.svg?branch=master)](https://travis-ci.org/bbatsov/rubocop)
[![Coverage Status](https://img.shields.io/codeclimate/coverage/github/bbatsov/rubocop.svg)](https://codeclimate.com/github/bbatsov/rubocop)
[![Code Climate](https://codeclimate.com/github/bbatsov/rubocop/badges/gpa.svg)](https://codeclimate.com/github/bbatsov/rubocop)
[![Inline docs](http://inch-ci.org/github/bbatsov/rubocop.svg)](http://inch-ci.org/github/bbatsov/rubocop)
[![Gratipay Team](https://img.shields.io/gratipay/team/rubocop.svg?maxAge=2592000)](https://gratipay.com/rubocop/)

<p align="center">
  <img src="https://raw.githubusercontent.com/bbatsov/rubocop/master/logo/rubo-logo-horizontal.png" alt="RuboCop Logo"/>
</p>

> Role models are important. <br/>
> -- Officer Alex J. Murphy / RoboCop

**RuboCop** is a Ruby static code analyzer. Out of the box it will
enforce many of the guidelines outlined in the community
[Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide).

Most aspects of its behavior can be tweaked via various
[configuration options](https://github.com/bbatsov/rubocop/blob/master/config/default.yml).

Apart from reporting problems in your code, RuboCop can also
automatically fix some of the problems for you.

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/bbatsov/rubocop?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

You can support my work on RuboCop via
[Salt](https://salt.bountysource.com/teams/rubocop) and
[Gratipay](https://gratipay.com/rubocop/).

[![Support via Gratipay](https://cdn.rawgit.com/gratipay/gratipay-badge/2.1.3/dist/gratipay.png)](https://gratipay.com/rubocop/)

## Installation

**RuboCop**'s installation is pretty standard:

```sh
$ gem install rubocop
```

If you'd rather install RuboCop using `bundler`, don't require it in your `Gemfile`:

```rb
gem 'rubocop', require: false
```

RuboCop's development is moving at a very rapid pace and there are
often backward-incompatible changes between minor releases (since we
haven't reached version 1.0 yet). To prevent an unwanted RuboCop update you
might want to use a conservative version locking in your `Gemfile`:

```rb
gem 'rubocop', '~> 0.40.0', require: false
```

## Quickstart

Just type `rubocop` in a Ruby project's folder and watch the magic happen.

```
$ cd my/cool/ruby/project
$ rubocop
```

## Official manual

You can read a ton more about RuboCop in its [official manual](http://rubocop.readthedocs.io).

## Compatibility

RuboCop supports the following Ruby implementations:

* MRI 1.9.3
* MRI 2.0
* MRI 2.1
* MRI 2.2
* MRI 2.3
* JRuby in 1.9 mode
* Rubinius 2.0+

## Team

Here's a list of RuboCop's core developers:

* [Bozhidar Batsov](https://github.com/bbatsov)
* [Jonas Arvidsson](https://github.com/jonas054)
* [Yuji Nakayama](https://github.com/yujinakayama)
* [Evgeni Dzhelyov](https://github.com/edzhelyov)

## Logo

RuboCop's logo was created by [Dimiter Petrov](https://www.chadomoto.com/). You can find the logo in various
formats [here](https://github.com/bbatsov/rubocop/tree/master/logo).

The logo is licensed under a
[Creative Commons Attribution-NonCommercial 4.0 International License](http://creativecommons.org/licenses/by-nc/4.0/deed.en_GB).

## Contributors

Here's a [list](https://github.com/bbatsov/rubocop/graphs/contributors) of
all the people who have contributed to the development of RuboCop.

I'm extremely grateful to each and every one of them!

If you'd like to contribute to RuboCop, please take the time to go
through our short
[contribution guidelines](CONTRIBUTING.md).

Converting more of the Ruby Style Guide into RuboCop cops is our top
priority right now. Writing a new cop is a great way to dive into RuboCop!

Of course, bug reports and suggestions for improvements are always
welcome. GitHub pull requests are even better! :-)

You can also support my work on RuboCop via
[Salt](https://salt.bountysource.com/teams/rubocop) and
[Gratipay](https://gratipay.com/rubocop/).

[![Support via Gratipay](https://cdn.rawgit.com/gratipay/gratipay-badge/2.1.3/dist/gratipay.png)](https://gratipay.com/rubocop/)

## Changelog

RuboCop's changelog is available [here](CHANGELOG.md).

## Copyright

Copyright (c) 2012-2016 Bozhidar Batsov. See [LICENSE.txt](LICENSE.txt) for
further details.
