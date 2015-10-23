package Finance::Currency::Convert::BI;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::Any::IfLOG '$log';

use DateTime::Format::Indonesian;
use LWP::Simple;
use Parse::Number::ID qw(parse_number_id);

use Exporter qw(import);
our @EXPORT_OK = qw(get_jisdor_rates);

our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Get/convert currencies from website of Indonesian Central Bank (BI)',
};

$SPEC{get_jisdor_rates} = {
    v => 1.1,
    summary => 'Get JISDOR USD-IDR rates',
    description => <<'_',
_
    args => {
        from_date => {
            schema => 'date*',
            'x.perl.coerce_to' => 'epoch',
        },
        to_date => {
            schema => 'date*',
            'x.perl.coerce_to' => 'epoch',
        },
    },
};
sub get_jisdor_rates {
    my %args = @_;

    #return [543, "Test parse failure response"];

    my $page;
    if ($args{_page_content}) {
        $page = $args{_page_content};
    } else {
        $page = get "http://www.bi.go.id/id/moneter/informasi-kurs/referensi-jisdor/Default.aspx"
            or return [500, "Can't retrieve BI page"];
    }

    # XXX submit form if we want to set from_date & to_date

    my @res;
    {
        my ($table) = $page =~ m!<table class="table1">(.+?)</table>!s
            or return [543, "Can't extract data table (table1)"];
        while ($table =~ m!<tr>\s*<td>\s*(.+?)\s*</td>\s*<td>\s*(.+?)\s*</td>!gs) {
            my $date = eval { DateTime::Format::Indonesian->parse_datetime($1) };
            $@ and return [543, "Can't parse date '$1'"];
            my $rate = parse_number_id(text=>$2);
            push @res, {date=>$date->ymd, rate=>$rate};
        }
    }
    [200, "OK", \@res];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use Finance::Currency::Convert::BI qw(get_jisdor_rates);

 my $res = get_jisdor_rates();


=head1 DESCRIPTION

B<EARLY RELEASE>.


=head1 SEE ALSO

L<http://www.bi.go.id/>

=cut
