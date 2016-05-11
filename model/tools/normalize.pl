#if ($NORMALIZE) {
#    print STDERR "\nNormalization...\n";
#    # normalization
#    my $mean = 0;
#    my $variation = 0;
#    foreach my $feature (3 .. $#{$table[0]}) {
#        foreach my $instance (0 .. $#table) {
#            $mean += $table[$instance][$feature];
#        }
#        $mean /= ($#table + 1);
#        foreach my $instance (0 .. $#table) {
#            $variation += ($table[$instance][$feature] - $mean)**2;
#        }
#        $variation /= ($#table + 1);
#        foreach my $instance (0 .. $#table) {
#            $table[$instance][$feature] = ($table[$instance][$feature] - $mean) / $variation;
#        }
#    }
#}


#        }
