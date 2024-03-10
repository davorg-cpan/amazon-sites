use Feature::Compat::Class;

class Amazon::Sites {
  use Amazon::Site;

  field %sites = _init_sites();

  method sites_hash { return %sites }
  method site($code) { return $sites{$code} }

  method sites {
    my @sites = sort {
      $sites{$a}->sort <=> $sites{$b}->sort;
    } keys %sites;

    return \@sites;
  }

  sub _init_sites {
    my %sites;
    my @cols = qw[code country domain currency sort];

    while (<main::DATA>) {
      chomp;
      my %site;
      @site{@cols} = split;
      $sites{$site{code}} = Amazon::Site->new(%site);
    }

    return %sites;
  }
}

__DATA__
AU Australia com.au AUD 1
BR Brazil com.br BRL 2
CA Canada ca CAD 3
DE Germany de EUR 4
ES Spain es EUR 5
FR France fr EUR 6
IN India in INR 7
IT Italy it EUR 8
JP Japan co.jp BRL 9
MX Mexico com.mx MXN 10
NL Netherlands nl EUR 11
UK UK co.uk GBP 12
US USA com USD 13
