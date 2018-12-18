## Auto-correct

In auto-correct mode, RuboCop will try to automatically fix offenses:

```sh
$ rubocop -a
```

For some offenses, it is not possible to implement automatic correction. 

Some automatic corrections that _are_ possible have not been implemented yet.

### Safe auto-correct

```sh
$ rubocop --safe-auto-correct
```

In 2018, RuboCop began to annotate cops as `Safe` or not safe.

> - Safe (true/false) - indicates whether the cop can yield false positives (by 
>   design) or not.
> - SafeAutoCorrect (true/false) - indicates whether the auto-correct the cop 
>   does is safe (equivalent) by design.
> https://github.com/rubocop-hq/rubocop/issues/5978#issuecomment-395958738

If a cop is annotated as "not safe", it will be omitted. As of December, not
all cops have a `Safe` annotation.
