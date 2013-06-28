This is a perl script used to check which the files stored in a certain
file system of a xrootd server are correctly registered in the ALICE catalog
AND appears to be stored (also) in the Legnaro SE and which files are 
instead orphan.


INPUT
-----
The variable $AliceFiles links to a file, provided by the experiment, which contains
all the files which appear to be in SE in Legnaro.
The file is made of entries such as:

root://t2-xrdrd.lnl.infn.it:1094//00/00000/48feda3c-cb39-11e1-b8f4-00266cfd8b68,25688778,deeb10c2ec1e058e221077b3edd1f9a6

where:
- the first element is the file name
- the second element is the size (can be missing)
- the third element is the checksum (can be missing)

This file must be sorted and in lowercase. 

The variable $FileSystem represents the name of the filesystem to consider.
A file ${FileSystem}.txt has to exists, and it has to be the output of "ls -l" issued in 
the xrddata directory of this filesystem.

The variable $ListCreationDate is the date when the experiment produced the file list.

OUTPUT
------
The script produces three output files:
- ${FileSystem}.ok: contains the file in ${FileSystem}.txt which appears in
  the list provided by the experiment
- ${FileSystem}.new: contains the file in ${FileSystem}.txt which don't appear in
  the list provided by the experiment but have been created after the date when this
  list was produced
- ${FileSystem}.orphan: contains the file in ${FileSystem}.txt which don't appear in
  the list provided by the experiment and have been created before the date when this
  list was produced. These files are likely orphan files

The .orphan and .new files have entries in the following format:

<filename>,<date>,<size>


It also prints in stdout the overall size of found orphan files

 
