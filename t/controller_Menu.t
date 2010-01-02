use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'Avarpics' }
BEGIN { use_ok 'Avarpics::Controller::Menu' }

ok( request('/menu')->is_success, 'Request should succeed' );
done_testing();
