package Perly::Bot::Cache;
use strict;
use warnings;
use CHI;

=head1 DESCRIPTION

This is a thin wrapper around C<CHI::File>, used to store URLs of
blog posts emitted by C<Perly::Bot> (to avoid emitting the same
blog posts over and over).

=head1 METHODS

=head2 new ($cache_path, $expires_secs)

Constructor, returns a new Perly::Bot::Cache::Object. Requires
an executable, writable, readable directory path as an argument
and the number of seconds to store a cache entry for.

=cut

sub new
{
  my ($class, $cache_path, $expires_secs) = @_;

  die 'new() requires a directory path with rwx permissions'
    unless $cache_path
      && -x $cache_path
      && -w $cache_path
      && -r $cache_path;

  die 'new() requires a positive integer for the expiry duration of entries'
    unless $expires_secs
      && $expires_secs =~ /^[0-9]+$/
      && $expires_secs > 0;

  my $cache = CHI->new(
    driver      => 'File',
    root_dir    => $cache_path,
    expires_in  => $expires_secs,
  );

  bless { chi => $cache }, $class;
}

=head2 has_posted ($post)

Checks the cache to see if the C<Perly::Bot::Feed::Post> has already been posted.

=cut

sub has_posted {
  my ($self, $post) = @_;
  die 'has_posted() requires a Perly::Bot::Feed::Post object as an argument'
    unless $post && $post->isa('Perly::Bot::Feed::Post');

  $self->{chi}->is_valid($post->root_url);
}

=head2 save_post ($post)

Saves the C<Perly::Bot::Feed::Post> object in the cache.

=cut

sub save_post
{
  my ($self, $post) = @_;
  die 'save_post() requires a Perly::Bot::Feed::Post object as an argument'
    unless $post && $post->isa('Perly::Bot::Feed::Post');

  $self->{chi}->set($post->root_url, $post);
}
1;
