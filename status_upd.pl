#!/usr/bin/perl -w
# status_upd.pl [1.04_26]
# process perlall-maketest logfiles: `perl$ver Makefile.PL && make test > log.test-$platform-$ver; make clean`
use strict;

my $logs = "log.test-*";
my $dir = ".";
my $STATUS = "./STATUS";

chdir ".." if ! -d "t" and -d "../t";
chdir "../.." if ! -d "t" and -d "../../t";

if (@ARGV and -d "t/reports/$ARGV[0]") {
  $dir = "t/reports/".$ARGV[0];
}
if (@ARGV and -d $ARGV[0]) {
  $dir = $ARGV[0];
}

die "$STATUS not found\n" unless -f $STATUS;

# update the TEST STATUS section in "./STATUS"
my $cmd = 'grep -B1 "Failed tests" ' . ($dir eq '.' ? "$logs" : "$dir/$logs");
print STDERR "$cmd\n";
my @g = `$cmd` or die $@;
my $s = "";
my $prefix = '';

while (@g) {
  if ($g[0] =~ /^--/) {
    $prefix = '';
    shift @g;
    next;
  }
  my $file = shift @g;
  my $failed = shift @g;
  unless ($prefix) {
    ($prefix) = $file =~ m{log.test-(.*?)-t/};
    $s .= "\n$prefix:\n";
    print STDERR "\n$prefix:\n";
  }
  ($file) = $file =~ m{(t/[\w\.]+\s?)};
  chomp $file if $file;
  $failed =~ s{^.+Failed tests:}{Failed tests:};
  chomp $failed;
  my $c = "$file\t";
  $c .= "\t" if length($file) < 8;
  $c .= "$failed\n";
  print STDERR "$c";
  $s .= $c;
}

#print $s;
exit;

use vars qw($Is_W32 $Is_OS2 $Is_Cygwin $Is_NetWare $Needs_Write);
use Config; # Remember, this is running using an existing perl
$Is_W32 = $^O eq 'MSWin32';
$Is_OS2 = $^O eq 'os2';
$Is_Cygwin = $^O eq 'cygwin';
$Is_NetWare = $Config{osname} eq 'NetWare';
if ($Is_NetWare) {
  $Is_W32 = 0;
}

$Needs_Write = $Is_OS2 || $Is_W32 || $Is_Cygwin || $Is_NetWare;

sub safer_unlink {
  my @names = @_;
  my $cnt = 0;

  my $name;
  foreach $name (@names) {
    next unless -e $name;
    chmod 0777, $name if $Needs_Write;
    ( CORE::unlink($name) and ++$cnt
      or warn "Couldn't unlink $name: $!\n" );
  }
  return $cnt;
}

sub safer_rename_silent {
  my ($from, $to) = @_;

  # Some dosish systems can't rename over an existing file:
  safer_unlink $to;
  chmod 0600, $from if $Needs_Write;
  rename $from, $to;
}

sub safer_rename {
  my ($from, $to) = @_;
  safer_rename_silent($from, $to) or die "renaming $from to $to: $!";
}
