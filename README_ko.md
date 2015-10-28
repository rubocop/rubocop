[![Gem Version](https://badge.fury.io/rb/rubocop.svg)](http://badge.fury.io/rb/rubocop)
[![Dependency Status](https://gemnasium.com/bbatsov/rubocop.svg)](https://gemnasium.com/bbatsov/rubocop)
[![Build Status](https://travis-ci.org/bbatsov/rubocop.svg?branch=master)](https://travis-ci.org/bbatsov/rubocop)
[![Coverage Status](http://img.shields.io/coveralls/bbatsov/rubocop/master.svg)](https://coveralls.io/r/bbatsov/rubocop)
[![Code Climate](https://codeclimate.com/github/bbatsov/rubocop/badges/gpa.svg)](https://codeclimate.com/github/bbatsov/rubocop)
[![Inline docs](http://inch-ci.org/github/bbatsov/rubocop.svg)](http://inch-ci.org/github/bbatsov/rubocop)

<p align="center">
  <img src="https://raw.github.com/bbatsov/rubocop/master/logo/rubo-logo-horizontal.png" alt="RuboCop Logo"/>
</p>

> Role models are important. <br/>
> -- Officer Alex J. Murphy / RoboCop


**RuboCop**은 루비정적 분석 소프트웨어이며 커뮤니티 [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide)을 기준으로 정적분석을 수행합니다.

다양한
[configuration options](https://github.com/bbatsov/rubocop/blob/master/config/default.yml)을 사용해 RuboCop의 동작을 설정할 수 있습니다.

코드 정적 분석은 물론 일부 오류들은 자동으로 수정할 수도 있습니다.

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/bbatsov/rubocop?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[Salt](https://salt.bountysource.com/teams/rubocop) 혹은
[Gratipay](https://www.gratipay.com/rubocop)를 통해 이 프로젝트를 지원할 수 있습니다.

[![Support via Gratipay](https://cdn.rawgit.com/gratipay/gratipay-badge/2.1.3/dist/gratipay.png)](https://gratipay.com/rubocop)

**이 문서는 RuboCop의 'master' 브랜치를 기준으로 작성되었습니다. 이 문서에 소개된 몇몇 기능 및 설정들은 오래된 버전에서는 동작하지 않을 수 있습니다(현재 stable release를 포함해). 특정한 RuboCop release 버전 문서를 확인하고 싶은 경우 해당 git tag(예 v0.30.0)을 사용하시기 바랍니다.**

- [Installation](#installation)
- [Basic Usage](#basic-usage)
    - [Cops](#cops)
        - [Style](#style)
        - [Lint](#lint)
        - [Metrics](#metrics)
        - [Rails](#rails)
- [Configuration](#configuration)
    - [Inheritance](#inheritance)
    - [Defaults](#defaults)
    - [Including/Excluding files](#includingexcluding-files)
    - [Generic configuration parameters](#generic-configuration-parameters)
    - [Automatically Generated Configuration](#automatically-generated-configuration)
- [Disabling Cops within Source Code](#disabling-cops-within-source-code)
- [Formatters](#formatters)
    - [Progress Formatter (default)](#progress-formatter-default)
    - [Clang Style Formatter](#clang-style-formatter)
    - [Fuubar Style Formatter](#fuubar-style-formatter)
    - [Emacs Style Formatter](#emacs-style-formatter)
    - [Simple Formatter](#simple-formatter)
    - [File List Formatter](#file-list-formatter)
    - [JSON Formatter](#json-formatter)
    - [Offense Count Formatter](#offense-count-formatter)
    - [HTML Formatter](#html-formatter)
- [Compatibility](#compatibility)
- [Editor integration](#editor-integration)
    - [Emacs](#emacs)
    - [Vim](#vim)
    - [Sublime Text](#sublime-text)
    - [Brackets](#brackets)
    - [TextMate2](#textmate2)
    - [Atom](#atom)
    - [LightTable](#lighttable)
    - [RubyMine](#rubymine)
    - [Other Editors](#other-editors)
- [Git pre-commit hook integration](#git-pre-commit-hook-integration)
- [Guard integration](#guard-integration)
- [Rake integration](#rake-integration)
- [Caching](#caching)
    - [Cache Validity](#cache-validity)
    - [Enabling and Disabling the Cache](#enabling-and-disabling-the-cache)
    - [Cache Path](#cache-path)
    - [Cache Pruning](#cache-pruning)
- [Extensions](#extensions)
  - [Loading Extensions](#loading-extensions)
  - [Custom Cops](#custom-cops)
    - [Known Custom Cops](#known-custom-cops)
  - [Custom Formatters](#custom-formatters)
    - [Creating Custom Formatter](#creating-custom-formatter)
    - [Using Custom Formatter in Command Line](#using-custom-formatter-in-command-line)
- [Team](#team)
- [Logo](#logo)
- [Contributors](#contributors)
- [Mailing List](#mailing-list)
- [Changelog](#changelog)
- [Copyright](#copyright)

## Installation

**RuboCop**은 일반적인 gem install 절차에 따라 설치 가능할 수 있습니다.

```
$ gem install rubocop
```

`bundler`를 사용해 설치를 진행하고 싶다면, `Gemfile`에 다음의 코드를 추가합니다:

```
gem 'rubocop', require: false
```

## Basic Usage

파리미터 없이 `rubocop` 명령어를 실행하면 현재 디렉토리(및 그 하위 디렉토리)에 포함된 모드 Ruby 파일들에 대한 정적분석을 수행합니다:

```
$ rubocop
```

정적분석을 수행할 대상 파일의 리스트나 디렉토리를 파라미터로 설정할 수 있습니다:

```
$ rubocop app spec lib/something.rb
```

RuboCop을 실행해 보겠습니다. 다음 루비 소스 프로젝트 코드를 사용한다고 가정합니다:

```ruby
def badName
  if something
    test
    end
end
```

위의 프로젝트에 RoboCop을 실행하면(파일 이름은 `test.rb`라고 가정) 다음과 같은 보고서가 표시됩니다:

```
Inspecting 1 file
W

Offenses:

test.rb:1:5: C: Use snake_case for method names.
def badName
    ^^^^^^^
test.rb:2:3: C: Use a guard clause instead of wrapping the code inside a conditional expression.
  if something
  ^^
test.rb:2:3: C: Favor modifier if usage when having a single-line body. Another good alternative is the usage of control flow &&/||.
  if something
  ^^
test.rb:4:5: W: end at 4, 4 is not aligned with if at 2, 2
    end
    ^^^

1 file inspected, 4 offenses detected
```

명령어 파라미터를 추가하여 더 많은 분석 정보를 확인할 수 있습니다:

```
$ rubocop -h
```

Command flag              | Description
--------------------------|------------------------------------------------------------
`-v/--version`            | 현재 RuboCop 버전을 표시합니다.
`-V/--verbose-version`    | 현재 RuboCop 버전에 Parser, Ruby 버전을 함께 표시합니다.
`-L/--list-target-files`  | RuboCop이 정적 분석을 수행하는 모든 파일들을 리스팅합니다.
`-F/--fail-fast`          | 가장 최근 수정된 파일 순으로 정적 분석을 수행하며, 위반 사항(offense)가 발생하면 정적 분석을 종료합니다.
`-C/--cache`              | 빠른 정적분석을 위해 정적 분석 결과 데이터를 저장 및 재사용합니다.
`-d/--debug`              | 추가적인 디버그 메시지를 출력합니다.
`-D/--display-cop-names`  | 위반 사항 발견 메시지에 cop(check) 이름을 표시합니다.
`-c/--config`             | 지정한 config 파일을 기준으로 정적분석을 수행합니다.
`-f/--format`             | Formatter를 선택합니다.
`-o/--out`                | STDOUT이 아닌 지정된 파일에 보고서를 저장합니다.
`-r/--require`            | Ruby 파일을 요청합니다([Loading Extensions](#loading-extensions) 참고).
`-R/--rails`              | Rails cop을 추가 실행합니다.
`-l/--lint`               | Lint cops 만을 실행합니다.
`-a/--auto-correct`       | 특정한 위반 사항을 자동으로 수정한다. (*주의: * 실험적인 기능이므로 테스트 후 적용하길 권장합니다)
`--only`                  | 지정한 cops 혹은 지정된 department에 설정된 cops 만을 실행합니다.
`--except`                | 지정한 cops를 제외하고 configuration에 활성화 되어 있는 모든 cops를 실행합니다.
`--auto-gen-config`       | 자동으로 configuration 파일을 생성하며, 이 configuration 파일은 TODO 리스트처럼 사용합니다.
`--exclude-limit`         | `--auto-gen-config` 가 Exclude parameter에 포함할 수 있는 최대 파일수를 지정합니다. 기본값은 15입니다.
`--show-cops`             | 실행 가능한 cops와 설정값을 출력합니다.
`--fail-level`            | 위반이 발생하는 경우 분석을 중지하기 위한 Minimum [severity](#severity)를 설정합니다. severity의 이름을 쓰거나 severity를 의미하는 대문자를 사용할 수 있습니다. 일반적으로 auto-corrected offenses는 무시됩니다. `A` 혹은 `auto-correct`를 사용하면 auto-corrected offenses를 실패 트리거로 사용할 수 있다.
`-s/--stdin`              | 분석 과정에서 표준 입력도구(STDIN, 키보드)를 파이핑합니다. Editor와 통합시 유용하게 사용할 수 있습니다.

### Cops

RuboCop에서 코드 정적 분석을 위해 수행하는 여려 가지 확인 작업을 cops라고 칭합니다. cop은 다양한 department로 구분됩니다.
[custom cops](#custom-cops)을 로딩하여 사용할 수도 있습니다.

#### Style

RuboCop의 대부분의  cops는 style cops 라 불리며 코드 스타일의 문제점을 확인합니다. style cops는 대부분은 Ruby Style Guide에 기반을 두고 있다. Style cops는 각각 configuration option을 가지고 있으며 이 옵션들을 통해 다양한 코딩 컨벤션을 지원한다.

#### Lint

Lint cops는 잠재적인 오류와 바람직하지 않은 프랙티스들을 확인합니다. RuboCop 매우 편리한 방법으로 내장된 MRI lint checks (`ruby -wc`)를 구현하였으며, 추가로 고유의 lint check 요소들을 포함합니다. lint check cops 만을 실행할 경우 다음 명령어를 사용합니다:

```
$ rubocop -l
```

`-l`/`--lint` 옵션은 `–only` 옵션과 함께 사용할 수 있으며, 두 옵션을 함께 사용하면 모든 lint cops를 사용하면서 다른 cops들을 추가할 수 있습니다. lint cops을 비활성화하는 것은 가급적 권장하지 않습니다.

#### Metrics

Metrics cops는 측정 가능한 소스 코드의 속성들을 다룹니다. 측정 가능한 소스 코드의 속성으로는 클래스 크기<sub>class length</sub>, 메소드 크기<sub>method length</sub>와 같은 것들이 포함됩니다. 일반적으로 이러한 속성들은 'Max'라는 파라미터를 가지고 있으며 `rubocop --auto-gen-config` 명령어를 수행할 때 코드를 분석한 값중 가장 큰 값으로 이 'Max' 값을 설정합니다.

#### Rails

Rails cops는 Ruby on Rails 프레임워크에 특화되어 있습니다. Style, lint cops와 다르게 rails cops는 기본적으로 사용되지 않으며 사용할 경우에는 다음의 명령어를 수행해야 합니다:

```
$ rubocop -R
```

혹은 다음 지시어를 `.rubocop.yml`에 등록합니다:

```yaml
AllCops:
  RunRailsCops: true
```

## Configuration

RuboCop은 [.rubocop.yml](https://github.com/bbatsov/rubocop/blob/master/.rubocop.yml) 설정 파일에 따라 동작합니다. 이 파일에서는 파일에서는 특정한 cops (checks)를 활성화/비활성화 할 수 있으며, cops의 파라미터 값을 설정할 수 있으며 홈 디렉토리/ 프로젝트 디렉토리에 위치합니다.

RuboCop은 분석 대상 파일이 있는 디렉토리의 configuration 파일을 가장 먼저 찾기 시작하며, 해당 디렉토리에 configuration 파일이 없을 경우 상위 디렉토리의 파일을 사용합니다. configuration 파일은 다음과 같은 형태로 구성되어 있습니다:

```yaml
inherit_from: ../.rubocop.yml

Style/Encoding:
  Enabled: false

Metrics/LineLength:
  Max: 99
```

**주의**: cop 이름과 cop의 type(예, Style)를 함께 쓸 것을 권장하고 있지만, cop 이름에서 type은 중복되어도 관계 없습니다.

### Inheritance

RuboCop은 configruation 파일의 단일 상속, 다중 상속을 런타임에 지원합니다.

#### Inheriting from another configuration file in the project

옵션인 `inherit_from` 지시어를 사용해서 단일 혹은 다중 설정 파일로부터 상속을 할 수 있습니다. 공통적으로 사용하는 프로젝트 속성은 프로젝트 루트 디렉토리의 `.rubocop.yml`에 설정한 뒤, 하위 디렉토리에는 달라지는 속성값들만 가지고 있는 설정 파일을 별도로 저장해 두고 사용하면 됩니다. 상속하는 파일들은 상대 경로 혹은 절대 경로를 사용해서 지정할 수 있습니다.`inherit_from` 지시자 이후의 설정 내용들은 모두 오버라이딩 되며, 동일한 속성값을 가지고 있는 복수개의 설정 파일을 상속하는 경우 리스트이 가장 마지막에서 호출된 파일로부터 속성값을 상속합니다.  다중 상속은 다음과 같은 형태로 선언한다:

```yaml
inherit_from:
  - ../.rubocop.yml
  - ../conf/.rubocop.yml
```

#### Inheriting configuration from a dependency gem

옵션인 `inherit_gem`  지시어를 사용해서 프로젝트 외부의 단일 혹은 다중 gem 파일을 포함할 할 수 있습니다. 이 방법을 사용해 공용 의존성을 가진 RuboCop configuration을 상속해서 복수의 분리된 프로젝트들에 적용할 수 있습니다.

이 방법으로 상속되는 설정값들은 `inherit_from 지시어 이전에 선언되어야 합니다. `inherit_gem` 지시어로 선언된 설정값들을 먼저 로딩하고, 그 다음으로 'inherit_from' 지시어로 선언된 설정값들을 로딩해야 합니다. 그리고 나서 마지막으로 지시어(cops)로 선언되어 있는 설정값들이 상속됩니다. 즉, 단일 혹은 복수 gem에서 상속되는 설정값들의 우선 순위는 가장 낮습니다.

지시어는 YAML Hash 형태로 선언하며 gem의 이름을 key로, gem의 상대 경로를 key의 값으로 사용합니다:

```yaml
inherit_gem:
  rubocop: config/default.yml
  my-shared-gem: .rubocop.yml
  cucumber: conf/rubocop.yml
```

**Note**: [Bundler](http://bundler.io/) Gemfile을 사용해 공유된 의존성을 선언한 뒤 해당 gem을 bundle install로 설치힌 경우에는 RuboCop 역시 Gemfile을 통해 설치헤야 해당 의존성의 설치 경로 관련 정보를 런타임에 찾아낼 수 있습니다:

```
$ bundle exec rubocop <options...>
```

### Defaults

RuboCop 홈 디렉토리에 [config/default.yml](https://github.com/bbatsov/rubocop/blob/master/config/default.yml) 파일이 존재합니다. 이 파일은 기본적으로 상속하는 모든 설정의 기본값을 포함하고 있으며, 개별 프로젝트 및 사용자가 정의한 `.rubocop.yml` 파일은 `defualt.yml`과 달리 실제로 사용할 설정값들만 변경하면 됩니다. 프로젝트 혹은 홈 디렉토리에 `.rubocop.yml` 파일이 없는 경우 `config/default.yml` 파일을 기준으로 분석을 수행합니다.

### Including/Excluding files

RuboCop은 명령어를 기본적으로 명령어를 실행한 디렉토리로부터 혹은 옵션으로 입력한 디렉토리를 포함해 해당 디렉토리의 모든 하위 디렉토리에 위치한 파일들을 분석합니다. 하지만, '.rb' 확장자를 가진 파일 혹ㄷ은 `#1.*ruby` 지시자를 포함한 파일만 루피 파일로 인식합니다. hidden directory(.으로 시작하는 디렉토리)는 기본적으로 분석 대상에서 제외되며, 이들을 분석 대상으로 포함하고 싶은 경우에는 해당 디렉토리를 커맨드 라인에서 파라미터로 넘기거나 `AllCops / Include` 지시어에 입력해 주어야 합니다. 분석 대상에서 파일이나 디렉토리를 제거하고 싶은 경우에는 `AllCops / Exclude` 지시어를 사용합니다.

레일즈 프로젝트라면 다음과 같은 형태로 분석 대상을 포함/제외시킬 수 있습니다:

```yaml
AllCops:
  Include:
    - '**/Rakefile'
    - '**/config.ru'
  Exclude:
    - 'db/**/*'
    - 'config/**/*'
    - 'script/**/*'
    - !ruby/regexp /old_and_unused\.rb$/

# other configuration
# ...
```

파일과 디렉토리는 `.rubocop.yml` 파일에 대한 상대 경로로 입력합니다.

**Note**: 모든 폴더의 특정한 파일(예 'Rakefile' 등)을 분석 대상에 포함/ 제외하고자 할 경우, 현재 디렉토리를 포함해 `**/Rakefile`과 같이 패턴을 이력합니다.

**Note**: config 디렉토리 및 그 하위에 포함된 모든 파일을 분석 대상에 포함/ 제외하고자 할 경우, `config/**/*`과 같이 패턴을 입력합니다.

**Note**:
`Include`, `Exclude`는 특별한 성격의 지시어로 선언된 파일(`.rubocop.yml`)이 포함된 디렉토리 및 하위 디렉토리에 대해 유효성을 보장받습니다. 즉 하위 폴더에 위치한 `Include`, `Exclude` 지시어의 영향을 받지 않는다는 의미입니다. 일반적인 지시어들은 분석 대상 파일과 가장 가까운 위치에 있는 설정 파일의 영향을 받습니다.

필요한 경우, 특정한 파일들에 대해서만 cops를 적용할 수 있습니다(예를 들어 `apps/models/*.rb` 파일들에만 Rails model check를 수행하는 경우 등). 모든 cops는 `Include` 지시어를 함께 사용할 수 있습니다.

```yaml
Rails/DefaultScope:
  Include:
    - app/models/*.rb
```

필요한 경우, 특정한 파일들에 대해서만 cops 적용을 제외할 수 있습니다(예를 들어 특정한 cops는 특정한 파일에만 적용하는 등).
모든 cops는 `Exclude` 지시어를 함께 사용할 수 있습니다:

```yaml
Rails/DefaultScope:
  Exclude:
    - app/models/problematic.rb
```

### Generic configuration parameters

`Include`, `Exlcude` 지시어와 함께 다음 파라미터들을 개별적인 cops 단위로 사용할 수 있습니다:

#### Enabled

`Enabled` 지시어의 값을 `false`로 설정해서 특정한 cop를 비활성화 할 수 있습니다.

```yaml
Metrics/LineLength:
  Enabled: false
```

기본적으로 대부분의 cops는 활성화되어 있으나, [config/disabled.yml](https://github.com/bbatsov/rubocop/blob/master/config/disabled.yml)
에 포함된 cops 들은 기본적으로 비활성화 되어 있습니다. `DisabledByDefault`를 `true`로 설정해서 cop 활성화 프로세스를 변경할 수 있습니다.

```yaml
AllCops:
  DisabledByDefault: true
```

위와 같이 설정하는 경우 기본적으로 모든 cops는 비활성화되며, 사용자 configuration 파일에서 활성화 설정된 cops들만 활성화됩니다. `Enabled: true`를 굳이 사용자 configuration에서 설정할 필요는 없습니다. 어쨌든 이 cops 들은 활성돠 횝니다.

#### Severity

각각의 cop은 기본 심각도를 가지고 있습니다. `Lint`의 경우 `warning`, 다른 cops의 경우는 `convention`으로 레벨이 설정되어 있습니다. 심각도 레벨은 커스터마이징이 기능하며, `refactor`, `convention`, `warnging`, `error` 및 `fatal`을 사용할 수 있습니다.

단 위의 원칙이 예외적으로 적용되는 cop이 하나 있는데 바로 `Lint/Syntax`입니다. 이 특별한 cops은 다른 cops이 호출되기 전에 syntax error를 확인합니다.
이 `Lint/Syntax` cop은 임의로 비활성화 할 수 없으며, 심각도 역시 configuration에서 변경할 수 없습니다(항상 `fatal` 심각도).

```yaml
Metrics/CyclomaticComplexity:
  Severity: warning
```

#### AutoCorrect

`--auto-correct` 옵션을 지원하는 cop들은 해당 옵션을 비활성화 할 수 있습니다. 다음 예를 참조합니다:

```yaml
Style/PerlBackrefs:
  AutoCorrect: false
```

### Automatically Generated Configuration

이미 작성된 코드들에서 Offenses가 너무 많이 발견된다면 `rubocop --auto-gen-gconfig` 명령어를 실행한 뒤, 사용자 정의 `.rubucop.yml`에 `inherit_from: .rubocop_todo.yml` 지시어를 포함하는 것도 고려해볼 수 있습니다. 자동으로 생성되는 `.rubocop_todo.yml` 파일은 위반 사항을 포함한 파일을 분석에서 제외함으로서 현재 코드 상에서 발견된 모든 offense를 비활성하는 설정값을 가지고 있습니다. 또한 파일의 수가 설정된 값을 초과하면 모든 cop을 비활성화 하기도 합니다.

`--exclude-limit COUNT`, 즉 `rubocop --auto-gen-config --exclude-limit 5`와 같은 형태로 명령어를 사용해서 해당 cop을 언제 완전히 제외할 지 설정할 수 있습니다. 기본값은 15입니다.

그리고 나서 자동 생성된 `.rubocop_todo.yml` 파일에서 copt을 하나씩 지워나가면서 코드 상의 offenses 들을 확인할 수 있다.

## 소스 코드 내에서 Cops를 비활성화 하기

하나 혹은 복수의 cops를 소스 코드상에서 비활성화 할 수 있습니다. 주석에 다음과 같이 추가합니다:

```ruby
# rubocop:disable Metrics/LineLength, Style/StringLiterals
[...]
# rubocop:enable Metrics/LineLength, Style/StringLiterals
```

또는 *모든* cops를 비활성화 할 수 있습니다. 코드에 다음 내용을 포함시킵니다:

```ruby
# rubocop:disable all
[...]
# rubocop:enable all
```

구문의 끝에서 다음 주석을 포함하면 하나 혹은 복수의 cops를 비활성화 할 수 있습니다.

```ruby
for x in (0..19) # rubocop:disable Style/AvoidFor
```

## Formatters

`-f/--format` 옴션을 사용해 RuboCop의 보고서 출력 형식을 변경할 수 있습니다. RuboCop은 다양한 formatter를 내장하고 있으며 사용자 정의 formatter를 생성할 수도 있습니다.

추가로 `-o/--out` 옵션을 사용하면 STDOUT이 아닌 파일에 분석 결과를 저장할 수 있습니다.

몇몇 내장 formatter들은 **시스템에서 파싱 가능한** 결과 보고서를 생성하며, public API와 같이 취급됩니다. 나머지는 사람이 인식할 수 있는 fornatter들로 이 결과 보고서를 파싱하는 것은 의미가 없습니다.

`-f/--format` 옵션을 여러번 사용하면 다양한 formatter를 동시에 활성화 할 수 있습니다. `-o/--out` 옵션은 직전에 호출된 `-f/--format` 옵션의 결과값을 저장됩니다.
`-o/--out` 옵션 앞에 `-f/-format` 옵셥을 사용하지 않는 경우 기본 `progress` format 형태의 결과 보고서가 저장됩니다.

```bash
# $stdout에 simple format 보고서를 출력합니다.
$ rubocop --format simple

# result.txt 파일에 progress format 보고서를 저장합니다.
$ rubocop --out result.txt

# $stdout에 progress format 및 coutn format 보거서를 출력합니다.
# offense count formatter는 분석 결과의 최종 요약 내용만을 출력하므로
# $stdout에 출력된 대부분의 내용은 progress formatter가 출력한 것입니다.
# offense count symmary는 출력된 보고서의 가장 마지막에 표시됩니다.
$ rubocop --format progress --format offenses

# $stdout에 prograss format 보고소를 출력하고, rubocop.json 파일에 JSON format 보고서를 저장합니다.
$ rubocop --format progress --format json --out rubocop.json
#         ~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~~~
#                 |               |_______________|
#              $stdout

# result.txt에 progress format 보고서를 저장하고, $stdout에 simple format 보고서를 출력합니다.
$ rubocop --output result.txt --format simple
#         ~~~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~
#                  |                 |
#           default format        $stdout
```

[custom formatters](#custom-formatters) 역시 사용할 수 있습니다.

### Progress Formatter (default)

기본 `progress` formatter는 분석된 모든 파일에 하나의 캐릭터를 표시하며 분석 로그 마지막에 분석된 모든 위반 사항을 `clang` 포맷으로 표시합니다. `.` 기호는 문제가 없는 파일을 의미하며, 모든 대분자는 파일에서 발견된 각 위반 사항의 심각도를 표시합니다(convention, warning, error of fatal).

```
$ rubocop
Inspecting 26 files
..W.C....C..CWCW.C...WC.CC

Offenses:

lib/foo.rb:6:5: C: Missing top-level class documentation comment.
    class Foo
    ^^^^^

...

26 files inspected, 46 offenses detected
```

### Clang Style Formatter

`clang` formatter는 `clang`과 비슷한 형태로 위반 사항을 표시합니다:

```
$ rubocop test.rb
Inspecting 1 file
W

Offenses:

test.rb:1:5: C: Use snake_case for method names.
def badName
    ^^^^^^^
test.rb:2:3: C: Use a guard clause instead of wrapping the code inside a conditional expression.
  if something
  ^^
test.rb:2:3: C: Favor modifier if usage when having a single-line body. Another good alternative is the usage of control flow &&/||.
  if something
  ^^
test.rb:4:5: W: end at 4, 4 is not aligned with if at 2, 2
    end
    ^^^

1 file inspected, 4 offenses detected
```

### Fuubar Style Formatter

`fuubar` style formatter는 프로그레스 바를 표시해 주며, 위반 사항이 발생되는 즉시 `clang` 형태로 결과를 표시합니다.
이 formatter는 RSpec의 [Fuubar](https://github.com/jeffkreeftmeijer/fuubar)에서 영감을 받아 구현했습니다.

```
$ rubocop --format fuubar
lib/foo.rb.rb:1:1: C: Use snake_case for methods and variables.
def badName
    ^^^^^^^
lib/bar.rb:13:14: W: File.exists? is deprecated in favor of File.exist?.
        File.exists?(path)
             ^^^^^^^
 22/53 files |======== 43 ========>                           |  ETA: 00:00:02
```

### Emacs Style Formatter

**시스템에서 파싱 가능**

`emacs` formatter는 `Emacs`에서 인식할 수 있는 형태로 위반 사항을 표시합니다(`Emacs` 혹은 다을 도구들에서도 인식 가능할 수 있습니다).

```
$ rubocop --format emacs test.rb
/Users/bozhidar/projects/test.rb:1:1: C: Use snake_case for methods and variables.
/Users/bozhidar/projects/test.rb:2:3: C: Favor modifier if/unless usage when you have a single-line body. Another good alternative is the usage of control flow &&/||.
/Users/bozhidar/projects/test.rb:4:5: W: end at 4, 4 is not aligned with if at 2, 2
```

### Simple Formatter

Simple formatter는 그 이름 그대로, 간단한 형태로 분석 결과를 출력합니다 :-)

```
$ rubocop --format simple test.rb
== test.rb ==
C:  1:  5: Use snake_case for method names.
C:  2:  3: Use a guard clause instead of wrapping the code inside a conditional expression.
C:  2:  3: Favor modifier if usage when having a single-line body. Another good alternative is the usage of control flow &&/||.
W:  4:  5: end at 4, 4 is not aligned with if at 2, 2

1 file inspected, 4 offenses detected
```

### File List Formatter

 **시스템에서 파싱 가능**

때대로 여러분이 선호하는 editor에서 위반 사항을 포함한 모든 파일들을 열고 싶은 경우가 있을 수 있습니다.
File List formatter는 위반 사항을 포함하고 있는 파일들의 이름만을 리스팅하며, 파이브와 함께 다음과 같이 사용할 수 있습니다.:

```
$ rubocop --format files | xargs vim
```

### JSON Formatter

**시스템에서 파싱 가능**

`--format json` 옵션을 사용하면 RuboCop 분셕 결과를 JSON 포맷으로 출력할 수 있습니다. 생성되는 JSON 구조는 다음과 같습니다:

```javascript
{
  "metadata": {
    "rubocop_version": "0.9.0",
    "ruby_engine": "ruby",
    "ruby_version": "2.0.0",
    "ruby_patchlevel": "195",
    "ruby_platform": "x86_64-darwin12.3.0"
  },
  "files": [{
      "path": "lib/foo.rb",
      "offenses": []
    }, {
      "path": "lib/bar.rb",
      "offenses": [{
          "severity": "convention",
          "message": "Line is too long. [81/80]",
          "cop_name": "LineLength",
          "corrected": true,
          "location": {
            "line": 546,
            "column": 80,
            "length": 4
          }
        }, {
          "severity": "warning",
          "message": "Unreachable code detected.",
          "cop_name": "UnreachableCode",
          "corrected": false,
          "location": {
            "line": 15,
            "column": 9,
            "length": 10
          }
        }
      ]
    }
  ],
  "summary": {
    "offense_count": 2,
    "target_file_count": 2,
    "inspected_file_count": 2
  }
}
```

### Offense Count Formatter

코드 베이스에 처음 RoboCop을 적용하는 경우 때로 어떤 부분에서 코드 개선을 해야할지 대략적으로 판단하는 것이 유용한 경우가 있습니다.

이 때 offenses count Formatter를 사용해서 위반한 cops와 각 cops의 위반 수를 쉽게 확인할 수 있다:

```
$ rubocop --format offenses

87   Documentation
12   DotPosition
8    AvoidGlobalVars
7    EmptyLines
6    AssignmentInCondition
4    Blocks
4    CommentAnnotation
3    BlockAlignment
1    IndentationWidth
1    AvoidPerlBackrefs
1    ColonMethodCall
--
134  Total
```

### HTML Formatter

CI(지속적인 통합) 환경에서 유용하게 사용할 수 있으며, HTML Formatter는 [this](http://f.cl.ly/items/0M3029412x3O091a1X1R/expected.html)와 같은 형태의 HTML 보고서를 생성합니다.

```
$ rubocop --format html -o rubocop.html
```

## Compatibility

RubiCop은 다음 루비 구현 환경을 지원합니다:

* MRI 1.9.3
* MRI 2.0
* MRI 2.1
* MRI 2.2
* JRuby in 1.9 mode
* Rubinius 2.0+

## Editor integration

### Emacs

[rubocop.el](https://github.com/bbatsov/rubocop-emacs)는 간단한 RuboCop-Emcas 인터페이스 입니다.
이 인터페이스를 사용해 Emacs에서 RubiCop을 실행할 수 있고, 코드 내의 위반 발생 지점을 손쉽게 이동할 수 있습니다.

[flycheck](https://github.com/lunaryorn/flycheck) > 0.9 역시 RuboCop을 지원하며 일반적인 경우 기본적으로 사용합니다.

### Vim

[vim-rubocop](https://github.com/ngmy/vim-rubocop) 플러그인을 사용해 Vim에서 RuboCop을 실행하고 분석과를 표시할 수 있습니다.

[syntastic](https://github.com/scrooloose/syntastic)에서도 RuboCop Checker를 사용할 수 있습니다.

### Sublime Text

Sublime Text를 사용하고 있다면 [Sublime RuboCop plugin](https://github.com/pderichs/sublime_rubocop)을 유용하게 사용할 수 있습니다.

### Brackets

[brackets-rubocop](https://github.com/smockle/brackets-rubocop) extension을 사용하면 Brackets에서 RuboCop 분석 결과를 표시할 수 있으며, Brackets의 extension manager에서 설치할 수 있습니다.

### TextMate2

[textmate2-rubocop](https://github.com/mrdougal/textmate2-rubocop)을 사용하면 새 윈도우에서 RoboCop 분석 결과를 표시할 수 있습니다. 설치 가이드는 [here](https://github.com/mrdougal/textmate2-rubocop#installation)를 참조합니다.

### Atom

[atom-lint](https://github.com/yujinakayama/atom-lint) 패키지는 RubiCop을 실행하고 Atom에 offenses를 하이라이트 합니다.

또한 Atom의 [linter](https://github.com/AtomLinter/Linter)용으로 [linter-rubocop](https://github.com/AtomLinter/linter-rubocop) 플러그인을 사용할 수 있습니다.

### LightTable

[lt-rubocop](https://github.com/seancaffery/lt-rubocop) 플러그인을 사용해 RuboCop과 LightTable을 통합할 수 있습니다.

### RubyMine

[rubocop-for-rubymine](https://github.com/sirlantis/rubocop-for-rubymine) 플러그인을 사용해 RoboCop과 RubyMine/IntelliJ IDEA를 통합할 수 있습니다.

### Other Editors

여러분이 가장 선호하는 Editor와 RuboCop을 통합할 기회를 가지고 싶다먄 언제든지 환영입니다!

## Git pre-commit hook integration

[overcommit](https://github.com/brigade/overcommit)은 자유로운 설정이 가능하며 확장기 가능한 Git commit hook manager입니다. RuboCop과 overcommit을 함께 사용하고 싶다면 다음 내용을 여러분이 사용하는 `.overcommit.yml` 파일에 추가합니다.


```yaml
PreCommit:
  RuboCop:
    enabled: true
```

## Guard integration

[Guard](https://github.com/guard/guard)를 선호한다면, [guard-rubocop](https://github.com/yujinakayama/guard-rubocop)가 좋은 선택이 될 것입니다. guard-rubocop은 파일이 변경되는 즉시 Ruby code style의 준수 여부를 확인합니다.

## Rake integration

`Rakefile`에서 RuboCop을 사용할 경우, 다음 내용을 추가합니다:

```ruby
require 'rubocop/rake_task'

RuboCop::RakeTask.new
```

`rake -T`를 실행하면 다음과 같은 2개의 RuboCop 태스크가 나타납니다:

```sh
rake rubocop                                  # Run RuboCop
rake rubocop:auto_correct                     # Auto-correct RuboCop offenses
```

위의 태스크는 기본 값들을 사용합니다:

```ruby
require 'rubocop/rake_task'

desc 'Run RuboCop on the lib directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb']
  # only show the files with failures
  task.formatters = ['files']
  # don't abort rake on failure
  task.fail_on_error = false
end
```

## Caching

큰 프로젝트들은 수백 혹은 수천 개의 파일을 포함하고 있으며 분석을 위해 상당한 시간이 소요됩니다. RuboCop은 이러한 문제를 완화하기 위한 기능을 가지고 있으며, 캐싱 매커니즘을 제공하여 분석된 파일에 발견된 offenses와 관련된 정보들을 저장합니다.

### Cache Validity

다음 번의 분석은 이번 분석의 결과를 참조하며 기존 파일을 다시 분석하는 대신 이미 저장되어 있는 과거 분석 결과를 표시합니다. 이 기능은 해당 파일의 캐시가 유용한 경우에 자동으로 수행되는데, 파일의 캐시는 다음 리스트의 변화가 없는 경우 유지됩니다:

* 분석된 파일의 내용
* 분석된 파일과 관련된 RuboCop configuration
* `rubocop` 실행시 사용한 옵션, 단 옵션에 의해 보고된 offenses가 없는 경우는 해당하지 않음
* RuboCop 을 수행한 Ruby 버전
* `rubocop` 프로그램 버전(정확히는 수행된 `rubocop` 프로그램의 모든 소스 코드)

### Enabling and Disabling the Cache

캐싱 기능은 `AllCops: UseCache` 설정값의 파라미터가 `true`로 설정된 경우 활성화되며, 기본적으로 `true` 값으로 설정된다. 커맨드라인 옵션으로 `--cache false`를 사용하면 캐싱을 비솰성화 할 수 있으며, configuration parameter는 오버라이딩 된다. 로컬 `.rubocop.yml` 파일의 `AllCops: UseCache`가 `false`로 설정되어 있는 경우  커맨드라인 옵션으로 `--cache true`를 사용하면 설정 파일의 설정값을 오버라이딩 한다.

### Cache Path

기본적으로 캐시는 유닉스 계열의 시스팀엔 경우 `/tmp/rubocop_cache/`라는 임시 디렉토리의 하위 디렉토리에 저장됩니다. 다른 캐시 저장 장소를 사용할 경우 `AllCops: CacheRootDirectory`에 경로를 설정할 수 있습니다. 이 기능은 네트워크 디스크를 다수의 사용자가 공통의 RuboCop 캐시를 사용해야 할 경우, 혹은 지속적인 통합 시스템이 임시 디렉토리가 아닌 영구 디렉토리들을 사용하도록 할 경우에 활용할 수 있습니다.

### Cache Pruning

하나 이상의 파일이 변경될 때마다, 해당 파일의 위반 내역은 캐시에 새로운 키로 저장됩니다. 즉 캐시의 용량은 계속 증가하게 됩니다. `AllCops: MaxFilesInCache`에 제한값을 설정할 수 있으면, 캐시 파일의 수가 제한값을 넘어서면 오래된 캐시부터 자동적으로 삭제됩니다.

## Extensions

사용자 정의 cops 와 formatter를 사용해서  RuboCop의 기능을 확장할 수 있습니다.

### Loading Extensions

`--require` 커맨드 라인 옵션 혹은 `.rubocop.yml`에서 `require` 지시어를 사용해서 임의의 ruby 파일들을 로딩할 수 있습니다.

```yaml
require:
 - ../my/custom/file.rb
 - rubocop-extension
```

NOTE: 위에서 설정한 경로들은 직접 `Kernel.require`로 전달됩니다. 사용자 정의 확장 파일이 `$LOAD_PATH`에 존재하지 않는 경우, `./`와 같은 상대 경로 혹은 절대 경로를 사용해 확장 파일의 위치를 지정할 수 있습니다.

### Custom Cops

일반적인 여타 cop들과 마찬가지로, 사용자 정의 cops들을 `.rubocop.yml`에서 설정할 수 있습니다.

#### Known Custom Cops

* [rubocop-rspec](https://github.com/nevir/rubocop-rspec) -
  RSpec-specific analysis

### Custom Formatters

사용자 정의 formatter를 사용해 RuboCop 분석 결과의 출력 형태를 자유롭게 변경할 수 있습니다.

#### Creating Custom Formatter

사용자 정의 formatter를 구현하려면, `RobpCop::Formatter:BaseFormatter`의 하위 클래스를 만들고, 필요한 method들을 오버라이드 하거나 모든 formatter API method를 직접 구현하시기 바랍니다.

Formatter API와 관련된 세부 사항은 아래 링크를 참조 하십시오:

* [RuboCop::Formatter::BaseFormatter](http://rubydoc.info/gems/rubocop/RuboCop/Formatter/BaseFormatter)
* [RuboCop::Cop::Offense](http://rubydoc.info/gems/rubocop/RuboCop/Cop/Offense)
* [Parser::Source::Range](http://rubydoc.info/github/whitequark/parser/Parser/Source/Range)

#### Using Custom Formatter in Command Line

`--format` 혹은 `--require` 옵션을 조합해서 사용자 정의 formatter를 사용할 수 있습니다.
예를 들어 `MyCustomFormatter`를 `./path/to/my_custom_formatter.rb`에 정의한 경우 다음 커맨드를 사용할 수 있습니다:

```
$ rubocop --require ./path/to/my_custom_formatter --format MyCustomFormatter
```

## Team

RoboCop의 핵심 개발자는 다음과 같습니다:

* [Bozhidar Batsov](https://github.com/bbatsov)
* [Jonas Arvidsson](https://github.com/jonas054)
* [Yuji Nakayama](https://github.com/yujinakayama)
* [Evgeni Dzhelyov](https://github.com/edzhelyov)

## Logo

RuboCop의 로고는 [Dimiter Petrov](https://www.chadomoto.com/)가 제작했습니다.
다음 링크에서 다양한 포맷의 로고를 다운로드 받을 수 있습니다: [here](https://github.com/bbatsov/rubocop/tree/master/logo).

모든 로고들은 [Creative Commons Attribution-NonCommercial 4.0 International License](http://creativecommons.org/licenses/by-nc/4.0/deed.en_GB) 라이선스를 준수합니다.

## Contributors

RuboCop의 개발에 도움을 모든 컨트리뷰터는 다음
[list](https://github.com/bbatsov/rubocop/contributors)에 표시되어 있습니다.

이 모든 분들께 감사드립니다.

만약 여러분이 RuboCop에 컨트리뷰션하길 원한다면, 다음의 짧은 가이드라인을 주의깊게 읽어보시길 바랍니다: [contribution guidelines](CONTRIBUTING.md).

이 프로젝트의 최우선 순위는 Ruby Style Guide의 내용을 RuboCop cops로 변경하는 것입니다. 새로운 cop을 작성하는 것은 RuboCop 개발에 뛰어드는 멋진 방법이며, 물론 버그 리포트나 개선 사항에 대한 제안도 언제든 환영합니다. GitHub pull requests 라면 더욱 좋습니다! :-)

[Salt](https://salt.bountysource.com/teams/rubocop)나 [Gratipay](https://www.gratipay.com/rubocop)를 통해서도 이 프로젝트를 지원할 수 있습니다.

[![Support via Gratipay](https://cdn.rawgit.com/gratipay/gratipay-badge/2.1.3/dist/gratipay.png)](https://gratipay.com/rubocop)

## Mailing List

RuboCop 개발에 관심이 있다면 다음 메일링 그룹에 가입할 것을 고려해 보십시오:
[Google Group](https://groups.google.com/forum/?fromgroups#!forum/rubocop)

## Freenode

IRC를 사용하고 있다면 Freenode에서  `#rubocop` 채널을 방문해 보십시오.

## Changelog

RuboCop 변경 사항은 다음 링크를 참조하십시오: [here](CHANGELOG.md)

## Copyright

Copyright (c) 2012-2015 Bozhidar Batsov. See [LICENSE.txt](LICENSE.txt) for
further details.
