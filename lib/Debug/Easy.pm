#############################################################################
#####################     Easy Debugging Module     #########################
##################### Copyright 2013 Richard Kelsch #########################
#####################      All Rights Reserved      #########################
#############################################################################
####### Licensing information available near the end of this file. ##########
#############################################################################

package Debug::Easy;

use strict;

use Term::ANSIColor;
use Log::Fast;
use Time::HiRes qw(time);
use Data::Dumper::Simple;

BEGIN {
    require Exporter;
    # set the version for version checking
    our $VERSION   = 0.05;
    # Inherit from Exporter to export functions and variables
    our @ISA       = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT    = qw(@Levels);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK = qw();
}

# Not used, but exported if the coder wants to use it as some sort
# of index or reference.
our @Levels = qw( ERR WARN NOTICE INFO VERBOSE DEBUG DEBUGMAX );

my %ANSILevel = (); # Global debug level colorized messages hash.
my $LOG = Log::Fast->global();
my $MASTERSTART = time; # Script start timestamp.

=head1 NAME

Debug::Easy - A Handy Debugging Module

=head1 SYNOPSIS

 use Debug::Easy;

 my $debug = Debug::Easy->new( 'LogLevel' => 'DEBUG', 'Color' => 1 );

 my $debug_level = 'NOTICE';

 # $debug_level is the maximum level to report, and ignore the rest.
 # It must be the first parameter passed to the object, when outputing
 # a specific message.  This identifies to the module what type of
 # message it is.
 #
 # The following is a list, in order of level, of the parameter to
 # pass to the debug method:
 #
 #  ERR      = Error
 #  WARN     = Warning
 #  NOTICE   = Notice
 #  INFO     = Information
 #  VERBOSE  = Special version of INFO that does not output any
 #             Logging headings and goes to STDOUT instead of STDERR.
 #             Very useful for verbose modes in your scripts.
 #  DEBUG    = Level 1 Debugging messages
 #  DEBUGMAX = Level 2 Debugging messages

 $debug->debug(__LINE__,$debug_level,"Message");

 $debug->debug(__LINE__,'ERR',      ['Error message']);
 $debug->debug(__LINE__,'WARN',     ['Warning message']);
 $debug->debug(__LINE__,'NOTICE',   ['Notice message']);
 $debug->debug(__LINE__,'INFO',     ['Information and VERBOSE mode message']);
 $debug->debug(__LINE__,'DEBUG',    ['Level 1 Debug message']);
 $debug->debug(__LINE__,'DEBUGMAX', ['Level 2 Debug message']);

 my @messages = ('First Message','Second Message',"Third\nMessage");

 $debug->debug(__LINE__,$debug_level,\@messages);

=head1 DESCRIPTION

This module makes it easy to add debugging features to your code,
Without having to re-invent the wheel.  It uses STDERR and ANSI color
Formatted text output, as well as indented and multiline text
formatting, to make things easy to read.

Benchmarking is automatic, to make it easy to spot bottlenecks in code.
It automatically stamps from where it was called, and makes debug
coding so much easier, without having to include the location of the
debugging location in your debug message.  This is all taken care of
for you.

It also allows multiple output levels from errors only, to
warnings, to notices, to verbose information, to full on debug output.
All of this fully controllable by the coder.

It is essentially a smart wrapper on top of Log::Fast.

=head1 EXPORTED VARIABLES

=head2 @Levels

 A simple list of all the acceptable debug levels to pass to the {debug} method,
 and the {new} method.

=cut

END { # We spit out one last message before we die, the total execute time.
    my $bench = colored(['bright_cyan on_black'],sprintf('%06s',sprintf('%.02f',(time - $MASTERSTART))));
    $LOG->DEBUG(' %s%s %s',$bench,$ANSILevel{'DEBUG'}, colored(['black on_white'],'---- Script complete ----'));
}

=head1 METHODS

=head2 new

The parameter names are case insensitive as of Version 0.04.

=over 1

=item B<LogLevel> [level]

This adjusts the global log level of the Debug object.  It requires
a string.

=over 2

=item B<ERR> (default)

This level shows only error messages and all other messages are not
shown.

=item B<WARN>

This level shows error and warning messages.  All other messages are
not shown.

=item B<NOTICE>

This level shows error, warning, and notice messages.  All other
messages are not shown.

=item B<INFO>

This level shows error, warning, notice, and information messages.
Only debug level messages are not shown.

=item B<VERBOSE>

This level can be used as a way to do "Verbose" output for your
scripts.  It ouputs INFO level messages without logging headers
and on STDOUT instead of STDERR.

=item B<DEBUG>

This level shows error, warning, notice, information, and level 1
debugging messages.  Level 2 Debug messages are not shown.

=item B<DEBUGMAX>

This level shows all messages, including level 2 debugging messages.

=back

=item B<Color> [boolean] (Not case sensitive)

=over 2

=item B<0>, B<Off>, or B<False> (Off)

 This turns off colored output.  Everything is plain text only.

=item B<1>, B<On>, or B<True> (On - Default)

 This turns on colored output.  This makes it easier to spot all of
 the different types of messages throughout a sea of debug output.
 You can pipe the output to Less, and see color, by using it's
 switch "-r".

=back

=item B<TimeStamp> [pattern]

Make this an empty string to turn it off, otherwise:

=over 2

=item B<%T>

 Formats the timestamp as HH:MM:SS.  This is the default for the
 timestamp.

=item B<%S>

 Formats the timestamp as seconds.milliseconds.  Normally not needed,
 as the benchmark is more helpful.

=item B<%T %S>

 Combines both of the above.  Normally this is just too much, but here
 if you really want it.

=back

=item B<DateStamp> [pattern]

Make this an empty string to turn it off, otherwise:

=over 2

=item B<%D>

 Formats the datestamp as YYYY-MM-DD.  It is the default, and the only
 option.

=back

=item B<Type>

 Output type. Possible values are: 'fh' (output to any already open
 filehandle) and 'unix' (output to syslog using UNIX socket).

=over 2

=item B<fh>

 When set to 'fh', you have to also set {FileHandle} to any open filehandle
 (like "\*STDERR", which is the default).

=item B<unix>

 When set to 'unix', you have to also set {FileHandle} to a path pointing to an
 existing unix socket (typically it's '/dev/log').

=back

=item B<FileHandle>

 File handle to write log messages if {Type} set to 'fh' (which is the default).

 Syslog's UNIX socket path to write log messages if {Type} set to 'unix'.

=back

=cut

sub new {
    # This module uses the Log::Fast library heavily.  Many of the
    # Log::Fast variables and features can work here.
    my $class = shift;

    my $self = {
		'LogLevel'           => 'ERR',       # Default is errors only
		'Type'               => 'fh',
		'Path'               => '/var/log',
		'FileHandle'         => \*STDERR,
		'MasterStart'        => $MASTERSTART, # Pull in the script start timestamp
		'ERR_LastStamp'      => time,
		'WARN_LastStamp'     => time,
		'INFO_LastStamp'     => time,
		'NOTICE_LastStamp'   => time,
		'DEBUG_LastStamp'    => time,
		'DEBUGMAX_LastStamp' => time,
		'LOG'                => $LOG, # Pull in the global Log::Fast object.
		'Color'              => 1,
		'DateStamp'          => colored(['yellow on_black'],'%D'),
		'TimeStamp'          => colored(['yellow on_black'],'%T'),
		'Padding'            => -25,
		'Prefix'             => '',
		@_
    };
	my @Keys = (keys %{$self});
	foreach my $Key (@Keys) {
		my $upper = uc($Key);
		if ($Key ne $upper) {
			$self->{$upper} = $self->{$Key};
			# This fixes a documentation error for past versions
			$self->{$upper} = 'ERR' if ($upper eq 'LOGLEVEL' && $self->{$upper} =~ /^ERROR$/i);
			delete($self->{$Key});
		}
	}
    # This instructs the ANSIColor library to turn off coloring,
    # if the Color attribute is set to zero.
    $ENV{'ANSI_COLORS_DISABLED'} = 1 if ($self->{'COLOR'} =~ /0|FALSE|OFF/i);

    %ANSILevel = (
		'ERR'       => colored(['white on_red'],       '[ ERROR ]'),
		'WARN'      => colored(['black on_yellow'],    '[WARNING]'),
		'NOTICE'    => colored(['black on_magenta'],   '[NOTICE ]'),
		'INFO'      => colored(['white on_black'],     '[ INFO  ]'),
		'DEBUG'     => colored(['bold green on_black'],'[ DEBUG ]'),
		'DEBUGMAX'  => colored(['bold green on_black'],'[-DEBUG-]')
    );
    # This assembles the Time and Date stamping output.  If any of the
    # variables are blank, then that part will be disabled.
    $self->{'PREFIX'} = $self->{'DATESTAMP'} . ' ' . $self->{'TIMESTAMP'};

    # The Global loglevel is set here.
    if ($self->{'LOGLEVEL'} eq 'VERBOSE') {
		$self->{'LOG'}->level('INFO');
    } elsif ($self->{'LOGLEVEL'} eq 'DEBUGMAX') {
		$self->{'LOG'}->level('DEBUG');
    } else {
		$self->{'LOG'}->level( $self->{'LOGLEVEL'} );
    }

    $self->{'LOG'}->config({
							   'type'   => $self->{'TYPE'},
							   'path'   => $self->{'PATH'},
							   'prefix' => $self->{'PREFIX'},
							   'fh'     => $self->{'FILEHANDLE'}
						   });
    $self->{'LOG'}->DEBUG('   %.02f%s %s',0,$ANSILevel{'DEBUG'}, colored(['black on_white'],'----- Script begin -----'));
    bless($self,$class);
    return($self);
}

=head2 debug

The parameters must be passed in the order given

=over 1

=item B<LINE>

 The line number with which the debug was called.  Typically '__LINE__'

=item B<LEVEL>

 The log level with which this message is to be triggered

=item B<MESSAGE(S)>

 A string or list of strings to output line by line.

=back

=cut

sub debug {
    my $self  = shift;
    my $cline = shift;
    my $level = shift;
    my $msgs  = shift;

    my @messages;

    if (ref($msgs) eq 'SCALAR') {
		push(@messages,$msgs);
    } elsif (ref($msgs) eq 'ARRAY') {
		@messages = @{$msgs};
    } else {
		push(@messages,Dumper($msgs));
    }

    my ($package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask) = caller(1);
    if (! defined($subroutine) || $subroutine eq '') {
		$subroutine = 'main';
    }
    if (length($subroutine) > abs($self->{'PADDING'})) {
		$self->{'PADDING'} = 0 - length($subroutine);
    }
    my $thisBench  = sprintf('%7s',sprintf(' %.02f',time - $self->{$level . '_LASTSTAMP'})) . $ANSILevel{$level} . '[' . colored(['bold cyan on_black'],sprintf('%' . $self->{'PADDING'} . 's>%04d',$subroutine,$cline)) . ']';
    my $thisBench2 = ' ' x 7 . $ANSILevel{$level} . '[' . colored(['bold cyan on_black'],sprintf('%' . $self->{'PADDING'} . 's>%04d',$subroutine,$cline)) . ']';
    my $nested = do { my $n=0; 1 while caller(2 + $n++); ' ' x $n };
	my $first = 1;
    foreach my $msg (@messages) {
		if ($msg =~ /\n/s) {
			my @message = split(/\n/,$msg);
			foreach my $line (@message) {
				if ($level eq 'INFO' && $self->{'LOGLEVEL'} eq 'VERBOSE') {
					$self->{'LOG'}->config({'prefix' => ''});
					$self->{'LOG'}->$level($line);
					$self->{'LOG'}->config({'prefix' => $self->{'PREFIX'}});
				} elsif ($level eq 'DEBUGMAX') {
					if ($self->{'LOGLEVEL'} eq 'DEBUGMAX') {
						if ($first) {
							$self->{'LOG'}->DEBUG($thisBench . $nested . $line);
						} else {
							$self->{'LOG'}->DEBUG($thisBench2 . $nested . $line);
						}
					}
				} else {
					if ($first) {
						$self->{'LOG'}->$level($thisBench . $nested . $line);
					} else {
						$self->{'LOG'}->$level($thisBench2 . $nested . $line);
					}
				}
				$first = 0;
			}
		} else {
			if ($level eq 'INFO' && $self->{'LOGLEVEL'} eq 'VERBOSE') {
				$self->{'LOG'}->config({'prefix' => ''});
				$self->{'LOG'}->INFO($msg);
				$self->{'LOG'}->config({'prefix' => $self->{'PREFIX'}});
			} elsif ($level eq 'DEBUGMAX') {
				if ($self->{'LOGLEVEL'} eq 'DEBUGMAX') {
					$self->{'LOG'}->DEBUG($thisBench . $nested . $msg);
				}
			} else {
				$self->{'LOG'}->$level($thisBench . $nested . $msg);
			}
		}
		$first = 0;
    }
    $self->{$level . '_LASTSTAMP'} = time;
}

=head1 AUTHOR

Richard Kelsch <rich@rk-internet.com>

Copyright 2013 Richard Kelsch, All Rights Reserved.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 VERSION

Version 0.05    (April 14, 2014)

=head1 BUGS

Please report any bugs or feature requests to C<bug-easydebug at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=EasyDebug>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Debug::Easy


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Debug-Easy>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Debug-Easy>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Debug-Easy>

=item * Search CPAN

L<http://search.cpan.org/dist/Debug-Easy/>

=back

=head1 ACKNOWLEDGEMENTS

The author of Log::Fast.  A very fine module, without which, this module
would be much larger.

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Richard Kelsch.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;

__END__

