#!/usr/bin/perl

use strict;
use warnings;
use autodie;
use Test::Most;
use Test::Warnings;

use File::Spec::Functions;
use File::Basename qw(basename dirname);

use File::Copy::NoClobber;

use t::lib::TestUtils;

my $d1 = testdir;
my $d2 = testdir;

my ($fh1,$fn1) = testfile($d1);

print $fh1 "Some content to go in the file\n";

cmp_ok
    my $s1 = -s $fn1,
    ">",
    0,
    "test file has content";

copy $fn1, $d2;

print $fh1 "More content to make the files different\n";

cmp_ok -s $fn1, ">", $s1, "test file has more content";

# my $dest_file = copy $fn1, $d2;

# is -s catfile( $d2, basename $fn1), $s1,
#     "copying it again does not affect existing destination";



done_testing;
