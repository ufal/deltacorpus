#!/usr/bin/perl

use utf8;
binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

while(<>)
{
    if(m/^\s*$/)
    {
        my $sentence = join('', @sentence);
        unless($sentence[0] =~ m/^1\t(Richieste|mrač|Genus|violončelo|HOMEPAGE|Secunda|Parameter|Cvetlica|NOVINARI|Chris|Stonecrop|Pozdravljen|Split|Mesto|Obersorbisch|Chceli|DIOBRAL|Shrubby|Szkolenia|Fotoalbum|Categories|isaacvallina|Copyright|Local|Highlights|Westlife|Company|Zarząd|Wrocław|Welke|jajajaja|Jesteśmy|Glebogryzarka|Početna|Buttercup|Jenica|Options|Đà|GLAVNI|GLAVNA|OBRAL|Opprime|Abonneren|Uvez|PRODAJA|Górnołużycki|Angelina|Maszyna|Firewall)\t/ || $sentence =~ m/shqip|inowroclaw|áÅ|éÒ|èÍ|mp3|Erythroxylaceae|Čeleď|Balanophoraceae|KANADZIE|Bouffiera|Makoišće|intrygujących|Havlicek|pinnatisectus|Heartleaf|Kultūras|Grbašić|Õistaimed|Belišće|nudity|DonjaRupotina|CBSSportsline|pussssa|prostějov|Gyrostemonaceae|Postlister|Quercus|Albüm|napędem|hyödyntää|Magnoliophytis|Službeni|Herrera|prdsjdnk|gltčkg|kūno|UČITELJICIII|brezbarvna|distinguish|życia|żarowych|artificem|Starigrad|mogą|obvestila|Kalendarz|Ayarlanmış|ylläpisto|[İáéíúůý]|ceae/si)
        {
            print("$sentence\n");
        }
        splice(@sentence);
    }
    else
    {
        push(@sentence, $_);
    }
}