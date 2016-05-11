#!/usr/bin/perl

use strict;
use warnings;

my @LANGUAGE  = qw(ar  bg  bn  ca  cs  da  de  el  en  es  et  eu  fa  fi  hi  hu  it  ja  la  nl  pt  ro  ru  sk  sl  sv  ta  te  tr);
my @LANG_LONG = qw(ara bul ben cat ces dan deu ell eng spa est eus fas fin hin hun ita jpn lat nld por ron rus slk slv swe tam tel tur);

foreach my $i (0 .. $#LANGUAGE) {
    system "zcat /net/data/hamledt/$LANGUAGE[$i]/stanford/test/*.conll.gz | head -1000 > data/test-conll-1k/$LANGUAGE[$i].conll";
    system "zcat /net/data/W2C/W2C_WEB/2011-08/$LANG_LONG[$i].txt.gz | head -1000000 > data/w2c-1Mlines/$LANGUAGE[$i].txt";
    system "echo \"./get_statistics.pl data/test-conll-1k/$LANGUAGE[$i].conll data/w2c-1Mlines/$LANGUAGE[$i].txt 0> data/test9-norm/$LANGUAGE[$i].test.small.data 2> $LANGUAGE[$i].norm.err\" > $LANGUAGE[$i]-run.sh";
    system "qsub -hard -l mf=30g -l act_mem_free=30g -cwd -o /dev/null -e /dev/null $LANGUAGE[$i]-run.sh";
}

