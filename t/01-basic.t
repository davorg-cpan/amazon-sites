use Test::More;

use Amazon::Sites;

ok(my $sites = Amazon::Sites->new, 'Got an object');
isa_ok($sites, 'Amazon::Sites');

ok(my @sites = $sites->sites);
ok(my %sites = $sites->sites_hash, 'sites_hash() gives a hash');
is(ref $sites{UK}, 'Amazon::Site');
is($sites{UK}->domain, 'co.uk');
ok(my $site  = $sites->site('UK'), 'site() gives a hash ref');
is($site->domain, 'co.uk');

my @codes = $sites->codes;
is_deeply(\@codes, [qw(AU BR CA DE ES FR IN IT JP MX NL UK US)]);

done_testing;
