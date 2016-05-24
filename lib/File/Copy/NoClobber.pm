package File::Copy::NoClobber;

use strict;
use warnings;
use Carp;

use parent 'Exporter';
use File::Copy ();
use File::Spec::Functions qw(splitpath catpath catfile);
use File::Basename qw(basename dirname);
use Fcntl;

our @EXPORT = qw(copy move);

my $pattern = " (%02d)";
my $MAX_COUNT = 1e4;

sub _declobber {

    my($from,$to) = @_;

    my $from_bn = basename $from;
    my $dest_file = -d $to ? catfile( $to, $from_bn ) : $to;

    my $fh;

    if ( -f $from and ref $to ne "GLOB" ) {

        if ( !-d dirname $to ) {
            croak "Invalid destination, should be in an existing directory";
        }

        # use eval in case autodie or friends get in here
        my $opened = eval {
            sysopen $fh, $dest_file, O_EXCL|O_CREAT|O_WRONLY;
        };

        my $count = 0;
        my $fp = filename_with_sprintf_pattern( $dest_file );

        while (not $opened and $! =~ /File exists/i ) {

            $opened = eval {
                sysopen
                    $fh,
                    ($dest_file = sprintf( $fp, ++$count )),
                    O_CREAT|O_EXCL|O_WRONLY;
            };

            if ($count > $MAX_COUNT) {
                croak "Failed to find a nonclobbering filename, tried to increment counter $MAX_COUNT times";
            }

        }

        if (not fileno $fh) {
            croak $!;
        }

        binmode $fh;
        switch_off_buffering($fh);

    }

    return ($fh,$dest_file);

}

sub copy {

    my @args = @_;

    my($from,$to,$buffersize) = @args;

    my($fh,$dest_file) = _declobber($from,$to);

    $args[1] = $fh // $dest_file;

    # return destination filename, as it may be altered
    return File::Copy::copy(@args) && $dest_file;

}

sub move {

    my @args = @_;

    my($from,$to,$buffersize) = @args;

    my($fh,$dest_file) = _declobber($from,$to);
    close $fh;

    $args[1] = $dest_file;

    # return destination filename, as it may be altered
    return File::Copy::move(@args) && $dest_file;

}

sub filename_with_sprintf_pattern {

    (my $path = shift) =~ s/%/%%/g;

    my($vol,$dir,$fn) = splitpath($path);

    if ( $fn =~ /\./ ) {
        $fn =~

            s{    (?= \. [^\.]+ $ )   }
             {        $pattern        }ex

            or die "Failed inserting noclobbering pattern into file";
    }
    else {
       $fn .= $pattern;
    }

    return catpath($vol,$dir,$fn);

}

sub switch_off_buffering {
    my $h = select(shift);
    $|=1;
    select($h);
}

1;

=head1 NAME

File::Copy::NoClobber - Rename copied files safely if destionation exists

=head1 SYNOPSIS



=head1 DESCRIPTION



=cut
