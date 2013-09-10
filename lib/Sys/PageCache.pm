package Sys::PageCache;

use strict;
use warnings;
use Carp;
use base qw(Exporter);
our @EXPORT = qw(page_size fincore fadvise
                 POSIX_FADV_NORMAL
                 POSIX_FADV_SEQUENTIAL
                 POSIX_FADV_RANDOM
                 POSIX_FADV_NOREUSE
                 POSIX_FADV_WILLNEED
                 POSIX_FADV_DONTNEED
            );
our @EXPORT_OK = qw();

our $VERSION = '0.01_001';

use POSIX;

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

sub fincore {
    my($file, $offset, $length) = @_;

    open my $fh, '<', $file or croak $!;
    my $fd = fileno $fh;

    if (! $offset) {
        $offset = 0;
    } elsif ($offset < 0) {
        croak "offset must be >= 0";
    } else {
        my $pa_offset = $offset & ~(page_size() - 1);
        if ($pa_offset != $offset) {
            carp(sprintf "[WARN] offset must be a multiple of the page size so change %llu to %llu",
                 $offset,
                 $pa_offset,
             );
            $offset = $pa_offset;
        }
    }

    my $fsize = (stat $file)[7];
    if (! $length) {
        $length = $fsize;
    } elsif ($length > $fsize - $offset) {
        my $new_length = $fsize - $offset;
        carp(sprintf "[WARN] fincore: length(%llu) is greater than file size(%llu) - offset(%llu). so use file size - offset (=%llu)",
             $length,
             $fsize,
             $offset,
             $new_length,
         );
        $length = $new_length;
    }

    my $r = _fincore($fd, $offset, $length);

    $r->{file_size}   = $fsize;
    $r->{total_pages} = ceil($fsize / $r->{page_size});

    return $r;
}

sub fadvise {
    my($file, $offset, $length, $advice) = @_;

    croak "missing advice" unless defined $advice;
    croak "missing length" unless defined $length;
    croak "missing offset" unless defined $offset;
    croak "missing file"   unless defined $file;

    croak "offset must be >= 0" if $offset < 0;

    my $fsize = (stat $file)[7];
    if ($length > $fsize - $offset) {
        my $new_length = $fsize - $offset;
        carp(sprintf "[WARN] fadvise: length(%llu) is greater than file size(%llu) - offset(%llu). so use file size - offset (=%llu)",
             $length,
             $fsize,
             $offset,
             $new_length,
         );
        $length = $new_length;
    }

    open my $fh, '<', $file or croak $!;
    my $fd = fileno $fh;

    return _fadvise($fd, $offset, $length, $advice);
}

1;
__END__

=head1 NAME

Sys::PageCache -

=head1 SYNOPSIS

  use Sys::PageCache;

=head1 DESCRIPTION

Sys::PageCache is

=head1 AUTHOR

HIROSE Masaaki E<lt>hirose31 _at_ gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
