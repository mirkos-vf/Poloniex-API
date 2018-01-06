use 5.008008;
use strict;
use warnings;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Poloniex::API',
    VERSION_FROM => 'lib/Poloniex/API.pm',    # finds $VERSION
    LICENSE      => 'perl',
    (
        $] >= 5.005
        ?    ## Add these new keywords supported since 5.005
          (
            AUTHOR => 'vlad mirkos <mirkos.vf@gmail.com>'
          )
        : ()
    ),
    PREREQ_PM => {
        map { $_ => 0 }
          qw(JSON::XS Test::MockObject HTTP::Request Digest::SHA Test::Perl::Critic Test::Pod Test::PerlTidy),
    },
    META_MERGE => {
        test_requires => {
            'Test::More'         => 0,
            'Test::MockObject'   => 0,
            'Test::Perl::Critic' => 0,
            'Test::Pod'          => 0,
            'Test::PerlTidy'     => 0,
        },
        resources => {
            license    => 'http://dev.perl.org/licenses/',
            repository => 'https://github.com/mirkos-vf/Poloniex-API',
            bugtracker => 'https://github.com/mirkos-vf/Poloniex-API/issues'
        },
    },
);
