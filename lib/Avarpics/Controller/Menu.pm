package Avarpics::Controller::Menu;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Avarpics::Controller::Menu - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $log = $c->{avarpics_log};

    my @files = $log->files;

    $c->stash->{title} = sprintf "%s pic-o-matic", $c->config->{channel};
    $c->stash->{menu} = $self->_menu( @files );
    $c->stash->{template} = 'menu.tt';
}

sub _menu
{
    my ($self, @files) = @_;
    my $menu;
	$menu .= qq{<table id="days">\n};
	$menu .= qq{\t<tr>\n\t\t<td>};

	my $month;
	my $row_cells = 1;

	foreach my $file (@files) {
		my ($file_month) = $file =~ /\d{4}-(\d{2})-\d{2}/g;

		$month = $file_month unless $month;

		if ($file_month ne $month) {
			$month = $file_month;

			if ($row_cells == 6) {	
				$menu .= qq{\n\t</tr>\n\t<tr>\n};
				$row_cells = 1;
			} else {
				$menu .= qq{</td>\n\t\t<td>};
			}
		}

		$menu .= qq{<a href="/day/$file">$file</a><br />\n};
	}

	$menu .= qq{</td>\n\t</tr>\n</table>\n};

	$menu .= "</body>\n</html>";

    return $menu;
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

