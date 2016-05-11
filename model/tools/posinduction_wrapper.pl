#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Getopt::Long;
use Encode;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my $POSINDUCTION_DIR = "/home/marecek/dissertation/tools/posinduction/";
my $CLUSTERS = 64;
my $TMPDIR = '.';

GetOptions(
    "clusters|c=i" => \$CLUSTERS,
    "tmpdir|t=s"   => \$TMPDIR,
);

my %orig2ascii;

my %convertable;
foreach my $ord ( 33 .. 126 ) {
    my $char = decode( 'US-ASCII', chr($ord) );
    $convertable{$char} = 1;
}

sub convert_to_ascii {
    my $word = shift;
    my $ascii = "";
    foreach my $ch (split(//, $word)) {
        # basic latin
        $ch =~ tr/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ/;
        # diacritic latin
        $ch =~ tr/ÁáÉéĚěÍíÓóÚúůÝýČčĎďŇňŘřŠšŤťŽžäëïöüÿÄËÏÖÜŸùè/aaeeeeiioouuuyyccddnnrrssttzzaeiouyaeiouyue/;
        # greek
        $ch =~ tr/ΑαΒβΓγΔδΕεΖζΗηΘθΙιΚκΛλΜμΝνΞξΟοΠπΡρΣσΤτΥυΦφΧχΨψΩω/AABBGGDDEEZZHHQQIIKKLLMMNNUUOOPPRRSSTTYYFFXXWWCC/;
        # cyrilic
        $ch =~ tr/АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюя/ABVGDezZIJKLMNOPRSTUFXCcsQWYHEuaABVGDezZIJKLMNOPRSTUFXCcsQWYHEua/;
        # special characters
        $ch =~ tr/–“”»«¦/-""<>|/;
        $ascii .= $convertable{$ch} ? $ch : '^';
    }
    return $ascii;
}

# create temporary directory for input and output files
my $tempdir = $TMPDIR;
system "mkdir -p $tempdir";
print STDERR "Tempdir $tempdir created.\n";

open (INPUT, ">:encoding(US-ASCII)", "$tempdir/input") or die;

my @corpus;

while(<STDIN>){
    chomp;
    if (/^\d/) {
        my ($ord, $form) = split /\t/;
        push @corpus, $form;
        if (!$orig2ascii{$form}) {
            $orig2ascii{$form} = convert_to_ascii($form);
        }
        print INPUT "$orig2ascii{$form}\n";
    }
    else {
        push @corpus, "";
        print INPUT "\n";
    }
}
close INPUT;

system "$POSINDUCTION_DIR/cluster_neyessenmorph -s 5 -m 5 -i 10 $tempdir/input $tempdir/input $CLUSTERS > $tempdir/output 2> $tempdir/error";

my %cluster;

open (OUTPUT, "<:encoding(US-ASCII)", "$tempdir/output") or die;
while(<OUTPUT>) {
    chomp;
    my ($form, $cluster) = split /\s/;
    $cluster{$form} = $cluster;
}
close OUTPUT;

foreach my $orig (keys %orig2ascii) {
    print "$orig\t$cluster{$orig2ascii{$orig}}\n";
}

#my $ord = 1;
#foreach my $word (@corpus) {
#    if (!$word) {
#        print "\n";
#        my $ord = 1;
#    }
#    else {
#        print "$ord\t$word\t_\t$cluster{$orig2ascii{$word}}\t_\t_\t0\t_\n";
#        $ord++;
#    }
#}

#system "rm -r $tempdir";








