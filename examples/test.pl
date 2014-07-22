#!/usr/bin/perl
use 5.006;
use strict;

use Debug::Easy;
my @LogLevel = qw( ERR WARN NOTICE INFO DEBUG DEBUGMAX );
my @CodeLevel = ('[ ERROR ]', '[WARNING]', '[NOTICE ]', '[ INFO  ]', '[ DEBUG ]', '[-DEBUG-]');

foreach my $LEVEL (0 .. 5) {
    print STDERR "\n---- Showing When Log Level is Set To $LogLevel[$LEVEL] ----\n\n";
    my $debug = Debug::Easy->new('LogLevel' => $LogLevel[$LEVEL], 'Color' => 1, 'Padding' => -5);

    foreach my $count (0 .. 5) {
        $debug->debug(__LINE__, $LogLevel[$count], $LogLevel[$count] . ' Single Line Message Test');
        $debug->debug(__LINE__, $LogLevel[$count], $LogLevel[$count] . " Multi-Line Scalar\nMessage Test");
        $debug->debug(__LINE__, $LogLevel[$count], [$LogLevel[$count] . ' Multi-Line', 'Array', 'Message Test']);
    } ## end foreach my $count (0 .. 5)
} ## end foreach my $LEVEL (0 .. 5)

exit(0);
