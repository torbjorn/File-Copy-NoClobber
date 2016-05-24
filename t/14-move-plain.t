#!/usr/bin/perl

use strict;
use warnings;
use utf8::all;
use Test::Most;
use Test::Warnings;

use File::Spec::Functions;
use File::Basename qw(basename dirname);

use File::Copy::NoClobber;
use File::Copy;

use t::lib::TestUtils;

my $d1 = testdir;
my $d2 = testdir;

my ($fh1,$fn1) = testfile($d1);
print $fh1 "some content\n";

move( $fn1, $d2 );

ok !-e $fn1, "after move, source is gone";
ok -s catfile($d2, basename $fn1), "and target exists and has size";

done_testing;
