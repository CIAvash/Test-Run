use v6.d;

use Test;

unit module Test::Run:auth($?DISTRIBUTION.meta<auth>):ver($?DISTRIBUTION.meta<version>);

=begin pod

=NAME Test::Run - A module for testing output of processes.

=begin SYNOPSIS

=begin code :lang<raku>

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

=end code

=end SYNOPSIS

=begin INSTALLATION

You need to have L<Raku|https://www.raku-lang.ir/en> and L<zef|https://github.com/ugexe/zef>, then run:

=begin code :lang<console>

zef install 'Test::Run:auth<zef:CIAvash>'

=end code

or if you have cloned the repo:

=begin code :lang<console>

zef install .

=end code

=end INSTALLATION

=begin TESTING

=begin code :lang<console>

prove -ve 'raku -I.' --ext rakutest

=end code

=end TESTING

=DESCRIPTION
Test::Run is a module for testing C<STDOUT>, C<STDERR> and C<exitcode> of processes.

=head1 SUBS

=end pod

#| Takes program arguments, optionally C<STDIN>, expected C<STDOUT> and C<STDERR> and C<exitcode>,
#| binary mode(can be separate for C<STDOUT> and C<STDERR>),
#| operator used for C<cmp-ok> (can be separate for C<STDOUT> and C<STDERR>),
#| custom test function to run on C<STDOUT> and/or C<STDERR>.
#| Then runs 3 tests for C<exitcode>, C<STDERR>, C<STDOUT> in a C<subtest>
our sub runs_ok (
    Str $description?, :@args!, :$in, :$out, :$err, Int :$exitcode = 0,
    Bool:D :$bin = False,       #= Whether C<output> is binary(C<Blob>)
    Bool:D :$bin_stdout = $bin, #= Whether C<STDOUT> is binary(C<Blob>)
    Bool:D :$bin_stderr = $bin, #= Whether C<STDERR> is binary(C<Blob>)
    :$op = &[~~],               #= Comparison operator for C<cmp-ok>
    :$op_stdout is copy = $op,  #= Comparison operator for C<cmp-ok> and C<STDOUT>
    :$op_stderr is copy = $op,  #= Comparison operator for C<cmp-ok> and C<STDERR>
    :&test_stdout,              #= Custom test function for C<STDOUT>
    :&test_stderr               #= Custom test function for C<STDERR>
) is export(:runs_ok) {
    # my ($proc_out, $proc_err, $proc_exitcode) = run_proc :@args, :$in, :$bin;
    my ($proc_out, $proc_err, $proc_exitcode) = run_proc_async :@args, :$in, :$bin_stdout, :$bin_stderr;

    subtest $description // 'Runs OK', {
        plan 3;

        # Flip operands for &[~~], if there was no expected content for output
        for ($op_stdout, $out), ($op_stderr, $err) -> ($op_std is rw, $test) {
            $op_std = &[R[~~]] if !$test.defined and $op_std eqv &[~~] | '~~';
        }

        cmp-ok $proc_exitcode, $op, $exitcode, 'Exit code';

        if &test_stderr {
            test_stderr $proc_err, $err, 'STDERR';
        } else {
            cmp-ok $proc_err, $op_stderr, $err, 'STDERR';
        }

        if &test_stdout {
            test_stdout $proc_out, $out, 'STDOUT';
        } else {
            cmp-ok $proc_out, $op_stdout, $out, 'STDOUT';
        }
    }
}

#| Runs process with C<Proc>, returns a list of C<STDOUT>, C<STDERR>, C<exitcode>.
#| Currently unused because it returns exitcode 1 for nonexistent programs, sinks & dies when handles are closed
#| See https://github.com/rakudo/rakudo/issues/1590 and https://github.com/rakudo/rakudo/issues/3720
our sub run_proc (:@args, :$in?, Bool:D :$bin = False --> List) is export(:run_proc) {
    with run |@args, :in, :out, :err, :$bin {
        $in ~~ Blob ?? .in.write($in) !! .in.print($in) and .in.close.so if $in;

        .out.slurp(:close), .err.slurp(:close), .exitcode;
    }
}

#| Runs process with C<Proc::Async>, returns a list of C<STDOUT>, C<STDERR>, C<exitcode>
our sub run_proc_async (
    :@args, :$in?, Bool:D :$bin = False, Bool:D :$bin_stdout = $bin, Bool:D :$bin_stderr = $bin --> List)
    is export(:run_proc_async) {
    my $proc = Proc::Async.new: :w($in.defined), |@args;

    my $stdout;
    my $stderr;
    my $exitcode;

    react {
        whenever $proc.stdout(:bin($bin_stdout)).reduce: &[~] {
            $stdout = $_;
        }
        whenever $proc.stderr(:bin($bin_stderr)).reduce: &[~] {
            $stderr = $_;
        }
        whenever $proc.start {
            $exitcode = .exitcode;
            done;
        }
        with $in {
            whenever $_ ~~ Blob ?? $proc.write: $_ !! $proc.print: $_ {
                $proc.close-stdin;
            }
        }
    }

    $stdout, $stderr, $exitcode;
}

=REPOSITORY L<https://github.com/CIAvash/Test-Run/>

=BUG L<https://github.com/CIAvash/Test-Run/issues>

=AUTHOR Siavash Askari Nasr - L<https://www.ciavash.name>

=COPYRIGHT Copyright © 2021 Siavash Askari Nasr

=begin LICENSE
This file is part of Test::Run.

Test::Run is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Test::Run is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with Test::Run.  If not, see <http://www.gnu.org/licenses/>.
=end LICENSE
