use strict;
use warnings;
use Test::More tests => 1;

use File::Spec;
use FindBin '$Bin';
use Archive::Tar;

# filenames
my $tartest = File::Spec->catfile("t", "tartest");
my $foo = File::Spec->catfile("t", "tartest", "foo");
my $bar = File::Spec->catfile("t", "tartest", "bar");
my $tarfile = File::Spec->catfile("t", "tartest.tar");
my $ptardiff = File::Spec->catfile($Bin, "..", "bin", "ptardiff");
my $cmd = "$^X $ptardiff $tarfile";

# create directory/files
mkdir $tartest;
open my $fh, ">", $foo or die $!;
print $fh "file foo\n";
close $fh;
open $fh, ">", $bar or die $!;
print $fh "file bar\n";
close $fh;

# create archive
my $tar = Archive::Tar->new;
$tar->add_files($foo, $bar);
$tar->write($tarfile);

# change file
open $fh, ">>", $foo or die $!;
print $fh "added\n";
close $fh;

# see if ptardiff shows the changes
my $out = qx{$cmd};
cmp_ok($out, '=~', qr{^\+added$}m, "ptardiff shows added text");

# cleanup
END {
    unlink $tarfile;
    unlink $foo or die $!;
    unlink $bar or die $!;
    rmdir $tartest or die $!;
}
