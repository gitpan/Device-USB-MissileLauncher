package Device::USB::MissileLauncher;

use strict;
use warnings;

use Device::USB;
#use Data::Dumper;

our $VERSION = '0.01';
our $timeout = 1000;

sub new {
  my $class = shift;
  my $inita = join ('', map { chr $_ } (85, 83, 66, 67,  0,  0,  4,  0)); # 8 bytes
  my $initb = join ('', map { chr $_ } (85, 83, 66, 67,  0, 64,  2,  0));
  my $usb = Device::USB->new();
  my $dev = $usb->find_device(0x1130,0x0202);
  $dev->open() || die "$!";
  $dev->set_configuration(1);
  $dev->claim_interface(0);
  $dev->claim_interface(1);
  my $self = {};
  $self->{dev} = $dev;
  return bless $self, $class;
}

sub do {
  my $self = shift;
  my $command = shift;

  my $command_string = {};
  my $command_fill = join ('', map { chr $_ } ( 8,  8,
						0,  0,  0,  0,  0,  0,  0,  0,
						0,  0,  0,  0,  0,  0,  0,  0,
						0,  0,  0,  0,  0,  0,  0,  0,
						0,  0,  0,  0,  0,  0,  0,  0,
						0,  0,  0,  0,  0,  0,  0,  0,
						0,  0,  0,  0,  0,  0,  0,  0,
						0,  0,  0,  0,  0,  0,  0,  0)); # 58 bytes
  $command_string->{stop}          = join('', map { chr $_ } ( 0,  0,  0,  0,  0,  0)).$command_fill;
  $command_string->{left}          = join('', map { chr $_ } ( 0,  1,  0,  0,  0,  0)).$command_fill;
  $command_string->{right}         = join('', map { chr $_ } ( 0,  0,  1,  0,  0,  0)).$command_fill;
  $command_string->{up}            = join('', map { chr $_ } ( 0,  0,  0,  1,  0,  0)).$command_fill;
  $command_string->{down}          = join('', map { chr $_ } ( 0,  0,  0,  0,  1,  0)).$command_fill;
  $command_string->{leftup}        = join('', map { chr $_ } ( 0,  1,  0,  1,  0,  0)).$command_fill;
  $command_string->{rightup}       = join('', map { chr $_ } ( 0,  0,  1,  1,  0,  0)).$command_fill;
  $command_string->{leftdown}      = join('', map { chr $_ } ( 0,  1,  0,  0,  1,  0)).$command_fill;
  $command_string->{rightdown}     = join('', map { chr $_ } ( 0,  0,  1,  0,  1,  0)).$command_fill;
  $command_string->{fire}          = join('', map { chr $_ } ( 0,  0,  0,  0,  0,  1)).$command_fill;

  return -1 unless exists $command_string->{$command};
  $self->{dev}->control_msg(0x21,9,0x2,0x0,$command_string->{$command},64,$timeout);
}

1;

=head1 NAME

Device::USB::MissileLauncher - interface to toy USB missile launchers

=head1 SYNOPSIS

  use Device::USB::MissileLauncher;
  my $ml = Device::USB::MissileLauncher->new();
  $ml->do('left');
  $ml->do('up');
  $ml->do('fire');

=head1 DESCRIPTION

This implements a basic interface to the toy USB missile launchers that were on sale
in Marks and Spencers Christmas 2005 and later at 'I want one of those'. 

It has two methods - new() and do(). do() takes a string out of the following list.

  stop
  left
  right
  up
  down
  leftup
  rightup
  leftdown
  rightdown
  fire

=head1 AUTHOR

Greg McCarroll <greg@mccarroll.org.uk>

=head1 COPYRIGHT

Copyright 2006 Greg McCarroll. All Rights Reserved.

This program is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

=head1 SEE ALSO

Device::USB

=cut