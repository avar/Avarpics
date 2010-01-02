use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'Avarpics' }
BEGIN { use_ok 'Avarpics::Controller::Day' }

#ok( request('/day/2009-01-01')->is_success, 'Request should succeed' );
done_testing();
