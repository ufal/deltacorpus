#!/usr/bin/env perl

use strict;
use warnings;

my $TNT_TAGGER_DIR = "/home/marecek/tectomt/share/external_tools/tnt_tagger/tnt/";

my ($TRAIN_FILE, $APPLY_FILE, $OUTPUT_FILE) = @ARGV;

system "cat $TRAIN_FILE | cut -f2,4 > corpus.tmp";
system "$TNT_TAGGER_DIR/tnt-para -o model.tmp corpus.tmp";
system "cat $APPLY_FILE | cut -f1,2,3 > corpus.tmp";
system "cat corpus.tmp | cut -f2 > forms.tmp";
system "$TNT_TAGGER_DIR/tnt -m model.tmp forms.tmp | tail -n +14 | perl -e 'while(<>){chomp; s/\\t+/\\t/g; print \"\$_\n\";}' | cut -f2 > tags.tmp";
system "paste corpus.tmp tags.tmp tags.tmp > $OUTPUT_FILE";
system "rm *.tmp";
