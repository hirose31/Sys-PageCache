package Sys::PageCache;

use strict;
use warnings;
use Carp;
use base qw(Exporter);
our @EXPORT = qw(fincore fadvise);
our @EXPORT_OK = qw(_fincore _fadvise);

our $VERSION = '0.01_001';

use POSIX;
use Log::Minimal;

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
    }

    my $fsize = (stat $file)[7];
    if (! $length) {
        $length = $fsize;
    } elsif ($length > $fsize) {
        warnf("length(%llu) is greater than file size(%uul). so use file size", $length, $fsize);
        $length = $fsize;
    }

    debugf("offset: %llu", $offset);
    debugf("length: %llu", $length);

    my $r = _fincore($fd, $offset, $length);

    $r->{file_size}   = $fsize;
    $r->{total_pages} = ceil($fsize / $r->{page_size});

    return $r;
}

sub fadvise {
    my($file, $offset, $length, $advice) = @_;

    open my $fh, '<', $file or croak $!;
    my $fd = fileno $fh;

    if (! $offset) {
        $offset = 0;
    } elsif ($offset < 0) {
        croak "offset must be >= 0";
    }

    my $fsize = (stat $file)[7];
    if (! $length) {
        $length = $fsize;
    } elsif ($length > $fsize) {
        warnf("length(%llu) is greater than file size(%uul). so use file size", $length, $fsize);
        $length = $fsize;
    }

    debugf("offset: %llu", $offset);
    debugf("length: %llu", $length);

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
