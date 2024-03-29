use strict;
use warnings;

use Test::More;

use Amazon::Sites;

my $assoc_codes = {
  UK => 'My Associate Code',
};

my $sites = Amazon::Sites->new(assoc_codes => $assoc_codes);

my $az_uk = $sites->site('UK');
is($az_uk->assoc_code, 'My Associate Code', 'Correct associate code for UK');

my $az_us = $sites->site('US');
is($az_us->assoc_code, '', 'No associate code for US');

done_testing;
