use warnings;
use strict;
use Test::More import => [qw( plan )];
eval "use Test::Pod::Coverage 1.00";
plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage" if $@;
all_pod_coverage_ok( { also_private => [qr[^(DOES|META)$]] } );
