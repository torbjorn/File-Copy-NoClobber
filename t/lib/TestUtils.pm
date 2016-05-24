package t::lib::TestUtils;

use strict;
use warnings;

use File::Temp qw(tempfile tempdir);

use parent 'Exporter';
our @EXPORT = qw(testdir testfile);

sub testdir {
    return tempdir(@_, CLEANUP => 1);
}

sub testfile {

    my $dir = shift;
    $dir //= tempdir;

    my @f = tempfile( @_, DIR => $dir, UNLINK => 1 );

    do {
        my $h = select $f[0];
        $|=1;
        select $h;
    };

    return(@f);

}

1;
