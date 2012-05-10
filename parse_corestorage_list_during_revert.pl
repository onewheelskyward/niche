#!/usr/bin/perl

######
# This script is intended to run with the input produced from diskutil coreStorage list during a revert operation.
# For instance, I wrote a bash script that ran the check every 60 seconds, displaying progress:
# (it turns out 300 minutes was a bit shy of the mark.  It took 8 hours.)
#
# #!/bin/bash
#
# for i in {1..300}
# do
#     diskutil coreStorage list | grep 'Size ' | tail -2 | ./parse.pl
#     sleep 60
# done
#

$run = 1;
open (IN, "parse.dat");
while (<IN>)
{
    chomp;
    $last_left = $_;
}

close (IN);

while (<>)
{
    /\s+Size\s[^\d]+(\d+)/;
    if ($run == 1)
    {
	$total = $1;
	$run++;
    }
    else
    {
	$converted = $1;
    }
}

$percentage_complete = int(($converted / $total) * 10000) / 100;
$data_left = int((($total - $converted) / 1024 / 1024 / 1024) * 10) / 10;

open (OUT, "> parse.dat");
print OUT $data_left;
close (OUT);

$movement = int(($last_left - $data_left) * 100) / 100;

# 0.7 GB/m
$time_left = $data_left / $movement * 60; #number of seconds left
$finish_time = localtime($time_left + time);

$finish_time =~ / (\d{2}:\d{2}:\d{2}) /;
$finish_clock = $1;

print $percentage_complete . "%  $movement GB/m.  $data_left GB to go.  Estimated completion: $finish_clock\n";
