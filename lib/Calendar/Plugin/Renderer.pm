package Calendar::Plugin::Renderer;

$Calendar::Plugin::Renderer::VERSION = '0.01';

=head1 NAME

Calendar::Plugin::Renderer - Interface to render calendar.

=head1 VERSION

Version 0.01

=cut

use 5.006;
use Data::Dumper;

use Calendar::Plugin::Renderer::SVG;
use Calendar::Plugin::Renderer::SVG::Box;
use Calendar::Plugin::Renderer::SVG::Page;
use Calendar::Plugin::Renderer::SVG::Text;
use Calendar::Plugin::Renderer::SVG::Label;

use Moo::Role;
use namespace::clean;

my $HEIGHT                   = 0.5;
my $MARGIN_RATIO             = 0.04;
my $DAY_COLS                 = 8;
my $ROUNDING_FACTOR          = 0.5;
my $TEXT_OFFSET_Y            = 0.1;
my $TEXT_OFFSET_X            = 0.15;
my $TEXT_WIDTH_RATIO         = 0.1;
my $TEXT_HEIGHT_RATIO        = 0.145;
my $HEADING_WIDTH_SCALE      = 0.8;
my $HEADING_HEIGHT_SCALE     = 0.45;
my $HEADING_DOW_WIDTH_SCALE  = 2;
my $HEADING_DOW_HEIGHT_SCALE = 0.4;
my $HEADING_WOY_WIDTH_SCALE  = 4;
my $HEADING_WOY_HEIGHT_SCALE = 0.9;
my $MAX_WEEK_ROW             = 5;

=head1 DESCRIPTION

Base class to render Calendar in SVG format.

=head1 SYNOPSIS

=head1 METHODS

=head2 as_svg(\%param)

Returns the requested calendar month in SVG format.

=cut

sub as_svg {
    my ($self, $params) = @_;

    my $adjust_height = $params->{adjust_height} || 0;
    my $start_index   = $params->{start_index};
    my $year          = $params->{year};
    my $month_name    = $params->{month_name};
    my $days          = $params->{days};

    my ($width,  $width_unit)  = (210 * 1.0, 'mm');
    my ($height, $height_unit) = (297 * 1.0, 'mm');

    my $page = Calendar::Plugin::Renderer::SVG::Page->new(
        {
            width       => $width,
            width_unit  => $width_unit,
            height      => $height,
            height_unit => $height_unit,
            x_margin    => $width  * $MARGIN_RATIO,
            y_margin    => $height * $MARGIN_RATIO,
        });

    my $rows = $MAX_WEEK_ROW + 1;
    my $t    = ($rows + $ROUNDING_FACTOR) * (0.5 + $HEIGHT);
    my $boundary_box = Calendar::Plugin::Renderer::SVG::Box->new(
        {
            'x'      => $page->x_margin,
            'y'      => ($page->height * (1 - $HEIGHT)) + $page->y_margin,
            'height' => (($page->height * $HEIGHT) - ($page->y_margin * 2)) - $t,
            'width'  => $page->width - ($page->x_margin * 2)
        });

    my $row_height        = $boundary_box->height / ($rows + $ROUNDING_FACTOR) * (0.5 + $HEIGHT);
    my $row_margin_height = $row_height / ($rows * 2);

    my $cols              = $DAY_COLS;
    my $col_width         = $boundary_box->width / ($cols + $ROUNDING_FACTOR);
    my $col_margin_width  = $col_width / ($cols * 2);

    my $month_label = Calendar::Plugin::Renderer::SVG::Label->new(
        {
            'x'     => $boundary_box->x + ($col_margin_width * 2) + 11,
            'y'     => $boundary_box->y - $page->y_margin/2,
            'style' => 'font-size: ' . ($row_height),
        });

    my $year_label = Calendar::Plugin::Renderer::SVG::Label->new(
       {
           'x'     => $boundary_box->x + $boundary_box->width,
           'y'     => $boundary_box->y - $page->y_margin/2,
           'style' => 'text-align: end; text-anchor: end; font-size: ' . $row_height,
       });

    my $count = 1;
    my $wdays = [];
    for my $day (qw/Sun Mon Tue Wed Thu Fri Sat/) {
        my $x = $boundary_box->x + $col_margin_width * (2 * $count + 1) + $col_width * ($count - 1) + $col_width / 2;
        my $y = $boundary_box->y + $row_margin_height;

        my $wday_text = Calendar::Plugin::Renderer::SVG::Text->new(
            {
                'value'     => $day,
                'x'         => $x + $col_width  / $HEADING_DOW_WIDTH_SCALE,
                'y'         => $y + $row_height * $HEADING_DOW_HEIGHT_SCALE,
                'length'    => $col_width * $HEADING_WIDTH_SCALE,
                'adjust'    => 'spacing',
                'font_size' => ($row_height * $HEADING_HEIGHT_SCALE)
            });

        push @$wdays, Calendar::Plugin::Renderer::SVG::Box->new(
            {
                'x'      => $x,
                'y'      => $y,
                'height' => $row_height * $HEIGHT,
                'width'  => $col_width,
                'text'   => $wday_text
            });

        $count++;
    }

    my $days_box = [];
    foreach my $i (2 .. $rows) {
        my $row_y = $boundary_box->y + $row_margin_height * (2 * $i - 1) + $row_height * ($i - 1);
        for my $j (2 .. $cols) {
            my $x = ($boundary_box->x + $col_margin_width * (2 * $j - 1) + $col_width * ($j - 1)) - $col_width / 2;
            my $y = $row_y - $row_height / 2;

        my $day_text = Calendar::Plugin::Renderer::SVG::Text->new(
            {
                'x'         => $x + $col_margin_width * $TEXT_OFFSET_X,
                'y'         => $y + $row_height * $TEXT_OFFSET_X,
                'length'    => $col_width * $TEXT_WIDTH_RATIO,
                'font_size' => (($row_height * $TEXT_HEIGHT_RATIO) + 5),
            });

        $days_box->[$i - 1][$j - 1] = Calendar::Plugin::Renderer::SVG::Box->new(
            {
                'x'      => $x,
                'y'      => $y,
                'height' => $row_height,
                'width'  => $col_width,
                'text'   => $day_text
            });
        }
    }

    my $svg = Calendar::Plugin::Renderer::SVG->new(
        {
            days          => $days_box,
            month         => $month_label,
            year          => $year_label,
            wdays         => $wdays,
            page          => $page,
            boundary_box  => $boundary_box,
            adjust_height => $adjust_height,
        });

    $svg->process({
        start_index => $start_index,
        year        => $year,
        month_name  => $month_name,
        days        => $days });

    return $svg->as_string;
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/Manwar/Calendar-Plugin-Renderer>

=head1 BUGS

Please report any bugs / feature requests to C<bug-calendar-plugin-renderer at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Calendar-Plugin-Renderer>.
I will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Calendar::Plugin::Renderer

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

Copyright (C) 2015 Mohammad S Anwar.

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

1; # End of Calendar::Plugin::Renderer
