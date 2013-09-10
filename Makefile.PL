use strict;
use warnings;

use 5.008001;

use ExtUtils::MakeMaker 6.30;

my %WriteMakefileArgs = (
    "ABSTRACT_FROM" => "lib/Sys/PageCache.pm",
    "AUTHOR" => "HIROSE Masaaki",
    "BUILD_REQUIRES" => {},
    "CONFIGURE_REQUIRES" => {
        "ExtUtils::MakeMaker" => "6.30"
    },
    "DISTNAME" => "Sys-PageCache",
    "EXE_FILES" => [
        "bin/pagecache-check.pl",
        "bin/pagecache-clear.pl",
    ],
    "LICENSE" => "perl",
    "NAME" => "Sys::PageCache",
    "PREREQ_PM" => {
        "Pod::Usage" => "1.36",
    },
    "TEST_REQUIRES" => {
        "Test::More" => 0
    },
    "VERSION_FROM" => "lib/Sys/PageCache.pm",
    "test" => {
        "TESTS" => "t/*.t"
    },
    LIBS   => [''],
    DEFINE => '',
    INC    => '-I.',
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
    my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
    my $br = $WriteMakefileArgs{BUILD_REQUIRES};
    for my $mod ( keys %$tr ) {
        if ( exists $br->{$mod} ) {
            $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
        } else {
            $br->{$mod} = $tr->{$mod};
        }
    }
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
    my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
    my $pp = $WriteMakefileArgs{PREREQ_PM};
    for my $mod ( keys %$br ) {
        if ( exists $pp->{$mod} ) {
            $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
        } else {
            $pp->{$mod} = $br->{$mod};
        }
    }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
    unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
