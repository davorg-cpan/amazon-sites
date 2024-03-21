package Amazon::Sites;

=head1 NAME

Amazon::Sites - A class to represent Amazon sites

=head1 SYNOPSIS

  use Amazon::Sites;

  my $sites = Amazon::Sites->new;
  my @sites = $sites->sites;
  my %sites = $sites->sites_hash;
  my @codes = $sites->codes;

  my $site  = $sites->site('UK');
  say $site->currency; # GBP
  say $site->tldr;     # co.uk
  # etc

=head1 DESCRIPTION

A simple class that encapsulates information about Amazon sites.

=cut

use Feature::Compat::Class;

use feature 'signatures';
no warnings 'experimental::signatures';

our $VERSION = '0.0.2';

class Amazon::Sites {
  use Amazon::Site;

  field %sites = _init_sites();

=head1 METHODS

=head2 new

Creates a new Amazon::Sites object.

=head2 sites_hash

Returns a hash where the keys are the two-letter country codes and the values are
L<Amazon::Site> objects.

=cut

  method sites_hash { return %sites }

=head2 site($code)

Given a two-letter country code, returns the corresponding L<Amazon::Site> object.

=cut

  method site ($code) { return $sites{$code} }

=head2 sites

Returns a list of L<Amazon::Site> objects, sorted by the sort order.

=cut

  method sites {
    my @sites = sort {
      $sites{$a}->sort <=> $sites{$b}->sort;
    } keys %sites;

    return \@sites;
  }

  sub _init_sites {
    my %sites;
    my @cols = qw[code country tldn currency sort];

    while (<main::DATA>) {
      chomp;
      my %site;
      @site{@cols} = split;
      $sites{$site{code}} = Amazon::Site->new(%site);
    }

    return %sites;
  }

=head2 codes

Returns a list of the two-letter country codes, sorted by the sort order.

=cut

  method codes {
    return sort keys %sites;
  } 
}

1;

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
