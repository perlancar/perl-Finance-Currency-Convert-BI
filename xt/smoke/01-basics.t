#!perl

use 5.010;
use strict;
use warnings;

use Perinci::Import 'Finance::Currency::Convert::BI',
    get_jisdor_rates => {exit_on_error=>1};
use Test::More 0.98;

my $res = get_jisdor_rates();
is($res->[0], 200, "get_jisdor_rates() succeeds")
    or diag explain $res;

done_testing;
