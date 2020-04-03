#!/usr/bin/perl
use strict;
use warnings;

my $filename = $ARGV[0];
open(my $fh, $filename)
    or die "Could not open file '$filename' $!";

my $startTime;
my $endTime;
my $subject;
my $group;
my $flag1, my $flag2, my $flag3 = 0;
my %answer;
my $all_time = 0;

my $wynik = "wynik.csv";
open(DES, '>', $wynik) or die $!;
print DES "przedmiot,forma_zajec,typ_studiow,liczba_godzin\n";

while(my $line = <$fh>){
    if($line =~ m/DTSTART;.*T(\d{4})/){
	$flag1 = 1;
	$startTime = $1;
    }
    if($line =~ m/DTEND;.*T(\d{4})/){
	$flag2 = 1;
	$endTime = $1;
    }
    if($line =~ m/SUMMARY:(.*) - .*Grupa: (.*),.*\n/){
	$flag3 = 1;
	$subject = $1;
	$group = $2;
    }
    if($flag1 && $flag2 && $flag3){
	$flag1 = 0;
	$flag2 = 0;
	$flag3 = 0;
	my $hours = (int(substr($endTime,0,2)) - int(substr($startTime,0,2)))*60;
	my $minutes = int(substr($endTime,2,2)) - int(substr($startTime,2,2));
	my $tt = $hours + $minutes;

	while($tt % 45 != 0){
	    $tt-=5;
	}
	$all_time += $tt;
	
	my $itype = ""; # S1, S2, N1 or N2
	my $iform = ""; # lab or lecture
	
	if($group =~ m/^.*(L|W)_?.*$/){ # looking for form
	    $iform = $1;
	}else{
	    $iform = "UNKNOWN";
	}

	if($group =~ m/^.*_?(S1|S2|N1|N2)_.*$/){ # looking for type
	    $itype = $1;
	}else{
	    $itype = "UNKNOWN";
	}
	
	my $sub_form_type = $subject . " " . $iform . " " . $itype;
	if(!exists($answer{$sub_form_type})){
	    $answer{$sub_form_type} = $tt;
	}else{
	    $answer{$sub_form_type} += $tt;
	}
	my $tth = $tt/45;
	print DES "\"$subject\",\"$iform\",\"$itype\",\"$tth\"\n";
    }
}
close $fh;
close (DES);

my $lesson_hour = ($all_time)/45;
printf "All hours: %.1f\n\n", $lesson_hour;

foreach my $name (sort keys %answer){
    my $h = $answer{$name}/45;
    printf "$name %.1f\n", $h;
}

