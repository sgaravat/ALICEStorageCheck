#!/usr/bin/perl

use DateTime;
use Date::Parse;
use File::SortedSeek ':all';

#
# INPUT
#
# File provided by the experiment (Costin)
# Sorted and converted in lowercase
$AliceFiles="ALICE.sorted.lower";

# The date when the above file was produced
my $ListCreationDate = DateTime->new(
    year       => 2013,
    month      => 6,
    day        => 25
    );

# The name of the filesystem to check
$FileSystem="xrdpool-01-disk1";

# Input file containing the output of ls -l issued on the xrddate directory of
# the file system
$FilesOnDiskList=$FileSystem . ".txt";

#
# OUTPUT
#
# Output file containing the files found in the list provided by the experiment
$FilesOK=$FileSystem . ".ok";

# Output file containing the files not found in the list provided by the experiment
# and created before ListCreationDate. Likely orphan files
$FilesOrphan=$FileSystem . ".orphan";

# Output file containing the files not found in the list provided by the experiment 
# but created after ListCreationDate. 
$FilesNew=$FileSystem . ".new";

#
# BEGIN
# 
open (FILEOK, ">$FilesOK");
open (FILEORPH, ">$FilesOrphan");
open (FILENEW, ">$FilesNew");

open (EXISTINGFILE, $FilesOnDiskList) || die "Cannot open '$ARGV[0]': $!,";

$TotalSize=0;

while (<EXISTINGFILE>) {
    chomp;
#    print "\n$_";
    @filefield=split(/\s+/);
    # Filename is the 8th field    
    $filename=$filefield[8];

    # Date are fields number 5,6,7
    $filemonth=$filefield[5];
    $fileday=$filefield[6];
    $fileyearhour=$filefield[7];

    # Converting filename format
    # e.g.  %data%disk1%xrdnamespace%00%00000%2afc3ff8-cec2-11e0-80cd-001cc45cb5dc --> 
    # root://t2-xrdrd.lnl.infn.it:1094//00/00000/2afc3ff8-cec2-11e0-80cd-001cc45cb5dc
    @fields=split(/\%/,$filename); 
    $convertedfilename="root://t2-xrdrd.lnl.infn.it:1094//" . $fields[-3] . "/" . $fields[-2] . "/" . $fields[-1];

    # Convert in lowercase, for the check with the file provided by the experiment (which is in lowercase)
    $convertedfilename=lc($convertedfilename);
#    print "\n$convertedfilename";
    # Find the string in the files provided by experiment
    # Since this file is very big and since this is sorted, using the alphabetic function which should
    # give better performance
    open BIG, $AliceFiles or die "Cannot open $AliceFiles: $!,";
    $tell = alphabetic( *BIG, $convertedfilename );
    $line = <BIG>;
    # $line is the string in the file provided by the experiment >= to the searched one
    chomp ($line);
    @ff=split(/,/, $line);
#    print "\n--$ff[0]";
    # Entries are separated by ",". The filename is the first entry
    if ($ff[0] ne $convertedfilename) {

    # File not found. Let's check its date
    my $str = "$filemonth $fileday $fileyearhour";
    my $epoch = str2time($str);
    my $DateOfFile = DateTime->from_epoch(epoch => $epoch);
    # Compare the date file with the one when the experiment built the list
    $cmp = DateTime->compare($ListCreationDate, $DateOfFile);
    if ($cmp == 1)
    {
     # The file is old. Likely an orphan
     print FILEORPH "$FileSystem,$filename,$filemonth $fileday $fileyearhour,$filefield[4]\n";
     # Update the totalsize of orphan files
     $TotalSize = $TotalSize + $filefield[4];
    }
    else {
          # The file was created after the date when the experiment built the list
	  print FILENEW "$FileSystem,$filename,$filemonth $fileday $fileyearhour,$filefield[4]\n";
    }
}
else {
      # The file was found
      print FILEOK "$FileSystem,$filename\n"; 
}
    close BIG;
}

close EXISTINGFILE;
close FILEOK;
close FILENEW;
close FILEORPH;

print "\nTotalSize: $TotalSize\n";
