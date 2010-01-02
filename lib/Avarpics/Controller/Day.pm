package Avarpics::Controller::Day;
use Moose;
use namespace::autoclean;
use Date::Calc qw(Add_Delta_Days);

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Avarpics::Controller::Day - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :CaptureArgs(1) {
    my ( $self, $c, $day ) = @_;

    if ($day =~ /^(\d\d\d\d-\d\d-\d\d)$/) {
        my %vars = $self->_process( $c, $1 );
        while (my ($k, $v) = each %vars) {
            $c->stash->{$k} = $v;
        }
    } else {
        $c->error( "$day is not a valid day" );
    }

    $c->stash->{template} = 'day.tt';
}

sub _process {
	my ($self, $c, $date) = @_;

    my $log = Avarpics::Log->new(
        logdir => $c->config->{logdir},
        logext => $c->config->{logext},
        logpre => $c->config->{logpre},
        channel => $c->config->{channel},
    );

    my $text = $log->on_date_slurp( $date );

	#error('nonesuch') unless -f $file;
	#error('problemo') unless -r $file;

	my ($current_nick, %seen, @uris);

	# Need to define this outside loop as it has to persist from
	# a *chan URI (which is not kept) to the following ImageShack URI.
	my $comment;

	my $img_count = 0;
	my $vid_count = 0;
	
	foreach my $line (split /\n/, $text) {
		if ($line =~ /<(?:\@|\+| )(\w+)>/) {
			$current_nick = $1;
		}
				
		my $fileext = qr/\.(?:jpg|jpeg|gif|png|bmp)/i;
		
		if ($line =~ m{(http://[\S]+?$fileext)}) {
			my $uri = $1;
			
			if ($line =~ /\s+#\s+(.*)/) {
				$comment = $1;
			}

			if (!$seen{$uri} && $uri !~ /\dchan\./) {

				push @uris, {
					'type'    => 'img',
					'uri'     => $uri,
					'who'     => $current_nick,
					'comment' => $comment,
				};

				$img_count++;		
				undef $comment;	
			}

			$seen{$uri} = 1;
		} elsif ($line =~ m#youtube\.com/watch\?v=(\w{11})#) {
			my $id = $1;

			my ($vid_comment) = $line =~ /\s+#\s+(.*)/g;

			push @uris, {
				'type'    => 'vid',
				'id'      => $id,
				'who'     => $current_nick,
				'comment' => $vid_comment,
			};
			
			$vid_count++;
		} elsif ($line =~ m#(http://www.flickr.com/photos/\w+/\d{10}/)#) {
			my $flickr = $1;
			my ($flickr_id) = $flickr =~ m#(\d{10})#;
			
			my $mech = WWW::Mechanize->new;
			$mech->agent_alias('Windows IE 6');
			$mech->get($flickr);
			next unless $mech->success;
			
			$mech->content =~ m#<link rel="image_src" href="(http://farm\d.static.flickr.com/\d+/\d{10}_\w{10}_\w.jpg)" />#gs;
			my $uri = $1;
			next unless $uri;
			
			if (!$seen{$uri}) {

				push @uris, {
					'type'      => 'img',
					'uri'       => $uri,
					'who'       => $current_nick,
					'comment'   => $comment,
					'flickr_id' => $flickr_id,
				};

				$img_count++;		
				undef $comment;	
			}

			$seen{$uri} = 1;
		}
	}

	my $options = {
		'date'      => $date,
		'uris'      => \@uris,
		'img_count' => $img_count,
		'vid_count' => $vid_count,
	};

	my ($year, $month, $day) = $date =~ /(\d\d\d\d)-(\d\d)-(\d\d)/g;

	my ($pdy, $pdm, $pdd) = Add_Delta_Days($year, $month, $day, -1);
	$pdm = sprintf("%02d", $pdm);
	$pdd = sprintf("%02d", $pdd);

	my ($ndy, $ndm, $ndd) = Add_Delta_Days($year, $month, $day, 1);
	$ndm = sprintf("%02d", $ndm);
	$ndd = sprintf("%02d", $ndd);

	$options->{'prev_day'} = join '-', ($pdy, $pdm, $pdd);
	$options->{'next_day'} = join '-', ($ndy, $ndm, $ndd); 

    %$options;
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

