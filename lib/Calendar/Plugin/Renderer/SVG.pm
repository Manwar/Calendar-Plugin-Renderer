package Calendar::Plugin::Renderer::SVG;

$Calendar::Plugin::Renderer::SVG::VERSION   = '0.03';
$Calendar::Plugin::Renderer::SVG::AUTHORITY = 'cpan:MANWAR';

=head1 NAME

Calendar::Plugin::Renderer::SVG - Interface to render calendar in SVG format.

=head1 VERSION

Version 0.03

=cut

use 5.006;
use Data::Dumper;

use SVG;
use Moo;
use namespace::clean;

has 'days'          => (is => 'rw', required => 1);
has 'month'         => (is => 'rw', required => 1);
has 'year'          => (is => 'rw', required => 1);
has 'wdays'         => (is => 'rw', required => 1);
has 'page'          => (is => 'rw', required => 1);
has 'boundary_box'  => (is => 'rw', required => 1);
has 'adjust_height' => (is => 'ro', default => sub { 0 });
has '_row'          => (is => 'rw');

=head1 DESCRIPTION

B<FOR INTERNAL USE ONLY>

=cut

sub process {
    my ($self, $params) = @_;

    $self->year->text($params->{year});
    $self->month->text($params->{month_name});

    my $start_index    = $params->{start_index};
    my $max_month_days = $params->{days};

    my $row = 1;
    my $i   = 1;
    while ($i < $start_index) {
        $self->days->[$row][$i]->text->value(' ');
        $i++;
    }

    my $d = 1;
    while ($i <= 7) {
        $self->days->[$row][$i]->text->value($d);
        $i++;
        $d++;
    }

    $row++;
    my $k = 1;
    while ($d <= $max_month_days) {
        $self->days->[$row][$k]->text->value($d);
        if ($k == 7) {
            $row++;
            $k = 1;
        }
        else {
            $k++;
        }
        $d++;
    }

    $self->_row($row);
}

sub as_string {
    my ($self) = @_;

    my $p_height = sprintf("%d%s", $self->page->height, $self->page->height_unit);
    my $p_width  = sprintf("%d%s", $self->page->width,  $self->page->width_unit);
    my $view_box = sprintf("0 0 %d %d", $self->page->width, $self->page->height);

    my $svg = SVG->new(
        height   => $p_height,
        width    => $p_width,
        viewBox  => $view_box,
        -svg_version => '1.1',
        -pubid       => '-//W3C//DTD SVG 1.1//EN',
        -sysid       => 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd');
    my $calendar = $svg->group(id => 'calendar', label => "Calendar");

    $calendar->text('id'    => "month",
                    'fill'  => 'blue',
                    'x'     => $self->month->x,
                    'y'     => $self->month->y,
                    'style' => $self->month->style)->cdata($self->month->text);

    $calendar->text('id'    => "year",
                    'fill'  => 'blue',
                    'x'     => $self->year->x,
                    'y'     => $self->year->y,
                    'style' => $self->year->style)->cdata($self->year->text);

    $calendar->rect('id'     => 'bounding_box',
                    'height' => $self->boundary_box->height - $self->adjust_height,
                    'width'  => $self->boundary_box->width - 14,
                    'x'      => $self->boundary_box->x + 7 + 7,
                    'y'      => $self->boundary_box->y,
                    'style'  => 'fill:none; stroke: blue; stroke-width: 0.5;');

    foreach (0..6) {
        my $day = $calendar->tag('g',
                                 'id'           => "row0_col$_",
                                 'text-anchor'  => 'middle',
                                 'fill'         => 'none',
                                 'stroke'       => 'blue',
                                 'stroke-width' => '0.5');
        next unless defined $self->wdays->[$_];

        $day->rect('id'     => "box_row0_col$_",
                   'x'      => $self->wdays->[$_]->x,
                   'y'      => $self->wdays->[$_]->y,
                   'height' => $self->wdays->[$_]->height,
                   'width'  => $self->wdays->[$_]->width);
        $day->text('id'          => "text_row0_col$_",
                   'x'           => $self->wdays->[$_]->text->x,
                   'y'           => $self->wdays->[$_]->text->y,
                   'length'      => $self->wdays->[$_]->text->length,
                   'adjust'      => $self->wdays->[$_]->text->adjust,
                   'font-size'   => $self->wdays->[$_]->text->font_size,
                   'text-anchor' => 'middle',
                   'stroke'      => 'red')
            ->cdata($self->wdays->[$_]->text->value);
    }

    my $row = $self->_row;
    foreach my $r (1..$row) {
        foreach my $c (1..7) {
            my $g_id = sprintf("row%d_col%d"     , $r, $c);
            my $r_id = sprintf("box_row%d_col%d" , $r, $c);
            my $t_id = sprintf("text_row%d_col%d", $r, $c);
            next unless defined $self->days->[$r]->[$c];

            my $d = $calendar->tag('g',
                                   'id'           => "$g_id",
                                   'fill'         => 'none',
                                   'stroke'       => 'blue',
                                   'stroke-width' => '0.5');
            $d->rect('id'     => "$r_id",
                     'x'      => $self->days->[$r]->[$c]->x,
                     'y'      => $self->days->[$r]->[$c]->y,
                     'height' => $self->days->[$r]->[$c]->height,
                     'width'  => $self->days->[$r]->[$c]->width,
                     'fill'         => 'none',
                     'stroke'       => 'blue',
                     'stroke-width' => '0.5');

            my $text = ' ';
            if (defined $self->days->[$r]->[$c]->text
                && defined $self->days->[$r]->[$c]->text->value) {
                $text = $self->days->[$r]->[$c]->text->value;
            }

            $d->text('id'     => "$t_id",
                     'x'      => $self->days->[$r]->[$c]->text->x + 1,
                     'y'      => $self->days->[$r]->[$c]->text->y + 5,
                     'length' => $self->days->[$r]->[$c]->text->length,
                     'adjust' => 'spacing',
                     'font-size'    => $self->days->[$r]->[$c]->text->font_size,
                     'stroke'       => 'green',
                     'text-anchor'  => 'right',
                     'fill'         => 'silver',
                     'fill-opacity' => '50%')
                ->cdata($text);
        }
    }

    return $svg->to_xml;
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

    perldoc Calendar::Plugin::Renderer::SVG

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

1; # End of Calendar::Plugin::Renderer::SVG
