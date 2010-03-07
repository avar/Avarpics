#!/usr/bin/env perl
use 5.010;
use strict;
use Test::More tests => 12;
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


is($data{vid_count}, 4, "vid_count is ok");
is($data{img_count}, 4, "img_count is ok");
is($data{date}, "2010-03-07", "date is ok");
is($data{next_day}, "2010-03-08", "next_day is ok");
is($data{prev_day}, "2010-03-06", "prev_day is ok");

#say dump $data{uris};

my @expect = (
    {
        comment => "/b/, in my lamebook?",
        furi    => "http://img52.imageshack.us/img52/5558/fan59.png",
        type    => "img",
        uri     => "http://imgur.com/FAT0Q.png",
        who     => "fooblah",
        sauce   => "http://www.lamebook.com/wp-content/uploads/2010/03/fan5-9.png",
    },
    {
        comment => undef,
        furi    => "http://img230.imageshack.us/img230/5631/1267932644644.png",
        type    => "img",
        uri     => "http://imgur.com/FyP7a.png",
        who     => "fooblah",
        sauce   => "http://images.4chan.org/b/src/1267932644644.png",
    },
    {
        comment => undef,
        id => "ZbGiPjIE1pE",
        rest => "",
        type => "vid",
        who => "blahblah"
    },
    {
        comment => undef,
        type => "img",
        uri => "http://imgur.com/mB7wO.jpg",
        furi => "http://img31.imageshack.us/img31/7861/1267974943813.jpg",
        who => "blahblah",
        sauce => "http://images.4chan.org/b/src/1267974943813.jpg",
    },
    {
        comment => "lol 90s",
        id => "A08Gsv5DEBk",
        rest => "",
        type => "vid",
        who => "blahblah",
    },
    {
        comment => "oh hlo",
        type => "img",
        uri => "http://imgur.com/0VkPb.jpg",
        who => "blahblah",
        sauce => "http://images.4chan.org/b/src/1267974997983.jpg",
    },
    {
        comment => "testing",
        id => "6FuI7TI2QnM",
        rest => "&feature=sub",
        type => "vid",
        who => "blahblah",
    },
);
#say dump(\@expect);

for (my $i = 0; $i < @expect; $i++) {
    is_deeply($data{uris}->[$i], $expect[$i], "Got #$i: deeply OK for $expect[$i]->{type}");
}

__DATA__
03:09:18 <fooblah> http://www.lamebook.com/wp-content/uploads/2010/03/fan5-9.png # /b/, in my lamebook?
03:09:28 >failo<  - http://imgur.com/FAT0Q.png / http://img52.imageshack.us/img52/5558/fan59.png
04:02:42 <fooblah> http://images.4chan.org/b/src/1267932644644.png
04:02:49 >failo<  - http://imgur.com/FyP7a.png / http://img230.imageshack.us/img230/5631/1267932644644.png
14:45:05 <blahblah> http://www.youtube.com/watch?v=ZbGiPjIE1pE
14:45:08 >failo< YouTube - The Listening Post - The 'hearts and minds' of Operation Moshtarak - Part 2
15:16:52 <blahblah> http://images.4chan.org/b/src/1267974943813.jpg
15:17:01 >failo< jpeg (633 x 772) - http://imgur.com/mB7wO.jpg / http://img31.imageshack.us/img31/7861/1267974943813.jpg
15:18:21 <blahblah> lol 90s: http://www.youtube.com/watch?v=A08Gsv5DEBk
15:18:21 >failo< YouTube - Nirvana on ice
15:24:28 <blahblah> http://images.4chan.org/b/src/1267974997983.jpg # oh hlo
15:24:41 >failo< jpeg (457 x 686) - http://imgur.com/0VkPb.jpg /
15:31:55 <blahblah> http://www.youtube.com/watch?v=6FuI7TI2QnM&feature=sub # testing
15:31:56 >failo< YouTube - An Astronomical Success Story: The La Silla Observatory
16:31:56 <fooblah> http://www.youtube.com/watch?v=7XtuPvwBa2U
16:31:57 >failo< YouTube - how to complete a census
