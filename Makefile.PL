use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'Debug::Easy',
    AUTHOR             => q{Richard Kelsch <rich@rk-internet.com>},
    VERSION_FROM       => 'lib/Debug/Easy.pm',
    ABSTRACT_FROM      => 'lib/Debug/Easy.pm',
    LICENSE            => 'Artistic_2_0',
    PL_FILES           => {},
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker'  => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM      => {
        'Data::Dumper::Simple' => 0,
        'Log::Fast'            => 0,
        'Time::HiRes'          => 0,
        'Term::ANSIColor'      => 4.00,
    },
    dist  => {COMPRESS => 'gzip -9f', SUFFIX => 'gz',},
    clean => {FILES    => 'Debug-Easy-*'},
);

sub MY::test {
    qq{
TEST_VERBOSE=0
TEST_TYPE=test_\$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/*.t
TESTDB_SW = -d

testdb :: testdb_\$(LINKTYPE)

test :: \$(TEST_TYPE) subdirs-test

subdirs-test ::
\t\$(NOECHO) \$(NOOP)


test_dynamic :: pure_all
\tPERL_DL_NONLAZY=1 \$(FULLPERLRUN) "-MExtUtils::Command::MM" "-MTest::Harness" "-e" "undef *Test::Harness::Switches; test_harness(\$(TEST_VERBOSE), '\$(INST_LIB)', '\$(INST_ARCHLIB)')" \$(TEST_FILES)

testdb_dynamic :: pure_all
\tPERL_DL_NONLAZY=1 \$(FULLPERLRUN) \$(TESTDB_SW) "-I\$(INST_LIB)" "-I\$(INST_ARCHLIB)" \$(TEST_FILE)

test_ : test_dynamic

test_static :: test_dynamic
testdb_static :: testdb_dynamic

}
} ## end sub MY::test
