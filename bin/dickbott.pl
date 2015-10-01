#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: dickbott.pl
#
#        USAGE: ./dickbott.pl  
#
#  DESCRIPTION: IRC bot derper
#
#       AUTHOR: Brandon Miller (r2dbg), r2dbg@hushmail.com
#===============================================================================

use strict;
use warnings;
use utf8;
use Getopt::Long;
use IO::Socket;

my $server   = "irc.haxzor.ninja";
my $nick     = "dickbott";
my $login    = "dickbott";
my $channel  = "#viper";
my $pass     = "derpyderp";

##################################################
# rand_nick
# ----------
# generate random nick
##################################################

sub rand_nick {
    my @chars = ("A".."Z", "a".."z", "1" .. "9");
    my $nick;
    $nick .= $chars[rand @chars] for 1..16;
    return $nick
} # function rand_nick

##################################################
# print_help
# ----------
# Display help menu
##################################################

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

##################################################
# irc_connect
# -----------
# connect to irc and join channel
##################################################

sub irc_connect {
    my $sock = new IO::Socket::INET(PeerAddr => $server,
                                    PeerPort => 6667,
                                    Proto    => 'tcp'
    );

    unless ( $sock ) {
        print "! failed to connect to IRCD\n";
        exit 1;
    }

    # identify
    print "* identifying as $nick...\n";
    print $sock "NICK $nick\r\n";
    print $sock "USER $login 8 * :Theodore D. Swaggins\r\n";

    # read server reply until done
    while ( my $input = <$sock> )
    {
        print $input;
        if ( $input =~ /004/ ) {
            last;
        } elsif ( $input =~ /^PING(.*)$/i ) {
            print $sock "PONG $1\r\n";
        } elsif ( $input =~ /433/ ) {
            print "! nickname is already in use";
            exit 1;
        }
    }

    print "* joining channel: $channel\n";
    print $sock "JOIN $channel\r\n"; 
    return $sock;
} # function irc_connect

##################################################
# derp_hangman
# ------------
# sabatoge hangman games
##################################################

sub derp_hangman {
    my ( $sock, $prefix ) = @_;
    my $i;
    my $nick = rand_nick();
    print $sock "NICK $nick\r\n";
    for ( $i = 0; $i < 6; $i++ ) {
        print $sock "PRIVMSG $channel :$prefix" . " guess derpyderp\r\n";
    }
} # function derp_hangman

##################################################
# threaten_marty
# --------------
# ask marty to state his name
##################################################

sub threaten_marty {
    my $sock = shift;
    print $sock "PRIVMSG $channel :state your name!\r\n";
    print $sock "PRIVMSG $channel " . "\x01" . "ACTION arms DDoS cannons\r\n";
} # function threaten_marty

##################################################
# cmd_loop
# ----------
# receive commands on loop
##################################################

sub cmd_loop {
    my $sock = shift;
    my $prefix;

    # cmd loop
    while ( my $input = <$sock> ) {
        print $input;
        chop $input;
        if ( $input =~ /^PING(.*)$/i ) {
            print $sock "PONG $1\r\n";

        } elsif ( $input =~ /(\S+hman) start/i ) {
            
            $prefix = substr($1, 1, length($1));
            if ( $input =~ /`kylt`/i ) {
                next;
            }

            sleep(3);
            if ( $input =~ /$channel/i ) {
                derp_hangman($sock, $prefix);
            }

        } elsif ( $input =~ /(\S+hman) guess/i ) {
            
            $prefix = substr($1, 1, length($1));
            if ( $input !~ /$channel/i) {
                next;
            }

            derp_hangman($sock, $prefix);
        
        } elsif ( $input =~ /Sphinx/i ) {
            threaten_marty($sock);
        }
    }
}

##################################################
# do_work
# -------
# parse args and run app
##################################################

sub do_work {
    my ( $help, $sock );

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
    
    # connect to server and enter cmd loop
    $sock = irc_connect($server);
    cmd_loop($sock);
} # function do_work

do_work();
