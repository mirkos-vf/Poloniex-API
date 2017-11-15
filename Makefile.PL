use 5.008008;
use strict;
use warnings;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Poloniex::API',
    VERSION_FROM      => 'lib/Poloniex/API.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Poloniex/API.pm', # retrieve abstract from module
       AUTHOR         => 'vlad mirkos <vladmirkos@sd.apple.com>') : ()),
  PREREQ_PM     		=> {
    'Test::More' =>	0,
    'Test::Pod' =>	1.0,
    'Test::Perl::Critic' =>	0,
    'Test::PerlTidy' =>	0,
  },
  META_MERGE   => {
    requires  => { perl => 'v5.22' },
    resources => {
      license     => 'http://dev.perl.org/licenses/',
      repository  => 'https://github.com/mirkos-vf/Hash-Iterator',
      bugtracker  => 'https://github.com/mirkos-vf/Hash-Iterator/issues'
    },
  },
);
