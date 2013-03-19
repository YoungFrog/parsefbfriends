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
my %friendlist = map { get_uid_and_name($_) } @divfriendlist;
$tree->delete();

map { printf "%s %s\n", $_, $friendlist{$_} } (keys %friendlist);

sub get_uid_and_name ($) {
  # $_[0] is an HTML::Element object whose HTML looks like:
  # <div class="fsl fwb fcb"><a data-hovercard="/ajax/hovercard/user.php?id=000000000"
  # href="https://www.facebook.com/nickname">Name First</a></div>

  # get the name
  my $name = $_[0]->as_text();
  $name =~ s/^\s*//; # strip leading spaces.

  # get the uid
  my $uid = $_[0]->as_HTML();
  if ($uid =~ /\?id=(\d+)/) {# only leave uid.
    $uid = $1;
  }
  else {
    $uid = 0
  }

  # we're done
  return $uid, $name;
}


sub show_help_and_exit {
  printf STDERR << "EOF";
$0 analyzes the HTML soup from ...
EOF
  exit
}
