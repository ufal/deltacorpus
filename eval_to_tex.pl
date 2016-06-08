#!/usr/bin/env perl
# Reads accummulated output of eval.pl for all languages. Creates a LaTeX table of results.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

#bg/dev/all-bg.pred 14704 tokens, 8341 correctly tagged, A=57%
#bg/dev/bg-bg.pred 14704 tokens, 12780 correctly tagged, A=87%
#bg/dev/c7-bg.pred 14704 tokens, 7327 correctly tagged, A=50%
#bg/dev/cagl-bg.pred 14704 tokens, 6668 correctly tagged, A=45%
#bg/dev/cger-bg.pred 14704 tokens, 9006 correctly tagged, A=61%
#bg/dev/cine-bg.pred 14704 tokens, 8596 correctly tagged, A=58%
#bg/dev/crom-bg.pred 14704 tokens, 8221 correctly tagged, A=56%
#bg/dev/csla-bg.pred 14704 tokens, 9798 correctly tagged, A=67%

while(<>)
{
    m:^([^/]+)/dev/(.+?)-.+?\.pred.*A=(\d+)%:;
    my $target = $1;
    my $source = $2;
    my $accuracy = $3;
    $source = 'self' if($source eq $target);
    $h{$target}{$source} = $accuracy;
}
my @targets = sort(keys(%h));
my @sources = qw(self all cine cger crom csla cagl c7);
foreach my $target (@targets)
{
    printf("  $target & ?    & %4d & %3d & %3d & %3d & %3d & %3d & %4d & %2d \\\\\n", $h{$target}{self}, $h{$target}{all}, $h{$target}{cine}, $h{$target}{cger}, $h{$target}{crom}, $h{$target}{csla}, $h{$target}{cagl}, $h{$target}{c7});
}
