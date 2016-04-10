#
#===============================================================================
#
#         FILE: Rumor.pm
#
#  DESCRIPTION: dickbott module for spreading rumors over pm
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Brandon K. Miller, brandonkentmiller@gmail.com
# ORGANIZATION: ---
#      VERSION: 1.0
#      CREATED: 10/04/2015 12:42:47 AM
#     REVISION: ---
#===============================================================================

package Dickbott::Rumor;
use strict;
use warnings;

#================================================
# new
# ---
# constructor
#================================================

sub new {
    my $class = shift;
    my $self  = { _nicks = undef };
    bless $self, $class;
    return $self;
} # constructor

#================================================
# get_nicks
# ---------
# get nick list in channel
#================================================

sub get_nicks {
    
} # function get_nicks

1;
 

