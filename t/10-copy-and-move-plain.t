#!/usr/bin/perl

use strict;
use warnings;
use utf8::all;
use Test::Most;
use Test::Warnings;

use File::Spec::Functions;
use File::Basename qw(basename dirname);

use File::Copy::NoClobber;

use t::lib::TestUtils;

my $d1 = testdir;
my $d2 = testdir;

my ($fh1,$fn1) = testfile($d1);
my ($fh2,$fn2) = testfile($d1);

note "Copy a file";

ok !-e catfile( $d2, basename $fn1 ),
    "at first the destination file does not exist";

copy $fn1, $d2;

ok -e catfile( $d2, basename $fn1 ),
    "but after copy destionation file exists";
ok -e $fn1, "and source file still exists in source directory";



# note "Move a file";

# ok !-e catfile( $d2, basename $fn2 ),
#     "at first the destination file2 also does not exist";

# move $fn2, $d2;

# ok -e catfile( $d2, basename $fn2 ),
#     "but after move, this destionation file also exists";
# ok !-e $fn2, "and source file is gone since it was a move";

done_testing;
