package DontPublishThis::MT::Callbacks;

use strict;
use warnings;

# Use the object-level `post_insert` callback on the Comment object, which is
# issued when saving new objects only. This way we can stop publishing when a
# new comment is added that meets the filter exlusion test, but if the comment
# *doesn't* meet the test then it still publishes.
sub callback_comment_post_insert {
    my ($cb, $app, $obj, $original) = @_;
    my $blog_id = $obj->blog_id;
    my $plugin  = MT->component('dontpublishthis');

    my $scope = 'blog:' . $blog_id;

    # Search through all filters to find the ones that apply to comments. Load
    # both blog-level and system-level filters.
    my @comment_filters = grep { $_->{filter_object} eq 'comment' }
        @{$plugin->get_config_value('filters', $scope),
            $plugin->get_config_value('filters', 'system')};

    my $filters_count = scalar @comment_filters;
    my $counter = '0';
    while ( $counter < $filters_count ) {
        my $filter_text = $comment_filters[$counter]->{filter_text};

        # If the text in the comment *does* match the text in the filter, this
        # should not be published.
        if ( $obj->text =~ m/$filter_text/i ) {
            MT->request('dontpublishthis', 1);

            # Additionally, set this entry to "unpublished."
            if ( $comment_filters[$counter]->{filter_status} eq 'unpublished' ) {
                $obj->moderate; # Sets the comment to not visible and not junk
                $obj->save or die $obj->errstr;
            }

            # Once we've found one test that identified this as a comment not
            # to cause publishing, we can just give up. Further matches won't
            # change the status.
            last;
        }

        $counter++;
    }
}

# Use the object-level `post_insert` callback on the Entry object, which is
# issued when saving new objects only. This way we can stop publishing when a
# new entry is added that meets the filter exlusion test, but if the entry
# *doesn't* meet the test then it still publishes.
sub callback_entry_post_insert {
    my ($cb, $app, $obj, $original) = @_;
    my $blog_id = $obj->blog_id;
    my $plugin  = MT->component('dontpublishthis');

    my $scope = 'blog:' . $blog_id;

    # Search through all filters to find the ones that apply to comments. Load
    # both blog-level and system-level filters.
    my @comment_filters = grep { $_->{filter_object} eq 'entry' }
        @{$plugin->get_config_value('filters', $scope),
            $plugin->get_config_value('filters', 'system')};

    my $filters_count = scalar @comment_filters;
    my $counter = '0';
    while ( $counter < $filters_count ) {
        my $filter_text = $comment_filters[$counter]->{filter_text};

        # If the text in the entry (title, text, or extended fields) *does*
        # match the text in the filter, this should not be published.
        if (
            $obj->title =~ m/$filter_text/i
            || $obj->text =~ m/$filter_text/i
            || $obj->text_more =~ m/$filter_text/i
        ) {
            MT->request('dontpublishthis', 1);

            # Additionally, set this entry to "unpublished."
            if ( $comment_filters[$counter]->{filter_status} eq 'unpublished' ) {
                $obj->status( MT->model('entry')->HOLD() );
                $obj->save or die $obj->errstr;
            }

            # Once we've found one test that identified this as a comment not
            # to cause publishing, we can just give up. Further matches won't
            # change the status.
            last;
        }

        $counter++;
    }
}

# The build_file_filter callback is where a publish job is actually stopped. A
# request object is set elsewhere (such as in the Comment `post_insert` object
# callback) and that request is used here to determine if publishing should
# continue.
sub callback_build_file_filter {
    my ( $cb, %args ) = @_;

    # If the `dontpublishthis` request object has been set, that simply means
    # any publish jobs in this request should not be republished.
    if ( MT->request('dontpublishthis') ) {
        MT->log("At the build_file_filter callback -- don't publish items with this request for URL ". $args{file_info}->url);
        return 0;
    }
}

1;
