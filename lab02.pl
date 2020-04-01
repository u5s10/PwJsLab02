#!/usr/bin/perl
use strict;
use warnings;

my $filename = $ARGV[0];
open(my $fh, $filename)
    or die "Could not open file '$filename' $!";

my @startTime;
my @endTime;
my @subject;
my @group;

while(my $line = <$fh>){
    if($line =~ m/DTSTART;.*T(\d{4})/){
	push(@startTime, $1);
    }
    if($line =~ m/DTEND;.*T(\d{4})/){
	push(@endTime, $1);
    }
    if($line =~ m/SUMMARY:(.*) - .*Grupa: (.*),.*\n/){
	push(@subject, $1);
	push(@group, $2);
    }
}
close $fh;

my %answer;
my $all_hours = 0;
my $all_minutes = 0;
for (my $var = 0; $var < @startTime; $var++) {
    $all_hours += (int(substr($endTime[$var],0,2)) - int(substr($startTime[$var],0,2)))*60;
    $all_minutes += int(substr($endTime[$var],2,2)) - int(substr($startTime[$var],2,2));
    
    my $hours = (int(substr($endTime[$var],0,2)) - int(substr($startTime[$var],0,2)))*60;
    my $minutes = int(substr($endTime[$var],2,2)) - int(substr($startTime[$var],2,2));
    my $itype = ""; # S1, S2, N1 or N2
    my $iform = ""; # lab or lecture
    
    if($group[$var] =~ m/^.*(L|W)_?.*$/){ # looking for form
	$iform = $1;
    }else{
	$iform = "UNKNOWN";
    }

    if($group[$var] =~ m/^.*_?(S1|S2|N1|N2)_.*$/){ # looking for type
	$itype = $1;
    }else{
	$itype = "UNKNOWN";
    }
    
    my $sub_form_type = $subject[$var] . " " . $iform . " " . $itype;
    
    if(!exists($answer{$sub_form_type})){
	$answer{$sub_form_type} = ($hours + $minutes);
    }else{
	$answer{$sub_form_type} += ($hours + $minutes);
    }
}

my $lesson_hour = ($all_hours + $all_minutes)/45;
printf "lessons hours: %.2f\n", $lesson_hour;

foreach my $name (sort keys %answer){
    my $h = $answer{$name}/45;
    printf "$name %.2f\n", $h;

}

