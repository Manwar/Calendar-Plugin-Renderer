package Calendar::Plugin::Renderer::Util;

$Calendar::Plugin::Renderer::Util::VERSION   = '0.16';
$Calendar::Plugin::Renderer::Util::AUTHORITY = 'cpan:MANWAR';

=head1 NAME

Calendar::Plugin::Renderer::Util - Helper package for Calendar::Plugin::Renderer.

=head1 VERSION

Version 0.16

=cut

use parent 'Exporter';
our @EXPORT = qw(round_number get_max_week_rows);

use 5.006;
use strict; use warnings;
use Data::Dumper;

=head1 DESCRIPTION

B<FOR INTERNAL USE ONLY>.

=head2 METHODS

=head1 round_number($number, $digits)

Round the given C<$number> by C<$digits>. By default round it by 4 digits.

=cut

sub round_number {
    my ($number, $digits) = @_;

    $digits    = 4 unless defined $digits;
    my $format = sprintf("%02d", $digits);
    $format    = '%.' . $format . 'f';

    return sprintf($format, $number);
}

sub get_max_week_rows {
    my ($start_index, $max_days, $max_week_row) = @_;

    my $rows = 1;
    my $i    = 1;
    while ($i < $start_index) {
        $i++;
    }

    my $d = 1;
    while ($i <= 7) {
        $d++;
        $i++;
    }

    $rows++;
    my $k = 1;
    while ($d <= $max_days) {
        if ($k == 7) {
            $rows++;
            $k = 1;
        }
        else {
            $k++;
        }
        $d++;
    }

    if ($rows < $max_week_row) {
        return $max_week_row;
    }
    else {
        return $rows;
    }
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/manwar/Calendar-Plugin-Renderer>

=head1 BUGS

Please report any bugs / feature requests to C<bug-calendar-plugin-renderer at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Calendar-Plugin-Renderer>.
I will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Calendar::Plugin::Renderer::Util

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Calendar-Plugin-Renderer>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Calendar-Plugin-Renderer>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Calendar-Plugin-Renderer>

=item * Search CPAN

L<http://search.cpan.org/dist/Calendar-Plugin-Renderer/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015 - 2016 Mohammad S Anwar.

This program  is  free software; you can redistribute it and / or modify it under
the  terms  of the the Artistic License (2.0). You may obtain a  copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of Calendar::Plugin::Renderer::Util
