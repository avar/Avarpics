#!/usr/bin/env perl
use 5.010;
use strict;
use Test::More;
use Avarpics::Log;
use Data::Dump 'dump';

my $DATA = join "", <DATA>;

my $log = Avarpics::Log->new(
    channel => '#test',
    logdir => 'test',
    logext => 'test',
    names => {},
);

my %data = $log->data_for_day("2010-03-07", $DATA);
#say dump(\%data);

is($data{vid_count}, 2, "vid_count is ok");
is($data{img_count}, 2, "img_count is ok");
is($data{date}, "2010-03-07", "date is ok");
is($data{img_count}, 2, "img_count is ok");
is($data{next_day}, "2010-03-08", "next_day is ok");
is($data{prev_day}, "2010-03-06", "prev_day is ok");

my @expect = (
    {
        comment => undef,
        type => "img",
        uri => "http://imgur.com/mB7wO.jpg",
        furi => "http://img31.imageshack.us/img31/7861/1267974943813.jpg",
        who => "avar",
    },
    {
        comment => "lol 90s",
        id => "A08Gsv5DEBk",
        rest => "",
        type => "vid",
        who => "avar",
    },
    {
        comment => "oh hlo",
        type => "img",
        uri => "http://imgur.com/0VkPb.jpg",
        who => "avar",
    },
    {
        comment => "testing",
        id => "6FuI7TI2QnM",
        rest => "&feature=sub",
        type => "vid",
        who => "avar",
    },
);

for (my $i = 0; $i < @expect; $i++) {
    is_deeply($data{uris}->[$i], $expect[$i], "Got deeply OK for $expect[$i]->{type}");
}

done_testing();

__DATA__
15:11:06 < avar> interesting: http://search.cpan.org/~yewenbin/Emacs-PDE-0.2.16/
15:11:06 -failo:#avar- 叶文彬 / Emacs-PDE-0.2.16 - search.cpan.org
15:16:52 < avar> http://images.4chan.org/b/src/1267974943813.jpg
15:17:01 -failo:#avar- jpeg (633 x 772) - http://imgur.com/mB7wO.jpg / http://img31.imageshack.us/img31/7861/1267974943813.jpg
15:18:21 < avar> lol 90s: http://www.youtube.com/watch?v=A08Gsv5DEBk
15:18:21 -failo:#avar- YouTube - Nirvana on ice
15:24:28 < avar> http://images.4chan.org/b/src/1267974997983.jpg # oh hlo
15:24:41 -failo:#avar- jpeg (457 x 686) - http://imgur.com/0VkPb.jpg /
15:31:55 < avar> http://www.youtube.com/watch?v=6FuI7TI2QnM&feature=sub # testing
15:31:56 -failo:#avar- YouTube - An Astronomical Success Story: The La Silla Observator
