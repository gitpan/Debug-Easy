#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok('Debug::Easy') || print "Bail out!\n";
}

# diag( "Testing Debug::Easy $Debug::Easy::VERSION, Perl $], $^X" );
