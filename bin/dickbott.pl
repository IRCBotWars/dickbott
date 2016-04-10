#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: dickbott.pl
#
#        USAGE: ./dickbott.pl  
#
#  DESCRIPTION: IRC bot derper
#
#       AUTHOR: Brandon K. Miller, brandonkentmiller@gmail.com
#===============================================================================

use strict;
use warnings;
use utf8;
use Getopt::Long;
use IO::Socket;
use lib "../lib/Dickbott";
use IRC;

#=================================================
# print_help
# ----------
# Display help menu
#=================================================

sub print_help {
    my $usage = <<EOF;

$0 [options]:
    --help    display this menu
    --server [url]       IRC server URL
                           DEFAULT irc.haxzor.ninja
    --nick [nick]        IRC nickname
                           DEFAULT dickbott
    --login [login]      IRC login (username)
                           DEFAULT dickbott
    --channel [chan]     IRC channel to join on connection
                           DEFAULT #viper
    --password [pass]    Nickname password
EOF

    print $usage;
} # function print_help

#=================================================
# do_work
# -------
# parse args and run app
#=================================================

sub do_work {
    my ( $help, $pass );
    my $server   = "irc.haxzor.ninja";
    my $nick     = "dickbott";
    my $login    = "dickbott";
    my $channel  = "#viper";

    GetOptions(
        "help",       => \$help,
        "server=s",   => \$server,
        "nick=s",     => \$nick,
        "login=s",    => \$login,
        "channel=s",  => \$channel,
        "password=s", => \$pass,
    );

    if ( defined($help) ) {
        print_help();
        exit 0;
    }

    unless ( defined($pass) ) {
        print "! missing required arg: --password\n";
        exit 1;
    }

    print "* connecting to server: $server...\n";

    my $irc = Dickbott::IRC->new($server, $nick, $login, $channel, $pass);
    $irc->connect();
    $irc->cmd_loop();
} # function do_work

do_work();
