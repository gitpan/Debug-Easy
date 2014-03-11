use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Debug::Easy',
    AUTHOR           => q{Richard Kelsch <rich@rk-internet.com>},
    VERSION_FROM     => 'lib/Debug/Easy.pm',
    ABSTRACT_FROM    => 'lib/Debug/Easy.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
		'Data::Dumper::Simple' => 0,
		'Log::Fast' => 0,
		'Time::HiRes' => 0,
		'Term::ANSIColor' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Debug-Easy-*' },
);
