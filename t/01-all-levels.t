#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 114;    # 6 * 19

use Debug::Easy;
my @LogLevel = qw( ERR WARN NOTICE INFO DEBUG DEBUGMAX );
my @CodeLevel = ('[ ERROR ]', '[WARNING]', '[NOTICE ]', '[ INFO  ]', '[ DEBUG ]', '[-DEBUG-]');

SKIP: {

    my ($major, $minor, $Sub) = split(/\./, substr($^V, 1));
    my $version = 0 + sprintf('%d.%03d%03d', $major, $minor, $Sub);

    skip 'Perl version < 5.10 skipping tests', 114 if ($version < 5.010);

    my $stderr;

    open(OUTPUT, '>', \$stderr);
    foreach my $LEVEL (0 .. 5) {
        my $debug = Debug::Easy->new('LogLevel' => $LogLevel[$LEVEL], 'Color' => 1, 'FileHandle' => \*OUTPUT);
        isa_ok($debug, 'Debug::Easy');

        foreach my $count (0 .. 5) {
            $stderr = '';
            if ($count <= $LEVEL) {
                $debug->debug(__LINE__, $LogLevel[$count], $LogLevel[$count] . ' Single Line Message Test');
                like($stderr, qr/$CodeLevel[$count]/, $LogLevel[$count] . ' Single Line Scalar Message Test');
                $stderr = '';
                $debug->debug(__LINE__, $LogLevel[$count], $LogLevel[$count] . "Multi-Line Scalar\nMessage Test");
                like($stderr, qr/$CodeLevel[$count]/, $LogLevel[$count] . ' Multi-Line Scalar Message Test');
                $stderr = '';
                $debug->debug(__LINE__, $LogLevel[$count], [$LogLevel[$count] . ' Multi-Line', 'Array', 'Message Test']);
                like($stderr, qr/$CodeLevel[$count]/, $LogLevel[$count] . ' Multi-Line Array Message Test');
            } else {
                $debug->debug(__LINE__, $LogLevel[$count], $LogLevel[$count] . ' Single Line Message Test');
                unlike($stderr, qr/$CodeLevel[$count]/, $LogLevel[$count] . ' Single Line Scalar Message Test');
                $stderr = '';
                $debug->debug(__LINE__, $LogLevel[$count], $LogLevel[$count] . "Multi-Line Scalar\nMessage Test");
                unlike($stderr, qr/$CodeLevel[$count]/, $LogLevel[$count] . ' Multi-Line Scalar Message Test');
                $stderr = '';
                $debug->debug(__LINE__, $LogLevel[$count], [$LogLevel[$count] . ' Multi-Line', 'Array', 'Message Test']);
                unlike($stderr, qr/$CodeLevel[$count]/, $LogLevel[$count] . ' Multi-Line Array Message Test');
            }
        } ## end foreach my $count (0 .. 5)
    } ## end foreach my $LEVEL (0 .. 5)
} ## end SKIP:
