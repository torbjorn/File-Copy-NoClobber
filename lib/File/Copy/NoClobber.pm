package File::Copy::NoClobber;

use strict;
use warnings;
use Carp;

use parent 'Exporter';
use File::Copy ();
use File::Spec::Functions qw(splitpath catpath catfile);
use Fcntl;

our @EXPORT = qw(copy move);
our @EXPORT_OK = qw(cp mv);

my $pattern = " (%02d)";
my $MAX_COUNT = 5;

sub copy {

    my @args = @_;

    my($from,$to,$buffersize) = @args;

    my(undef,undef,$from_bn) = splitpath( $from );
    my $dest_file = -d $to ? catfile( $to, $from_bn ) : $to;

    if ( -f $from and ref $to ne "GLOB" ) {

        my $dest_file = catfile( $to, $from_bn );
        my $opened = sysopen my $fh, $dest_file, O_EXCL|O_CREAT|O_WRONLY;

        my $count = 0;
        my $fp = filename_with_sprintf_pattern( $dest_file );

        while (not $opened ) {

            $opened = sysopen
                $fh,
                ($dest_file = sprintf( $fp, ++$count )),
                O_CREAT|O_EXCL|O_WRONLY;

            if ($count > $MAX_COUNT) {
                die "Failed to find a nonclobbering filename, tried to increment counter $MAX_COUNT times: $!";
            }

        }

        binmode $fh;
        switch_off_buffering($fh);

        $args[1] = $fh;

    }

    # return destination filename, as it may be altered
    return File::Copy::copy(@args) && $dest_file;

}

sub move {
    File::Copy::move(@_);
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
