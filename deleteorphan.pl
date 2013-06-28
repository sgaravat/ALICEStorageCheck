#!/usr/bin/perl

#
# INPUT
#
# Files containing the list of files to be deleted
# Produced by findorphan.pl
$FilesToDelete="xrdpool-01-disk3.orphan";
#
# Name of the filesystem
$FileSystemName="/data/disk3";

#                                                                                                                                     
# OUTPUT
# Files containing if files were successfully deleted
$ReportFile=$FilesToDelete . ".report";

#
# BEGIN
#
print "\nBefore cleaning ...\n";
system("df $FileSystemName");
open (FILESTODELETE, $FilesToDelete) || die "Cannot open $FilesToDelete: $!,";

open (REPORT, ">$ReportFile");

while (<FILESTODELETE>) {
    chomp;
#   print "\n$_";
    #
    # Each entry is composed by elements separated by ","
    # Filename is the second element
    @ff=split(/,/); 
    $fullpath= $FileSystemName . "/xrddata/" . $ff[1];
    if (unlink($fullpath) == 0) {
	print REPORT "File $fullpath deleted successfully.\n";
    } else {
	print REPORT "File $fullpath was not deleted.\n";
    }
}
close FILESTODELETE;
close REPORT;
print "\nAfter cleaning ...\n";
system("df $FileSystemName");
