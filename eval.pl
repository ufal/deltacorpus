#!/usr/bin/env perl
# Evaluates Zhiwei's delexicalized tagging.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

# /home/zhiwai/pos/model/svm/predictlabel, for example c7_cs_20000000_20000000.txt
while(<>)
{
    s/\r?\n//;
    # Skip empty lines.
    next if(m/^\s*$/);
    # Skip the heading of the OOV section.
    next if(m/^out of vocabulary word prediction$/);
    # Expected three tab-separated fields: word form, gold tag, predicted tag.
    my @fields = split(/\s+/, $_);
    my $form = $fields[0];
    my $gtag = $fields[1];
    my $ptag = $fields[2];
    if($ptag eq $gtag)
    {
        $nok++;
        $gnok{$gtag}++;
        $pnok{$ptag}++;
    }
    else
    {
        my $error = "$gtag-$ptag";
        $gpn{$error}++;
        $gpex{$error}{$form}++;
    }
    $n++;
    $gn{$gtag}++;
    $pn{$ptag}++;
    $gex{$gtag}{$form}++;
    $pex{$ptag}{$form}++;
    # Is it at all possible to tag a word differently in different contexts?
    if(exists($pdict{$form}) && $pdict{$form} ne $ptag)
    {
        print("Ambiguous prediction of '$form': previously $pdict{$form}, now $ptag.\n");
    }
    $pdict{$form} = $ptag;
}
$n = 1 if($n==0);
printf("$n tokens, $nok correctly tagged, A=%d%%\n", $nok/$n*100+0.5);
print("Per-tag precision and recall:\n");
foreach my $tag (sort(keys(%gn)))
{
    # Most frequent examples whose gold tag is the current one.
    my @ex = sort {my $r = $gex{$tag}{$b} <=> $gex{$tag}{$a}} (keys(%{$gex{$tag}}));
    my $gex = join(', ', @ex[0..4]);
    # Most frequent examples whose predicted tag is the current one.
    @ex = sort {my $r = $pex{$tag}{$b} <=> $pex{$tag}{$a}} (keys(%{$pex{$tag}}));
    my $pex = join(', ', @ex[0..4]);
    my $denom = $pn{$tag};
    $denom = 1 if($denom==0);
    my $p = $pnok{$tag}/$denom;
    printf("\t%s\t%d\t%d\tP=%d%%\t\tPRED: $pex\n", $tag, $pn{$tag}, $pnok{$tag}, $p*100+0.5);
    $denom = $gn{$tag};
    $denom = 1 if($denom==0);
    my $r = $gnok{$tag}/$denom;
    $denom = $p+$r;
    $denom = 1 if($denom==0);
    my $f = 2*$p*$r/$denom;
    printf("\t%s\t%d\t%d\tR=%d%%\tF=%d\tGOLD: $gex\n", $tag, $gn{$tag}, $gnok{$tag}, $r*100+0.5, $f*100+0.5);
}
print("Most frequent errors (GOLD-PREDICTED):\n");
#my @errors = sort {$gpn{$b} <=> $gpn{$a}} (keys(%gpn));
my @errors = sort(keys(%gpn));
my $maxerrors = 144;
for(my $i = 0; $i <= $#errors && $i < $maxerrors; $i++)
{
    my $error = $errors[$i];
    my @ex = sort {my $r = $gpex{$error}{$b} <=> $gpex{$error}{$a}} (keys(%{$gpex{$error}}));
    my $gpex = join(', ', @ex[0..4]);
    printf("\t%s\t%d\t%s\n", $error, $gpn{$error}, $gpex);
}
