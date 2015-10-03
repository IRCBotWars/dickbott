#
#===============================================================================
#
#         FILE: IRC.pm
#
#  DESCRIPTION: IRC protocol logic
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Brandon Miller (r2dbg), r2dbg@hushmail.com
# ORGANIZATION: ---
#      VERSION: 1.0
#      CREATED: 10/03/2015 12:17:55 AM
#     REVISION: ---
#===============================================================================

package Dickbott::IRC;
use strict;
use warnings;

#=================================================
# new
# ---
# constructor
#=================================================

sub new {
    my ( $class, $server, $nick,
         $login, $channel, $pass ) = @_;

    my $self = {_server    => $server,
                _nick      => $nick,
                _login     => $login,
                _channel   => $channel,
                _pass      => $pass,
                _sock      => undef,
    };

    bless $self, $class;
    return $self;
} # constructor

#================================================
# rand_nick
# ----------
# generate random nick
#================================================

sub rand_nick {
    my @chars = ("A".."Z", "a".."z", "1" .. "9");
    my $nick = "";
    $nick .= $chars[rand @chars] for 1..16;
    return $nick
} # function rand_nick

#================================================
# derp_hangman
# ------------
# sabatoge hangman games
#================================================

sub derp_hangman {
    my ( $self, $prefix ) = @_;
    my $i;
    $self->{_nick} = rand_nick();
    $self->{_sock}->send("NICK $self->{_nick}\r\n");
    for ( $i = 0; $i < 6; $i++ ) {
        $self->{_sock}->send("PRIVMSG $self->{_channel} :$prefix" . " guess derpyderp\r\n");
    }
} # function derp_hangman

#================================================
# threaten_marty
# --------------
# ask marty to state his name
#================================================

sub threaten_marty {
    my $self = shift;
    $self->{_sock}->send("PRIVMSG $self->{_channel} :state your name!\r\n");
    $self->{_sock}->send("PRIVMSG $self->{_channel} " . "\x01" . "ACTION arms DDoS cannons\r\n");
} # function threaten_marty

#=================================================
# connect
# -----------
# connect to irc and join channel
#=================================================

sub connect {
    my $self = shift;

    $self->{_sock} = new IO::Socket::INET( PeerAddr => $self->{_server},
                                           PeerPort => 6667,
                                           Proto    => 'tcp'
    );

    unless ( $self->{_sock} ) {
        print "! failed to connect to IRCD\n";
        exit 1;
    }

    # identify
    print "* identifying as $self->{_nick}...\n";
    $self->{_sock}->send("NICK $self->{_nick}\r\n");
    $self->{_sock}->send("USER $self->{_login} 8 * :Theodore D. Swaggins\r\n");

    # read server reply until done
    my $input;
    while ( $self->{_sock}->recv($input, 1024) )
    {
        print $input;
        if ( $input =~ /004/ ) {
            last;
        } elsif ( $input =~ /^PING(.*)$/i ) {
            print $self->{_sock}, "PONG $1\r\n";
        } elsif ( $input =~ /433/ ) {
            print "! nickname is already in use";
            exit 1;
        }
    }

    print "* joining channel: $self->{_channel}\n";
    $self->{_sock}->send("JOIN $self->{_channel}\r\n");
} # function connect


#================================================
# cmd_loop
# ----------
# receive commands on loop
#================================================

sub cmd_loop {
    my $self = shift;
    
    my ( $prefix, $input );
    while ( 1 ) {
        $self->{_sock}->recv($input, 1024);
        print $input;
        chop $input;
        if ( $input =~ /^PING(.*)$/i ) {
            $self->{_sock}->send("PONG $1\r\n");

        } elsif ( $input =~ /(\S+hman) start/i ) {

            $prefix = substr($1, 1, length($1));
            if ( $input =~ /`kylt`/i ) {
                next;
            }

            sleep(3);
            if ( $input =~ /$self->{_channel}/i ) {
                derp_hangman($self->{_sock}, $prefix);
            }

        } elsif ( $input =~ /(\S+hman) guess/i ) {

            $prefix = substr($1, 1, length($1));
            if ( $input !~ /$self->{_channel}/i) {
                next;
            }

            derp_hangman($self->{_sock}, $prefix);

        } elsif ( $input =~ /Sphinx/i ) {
            threaten_marty($self->{_sock});
        }
    }
} # function cmd_loop

1;
