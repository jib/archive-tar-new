use ExtUtils::MakeMaker;
use strict;
use Getopt::Std;
use Config;
my $opt = {};
getopts( 'nd', $opt );

unless( $] >= 5.005_03 ) {
    die qq[Archive::Tar requires perl version 5.005_03 or higher to run\n];
}

if( !eval { require IO::Compress::Bzip2; 1 } and !$opt->{n} ) {
    warn    qq[You do not have IO::Compress::Bzip2 installed. This means you can ].
            qq[not read or write bzip2 compressed archives!\n] .
            qq[Note: you can disable this warning (and the prerequisite) ].
            qq[by invoking Makefile.PL with '-n'\n];
}

if( !$opt->{d} and not eval { require Text::Diff; 1 } ) {
    print   qq[\nArchive::Tar comes with a utility called 'ptardiff' which ].
            qq[lets you run diffs against tar archives.\n\nHowever, this ].
            qq[utility requires you to have Text::Diff installed.\n\n].
            qq[To add Text::Diff as a prerequisite, please supply the ].
            qq['-d' option when invoking this Makefile.PL.\n\n];
}

my $prereqs = {
    'Test::More'                    => 0,
    'Package::Constants'            => 0,
    'File::Spec'                    => 0.82,
    'Test::Harness'                 => 2.26,    # bug in older versions
    'IO::Zlib'                      => 1.01,
    # All these should be the same version, or breakage may occurr. See:
    # http://www.nntp.perl.org/group/perl.cpan.testers/2008/08/msg2083310.html
    # Requires at least 2.015, to address: #43609: Memory problem with A::T.
    # Turns out 2.012 was leaking memory.
    'IO::Compress::Base'            => 2.015,   # base class
    'Compress::Zlib'                => 2.015,   # zlib
    'IO::Compress::Gzip'            => 2.015,   # c::z needs this
    'IO::Compress::Bzip2'           => 2.015,   # bzip2 support
};


unless ($Config{useperlio}) {
    $prereqs->{'IO::String'} = 0;       # for better 'return stringified archive'
}

### ok, you didn't want IO::Zlib ###
delete $prereqs->{'IO::Compress::Bzip2'} if $opt->{n};

### so you want text::diff ###
$prereqs->{'Text::Diff'} = 0 if $opt->{d};


my @LICENSE;

push @LICENSE, 'LICENSE', 'perl' if $ExtUtils::MakeMaker::VERSION > 6.30;

WriteMakefile (
    NAME            => 'Archive::Tar',
    VERSION_FROM    => 'lib/Archive/Tar.pm', # finds $VERSION
    dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    EXE_FILES       => ['bin/ptar', 'bin/ptardiff'],
    PREREQ_PM       => $prereqs,
    INSTALLDIRS     => ( $] >= 5.009003 ? 'perl' : 'site' ),
    AUTHOR          => 'Jos Boumans <kane[at]cpan.org>',
	  ABSTRACT        => 'Manipulates TAR archives',
    @LICENSE,
);
