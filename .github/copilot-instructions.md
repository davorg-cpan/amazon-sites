# Copilot Instructions for amazon-sites

## Project Overview

**Amazon::Sites** is a Perl CPAN module that provides an object-oriented interface to information about international Amazon sites. It allows users to retrieve details (country, domain, currency, etc.) for each Amazon site and generate product URLs (with optional affiliate/associate codes) for any ASIN across all or a filtered subset of sites.

- **Module name:** `Amazon::Sites` (container) and `Amazon::Site` (single site)
- **Current version:** defined by `our $VERSION` in `lib/Amazon/Sites.pm` (that file is the authoritative source)
- **Author:** Dave Cross <dave@perlhacks.com>
- **Minimum Perl version:** 5.26.0
- **License:** Perl (GPL v1+ or Artistic License v2.0)

---

## Directory Structure

```
amazon-sites/
├── .github/
│   ├── copilot-instructions.md     # This file
│   ├── dependabot.yml              # Weekly GitHub Actions dependency updates
│   └── workflows/
│       ├── perltest.yml            # Main CI: test, coverage, perlcritic, complexity
│       └── copilot-setup-steps.yml # Copilot environment setup (Perl 5.40 + deps)
├── lib/
│   └── Amazon/
│       ├── Sites.pm                # Main class: collection of Amazon sites
│       └── Site.pm                 # Single Amazon site representation
├── t/                              # Test suite (Test::More)
│   ├── 00-load.t                   # Module loading
│   ├── 01-basic.t                  # Core functionality
│   ├── 02-include-exclude.t        # Include/exclude filter logic
│   ├── 03-associates.t             # Associate/affiliate code support
│   ├── pod.t                       # POD syntax (skipped if Test::Pod absent)
│   └── pod_coverage.t              # POD coverage (skipped if Test::Pod::Coverage absent)
├── ChangeLog.md                    # Version history (Keep a Changelog format)
├── Makefile.PL                     # Build configuration (ExtUtils::MakeMaker)
├── MANIFEST                        # Files included in the CPAN distribution
├── MANIFEST.SKIP                   # Patterns excluded from CPAN distribution
└── README.md                       # Project documentation and usage examples
```

> **Note:** `Makefile`, `blib/`, `MYMETA.json`, and `MYMETA.yml` are **generated** by the build system and are listed in `.gitignore`. Do not commit them.

---

## Setting Up the Environment

The Copilot setup workflow installs Perl 5.40 and all dependencies automatically. To do this manually:

```bash
# Install all runtime and development dependencies (no tests for speed)
cpanm --installdeps --with-develop --notest .
```

### Key Runtime Dependency

| Package | Min Version | Purpose |
|---------|-------------|---------|
| `Feature::Compat::Class` | 0.07 | Provides the `class`/`method`/`field` keywords (modern Perl OOP) |
| `Object::Pad` | any | Fallback OOP support for Perl < 5.40 (any version accepted) |

### Key Test Dependencies

| Package | Purpose |
|---------|---------|
| `Test::More` | Standard Perl test framework |
| `Test::Exception` | Tests for thrown exceptions (`throws_ok`) |

---

## Building

This is a standard Perl module using **ExtUtils::MakeMaker**:

```bash
perl Makefile.PL   # Generate the Makefile
make               # Copy files to blib/ (build directory)
make test          # Run the test suite
make install       # Install to system Perl
```

---

## Running Tests

```bash
# Full test suite via make:
make test

# Or run individual test files directly:
perl -Ilib t/01-basic.t
perl -Ilib t/02-include-exclude.t
perl -Ilib t/03-associates.t
```

All tests across the four active test files (excluding optional pod tests) should pass. Expected output ends with:

```
Result: PASS
```

> **Note:** `pod.t` and `pod_coverage.t` are skipped if `Test::Pod` / `Test::Pod::Coverage` are not installed. This is expected and not an error.

---

## Linting / Static Analysis

Linting runs automatically in CI via `PerlToolsTeam` shared workflows. To run PerlCritic locally:

```bash
perlcritic lib/
```

The CI workflow also runs complexity analysis via `PerlToolsTeam/github_workflows/.github/workflows/cpan-complexity.yml`.

---

## CI/CD Workflow

The main workflow (`.github/workflows/perltest.yml`) runs on push/PR to `main` and has four jobs:

| Job | Tool | Purpose |
|-----|------|---------|
| `test` | `cpan-test.yml` | Runs tests on Perl 5.26, 5.28, 5.30, 5.32, 5.34, 5.36, 5.38 |
| `coverage` | `cpan-coverage.yml` | Reports code coverage to Coveralls.io |
| `perlcritic` | `cpan-perlcritic.yml` | Runs PerlCritic static analysis |
| `complexity` | `cpan-complexity.yml` | Checks code complexity |

All jobs use reusable workflows from `PerlToolsTeam/github_workflows@main`.

---

## Code Architecture and Conventions

### OOP Style

The code uses **modern Perl OOP** via `Feature::Compat::Class` (which backports the native `class` feature from Perl 5.40 to earlier versions). Key syntax:

```perl
use Feature::Compat::Class;
use feature 'signatures';
no warnings 'experimental::signatures';

class Amazon::Sites;

field $include :param = [];   # Constructor parameter with default
field %sites = _init_sites(…);

method sites { … }            # Instance method (has implicit $self)
sub _init_sites(…) { … }      # Private subroutine (not a method)
```

- `field` declares instance variables; `:param` means it can be set in the constructor
- `method` declares instance methods; `$self` is available implicitly
- Regular `sub` is used for private helper functions (not exposed as methods)
- `ADJUST { … }` runs after construction for validation

### Site Data

All 22 Amazon sites are stored as tab-separated data in the `__DATA__` section of `lib/Amazon/Sites.pm`:

```
AE	UAE	ae	AED	1
AU	Australia	com.au	AUD	2
...
UK	United Kingdom	co.uk	GBP	21
US	USA	com	USD	22
```

Columns: `code | country | tldn | currency | sort`

To **add a new Amazon site**, append a new tab-separated line to the `__DATA__` section in `lib/Amazon/Sites.pm`. Update tests in `t/01-basic.t` and `t/02-include-exclude.t` that check `codes()` output.

### URL Format

- Without associate code: `https://amazon.<tldn>/dp/<ASIN>`
- With associate code: `https://amazon.<tldn>/dp/<ASIN>?tag=<assoc_code>`

---

## Key API Summary

### `Amazon::Sites`

```perl
my $sites = Amazon::Sites->new(
    include      => ['UK', 'US'],    # optional: only include these
    exclude      => ['US'],          # optional: exclude these (mutually exclusive with include)
    assoc_codes  => { UK => 'tag' }, # optional: associate codes per site
);

$sites->sites;              # Returns sorted list of Amazon::Site objects
$sites->sites_hash;         # Returns hash: code => Amazon::Site
$sites->site('UK');         # Returns Amazon::Site for UK
$sites->codes;              # Returns sorted list of country codes
$sites->asin_urls('ASIN');  # Returns hash: code => URL for given ASIN
```

### `Amazon::Site`

```perl
$site->code;                # 'UK'
$site->country;             # 'United Kingdom'
$site->tldn;                # 'co.uk'
$site->domain;              # 'amazon.co.uk'
$site->currency;            # 'GBP'
$site->sort;                # Sort order integer
$site->assoc_code;          # Associate code string (empty if not set)
$site->asin_url('ASIN');    # Full product URL
```

---

## Documentation

Both source files use **POD** (Plain Old Documentation) inline. To view:

```bash
perldoc lib/Amazon/Sites.pm
perldoc lib/Amazon/Site.pm
```

Online documentation is published at [MetaCPAN](https://metacpan.org/pod/Amazon::Sites).

When adding new public methods, always add a corresponding POD section following the existing style (e.g., `=head2 method_name` followed by a description).

---

## Known Issues and Workarounds

- **`pod.t` and `pod_coverage.t` skip:** These tests require `Test::Pod` and `Test::Pod::Coverage` which are not installed by default. They are safely skipped with a message. This is expected behaviour, not a failure.
- **`experimental::signatures` warning:** The `no warnings 'experimental::signatures'` pragma is used to suppress warnings about the `signatures` feature, which is experimental in Perl < 5.37. This is intentional.
- **Makefile and build artifacts:** `Makefile`, `blib/`, `MYMETA.*`, and `pm_to_blib` are build artifacts. They are in `.gitignore`. If you accidentally generate them, do not commit them.
