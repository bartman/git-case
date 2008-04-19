package Test::GitCase::New;
use strict;
use warnings;
use base qw( Test::GitCase );  # Gives us Test::Class magic
use Test::More;

sub make_blank_repository : Test(setup => 4)
{
	my ($self) = @_;

	$self->git_ok('init', 'Ran git-init in work directory');

	# Have to commit something before we can have a branch (git bug?)
	ok(!system('touch', $self->cmd->workdir . '/booger'), 'Created useless file');
	$self->git_ok('add booger',               'Add useless file');
	$self->git_ok('commit -m "Dummy commit"', 'Commit useless file');
}

# Test #1 - create first case in a tree
sub could_create_first_case : Test(7)
{
	my ($self) = @_;

	ok(!-e $self->cmd->workpath('.git/refs/heads/cases'), 'Cases head does not exist');

	$self->cmd_ok({ prog => 'git-case-new', args => 'This is a brand new case' }, 'Ran git-case-new');

	# Argh, damn colour codes.
	like($self->cmd->stdout, qr/New case \e\[33;40m[0-9a-f]{6}\e\[m created/, 'Got expected stdout output');
	is($self->cmd->stderr, '', 'Got expected stderr output');

	ok(-r $self->cmd->workpath('.git/refs/heads/cases'), 'Cases head now exists');

	$self->cmd_ok({ prog => $self->git_binary, args => 'log -b cases' }, 'Ran git-log in work directory');
	like($self->cmd->stdout, qr/This is a brand new case/, 'Got expected stdout output');
}

__PACKAGE__->runtests unless caller();
1;
