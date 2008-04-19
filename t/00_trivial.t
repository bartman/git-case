package Test::GitCase::Trivial;
use strict;
use warnings;
use base qw( Test::GitCase );  # Gives us Test::Class magic
use Test::More;

# These are very trivial tests.  We probably don't really need them, but
# this test file makes a good template for new tests, so we keep it in
# working order.

# - If subroutine name is suffixed with the attribute:
# 	: Test(somenumber)
#   it means that it runs that many tests.
# - Test methods can be named whatever you want
# - All methods with a :Test attribute are run when ->runtests (see bottom
#   of file) executes.
sub test_the_test_harness : Test(2)
{
	my ($self) = @_;

	isa_ok($self->cmd, 'Test::Cmd', 'Test object has a {cmd} member');
	ok(-d $self->cmd->workdir, '->workdir() is a directory');
}

sub run_a_command : Test(3)
{
	my ($self) = @_;

	# ->run is the same as ->cmd->run(), except it passes in a few
	# standard options to run() as defined by ->run_args().  Call
	# set_run_args() if you need to change this.
	is($self->run(prog => 'git-case-list') >> 8, 128, 'git-case-list fails');
	is($self->cmd->stdout, '', 'Got expected stdout output');
	is($self->cmd->stderr, "fatal: Not a git repository\n", 'Got expected stderr output');

}

# This bit of magic below runs all tests in this file if and only if this
# file is called as a script.
__PACKAGE__->runtests unless caller();
1;
