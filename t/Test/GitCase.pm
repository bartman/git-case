package Test::GitCase;
use strict;
use warnings;

use Test::Class;
use base qw( Test::Class );

use Test::Cmd;
use Test::More;
use File::Temp  ();
use File::Which ();

=head1 NAME

Test::GitCase - Test::Class subclass for git-case

=head1 SYNOPSIS

Test::GitCase subclasses Test::Class to implement a testharness
framework for testing git-case.

See and understand L<Test::Class> first.

=head1 METHODS

=over 4

=item git_binary ( )

Returns path to git binary

=cut

sub git_binary
{
	my ($self) = @_;

	if(!$self->{git_binary}) {
		$self->{git_binary} = File::Which::which('git');
	}

	return $self->{git_binary};
}

=item get_run_args ( )

Get default args used for ->run()

=cut

sub get_run_args
{
	return %{ $_[0]->{run_args} };
}

=item set_run_args ( $hashref )

Set default args used for ->run()

=cut

sub set_run_args
{
	$_[0]->{run_args} = $_[1];
	return %{ $_[0]->{run_args} };
}

=item cmd 

Return our L<Test::Cmd> instance.

=cut

sub cmd
{
	my ($self) = @_;

	return $self->{cmd};
}

=item run ( %args )

Calls ->cmd->run, using both the provided arguments and the
preconfigured defaults merged together.  In case of collision,
arguments provided to this method override the defaults.

For test counting purposes, does not count as a test.

See L<Test::Cmd/run> for details as to which named arguments are
permitted.

=cut

sub run
{
	my ($self, %args) = @_;

	return $self->cmd->run($self->get_run_args, %args,);
}

=item cmd_ok ( $args, $msg )

Test helper for executing commands.

Calls ->run, using the $args hashref, and tests that the return code is
zero.  Outputs the test result with $msg.

For test counting purposes, counts as one test.

See L<Test::Cmd/run> for details as to which named arguments are
permitted.

=cut

sub cmd_ok
{
	my ($self, $args, $msg) = @_;

	$args ||= {};
	$msg  ||= 'command exited with 0 return code';

	my $rc = $self->run(%{$args});

	unless (is($rc >> 8, 0, $msg)) {
		diag($self->{cmd}->stderr);
	}

	return $rc;
}

=item git_ok ( $git_arguments, $msg )

Test helper for executing git commands.

Calls ->run on ->git_binary, using $git_arguments (a string containing
any arguments and options for git).

Outputs the test result with the message $msg.  For test counting
purposes, counts as one test.

=cut

sub git_ok
{
	my ($self, $args, $msg) = @_;

	return $self->cmd_ok({ prog => $self->git_binary, args => $args }, $msg);
}

=item create_cmd_object ( )

Test::Class startup hook that creates a new Test::Cmd object
(accessible hereafter using $self->cmd) for this Test::Class instance.

=cut

sub create_cmd_object : Test(startup => 1)
{
	my ($self) = @_;

	$self->{cmd} = Test::Cmd->new(
		workdir => '',  # Allow Test::Cmd to autocreate
	);

	$self->set_run_args(
		{
			chdir => '.',  # Force tests to run in workdir
		}
	);

	if(!isa_ok($self->{cmd}, 'Test::Cmd', 'Created Test::Cmd object')) {
		BAIL_OUT('Could not create Test::Cmd object; aborting');
	}

}

=item cleanup_cmd_object ( )

Test::Class shutdown hook that cleans up this instance's Test::Cmd
object.

=cut

sub cleanup_cmd_object : Test(shutdown)
{
	my ($self) = @_;
	if($self->{cmd}) {
		$self->{cmd}->cleanup;
	}
}

=pod

=back

=cut

1;
