#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;
use Test::Warnings;

use File::Spec::Functions;
use File::Basename qw(basename dirname);

use File::Copy::NoClobber;

use t::lib::TestUtils;

my $d1 = testdir;
my $d2 = testdir;

my ($fh1,$fn1) = testfile($d1, SUFFIX => ".txt" );
print $fh1 "some content\n";

my $inode1 = (stat $fn1)[1];

my $s1 = -s $fn1;

# first copy it so it exists in destination
my $dest1 = catfile( $d2, basename $fn1 );
copy( $fn1, $d2 );

my $inode2 = (stat $dest1)[1];

isnt $inode1, $inode2,
    "after copy they have different inodes";

# then move it
print $fh1 "some more content\n";
my $s2 = -s $fn1;

isnt $s1, $s2, "two versions of file have different size";

my $new_dest = move( $fn1, $d2 );

like $new_dest,
    qr/ \Q (01).txt/x,
    "destination has counter";

my $inode3 = (stat $new_dest)[1];

is $inode1, $inode3,
    "inodes are same when moved to new filename";

is -s $new_dest, $s2,
    "the new named file has same content as the source";

done_testing;
