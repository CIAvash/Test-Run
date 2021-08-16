NAME
====

Test::Run - A module for testing output of processes.

SYNOPSIS
========

```raku
use Test::Run :runs_ok;

runs_ok :args«$*EXECUTABLE -e 'put "Hi!"'», :out("Hi!\n"), 'Simple STDOUT test';
# or
Test::Run::runs_ok :args«$*EXECUTABLE -e 'put "Hi!"'», :out("Hi!\n"), 'Simple STDOUT test with full sub name';

runs_ok :args«$*EXECUTABLE -»,
        :in('put "Hi!"; note "Bye!"; exit 1'), :out("Hi!\n"), :err("Bye!\n"), :exitcode(1),
        'Output test';

# Using custom test function
use Test::Differences;
runs_ok :args«@args[] $command», :out($expected_data), "Prints correctly", :test_stdout(&eq_or_diff);
```

INSTALLATION
============

You need to have [Raku](https://www.raku-lang.ir/en) and [zef](https://github.com/ugexe/zef), then run:

```console
zef install 'Test::Run:auth<zef:CIAvash>'
```

or if you have cloned the repo:

```console
zef install .
```

TESTING
=======

```console
prove -ve 'raku -I.' --ext rakutest
```

DESCRIPTION
===========

Test::Run is a module for testing `STDOUT`, `STDERR` and `exitcode` of processes.

SUBS
====

## sub runs_ok

```raku
sub runs_ok(
    Str $description?, :@args!, :$in, :$out, :$err, Int :$exitcode = 0,
    Bool:D :$bin = Bool::False,
    Bool:D :$bin_stdout = $bin,
    Bool:D :$bin_stderr = $bin,
    :$op = &[~~],
    :$op_stdout is copy = $op,
    :$op_stderr is copy = $op,
    :&test_stdout,
    :&test_stderr
) returns Mu
```

Takes program arguments, optionally `STDIN`, expected `STDOUT` and `STDERR` and `exitcode`, binary mode(can be separate for `STDOUT` and `STDERR`), operator used for `cmp-ok` (can be separate for `STDOUT` and `STDERR`), custom test function to run on `STDOUT` and/or `STDERR`.

Then runs 3 tests for `exitcode`, `STDERR`, `STDOUT` in a `subtest`

### Bool:D :$bin

Whether output is binary(`Blob`)

### Bool:D :$bin_stdout

Whether STDOUT is binary(`Blob`)

### Bool:D :$bin_stderr

Whether STDERR is binary(`Blob`)

### Mu $op

Comparison operator for `cmp-ok`

### Mu $op_stdout

Comparison operator for `cmp-ok` and `STDOUT`

### Mu $op_stderr

Comparison operator for `cmp-ok` and `STDERR`

### Callable &test_stdout

Custom test function for `STDOUT`

### Callable &test_stderr

Custom test function for `STDERR`

## sub run_proc

```raku
sub run_proc(:@args, :$in, Bool:D :$bin = Bool::False) returns List
```

Runs process with `Proc`, returns a list of `STDOUT`, `STDERR`, `exitcode`.

Currently unused because it returns exitcode 1 for nonexistent programs,
sinks & dies when handles are closed

See https://github.com/rakudo/rakudo/issues/1590 and https://github.com/rakudo/rakudo/issues/3720

## sub run_proc_async

```raku
sub run_proc_async(
    :@args,
    :$in,
    Bool:D :$bin = Bool::False,
    Bool:D :$bin_stdout = $bin,
    Bool:D :$bin_stderr = $bin
) returns List
```

Runs process with `Proc::Async`, returns a list of `STDOUT`, `STDERR`, `exitcode`

REPOSITORY
==========

https://github.com/CIAvash/Sway-Config/

BUG
===

https://github.com/CIAvash/Sway-Config/issues

AUTHOR
======

Siavash Askari Nasr - https://www.ciavash.name

COPYRIGHT
=========

Copyright © 2021 Siavash Askari Nasr

LICENSE
=======

This file is part of Test::Run.

Test::Run is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Test::Run is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with Test::Run. If not, see <http://www.gnu.org/licenses/>.
