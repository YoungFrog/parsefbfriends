#!/usr/bin/env perl
use strict;
use warnings;
use HTML::TreeBuilder;
binmode STDOUT, ":utf8"; # spit utf8 to terminal
use utf8; # allow for utf8 inside the code.
use IO::HTML;
# use Data::ICal;
# use Data::ICal::Entry::Event;
# use diagnostics;
# use feature "switch";

# require 5.004;
# use POSIX qw(locale_h);
# use locale;
# use Date::ICal;
use DateTime;

my $file;

## Parse arguments
# while(shift) will not work (scope problem ?)
# while($_ = shift) will usually work, except if the value was one to
# be interpreted as false (e.g. 0)
while (defined($_ = shift)) {
  if (!defined($file)) {
    $file = $_;
    unless (-f $file) { show_help_and_exit(); }
  } else {
    print STDERR "Unrecognized option.\n";
    show_help_and_exit();
  }
}
## Arguments parsed.

my $tree = HTML::TreeBuilder->new;
my $filehandle = html_file($file);
$tree->parse_file($filehandle);

my @divfriendlist = $tree->look_down("_tag","div","class","fsl fwb fcb");
my @friendlist = map { my $name = $_->as_text(); $name =~ s/^\s*//; $name } @divfriendlist;
$tree->delete();

map { printf "%s\n", $_ } @friendlist;

sub show_help_and_exit {
  printf STDERR << "EOF";
$0 analyzes the HTML soup from ...
EOF
  exit
}
