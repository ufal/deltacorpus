#!/usr/bin/env perl
# Vybere nejdůvěryhodnější model pro každý jazyk Deltacorpusu.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

# Model "sla" použijeme pro slovanské a baltské jazyky.
@sla = ('bel', 'bos', 'bul', 'ces', 'hbs', 'hrv', 'hsb', 'mkd', 'pol', 'rus', 'slk', 'slv', 'srp', 'ukr', 'lav', 'lit');
# Model "ger" použijeme pro germánské jazyky a maďarštinu.
@ger = ('afr', 'dan', 'deu', 'eng', 'fao', 'fry', 'gsw', 'isl', 'lim', 'ltz', 'nds', 'nld', 'nno', 'nor', 'sco', 'swe', 'yid', 'hun');
# Model "rom" použijeme pro románské jazyky kromě rumunštiny (a latiny, která se ale považuje za jazyk italický).
@rom = ('arg', 'ast', 'cat', 'fra', 'glg', 'hat', 'ita', 'lmo', 'nap', 'pms', 'por', 'spa', 'vec', 'wln');
# Pro ostatní jazyky použijeme model "all".
@all = ('lat', 'ron', 'bre', 'cym', 'gla', 'gle', 'ell', 'hye', 'sqi', 'diq', 'fas', 'glk', 'kur', 'tgk', 'ben', 'bpy', 'guj', 'hif', 'hin', 'mar', 'nep', 'urd',
        'amh', 'ara', 'arz', 'heb', 'est', 'fin', 'eus', 'kat', 'chv', 'aze', 'tur', 'uzb', 'kaz', 'tat', 'sah', 'kor', 'mon', 'tel', 'kan', 'mal', 'tam',
        'new', 'vie', 'ind', 'jav', 'mlg', 'mri', 'msa', 'pam', 'sun', 'tgl', 'war', 'swa', 'epo', 'ido', 'ina', 'vol');
# Zkopírovat vybraný model pro každý jazyk.
$spath = '/net/work/people/zeman/deltacorpus/data/w2c';
$tpath = '/net/work/people/zeman/deltacorpus/data/release';
system("mkdir -p $tpath");
foreach my $l (@sla)
{
    my $command = "cp $spath/csla-$l.conll $tpath/$l.conll";
    print STDERR ("$command\n");
    system($command);
}
foreach my $l (@ger)
{
    my $command = "cp $spath/cger-$l.conll $tpath/$l.conll";
    print STDERR ("$command\n");
    system($command);
}
foreach my $l (@rom)
{
    my $command = "cp $spath/crom-$l.conll $tpath/$l.conll";
    print STDERR ("$command\n");
    system($command);
}
foreach my $l (@all)
{
    my $command = "cp $spath/all-$l.conll $tpath/$l.conll";
    print STDERR ("$command\n");
    system($command);
}
