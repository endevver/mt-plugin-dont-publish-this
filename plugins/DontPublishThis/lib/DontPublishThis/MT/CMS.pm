package DontPublishThis::MT::CMS;

use strict;
use warnings;

# The edit screen where different exclusion filters can be set.
sub edit {
    my $app     = shift;
    my $q       = $app->can('query') ? $app->query : $app->param;
    my $blog_id = $q->param('blog_id');
    my $plugin  = $app->component('dontpublishthis');
    my $param   = {};

    $param->{saved} = $q->param('saved') if $q->param('saved');
    $param->{blog_id} = $blog_id;

    # Theoretically, any object type can be checked to see if it should
    # determine if it should/shouldn't be republished. But we only need
    # Comments to work right now.
    $param->{filter_objects} = {
        comment => 'new comments',
        entry   => 'new entries',
    };

    # Set the scope variable to use when loading the filters. If there is no
    # blog, this must be the system level.
    my $scope = $blog_id ? 'blog:'.$blog_id : '';

    # Load the saved filters.
    $param->{saved_filters} = $plugin->get_config_value('filters', $scope);

    # If this isn't the system level, we want to also show what system-level
    # filters have been set.
    if ($blog_id) {
        $param->{system_saved_filters}
            = $plugin->get_config_value('filters', 'system');
    }

    return $plugin->load_tmpl('edit.tmpl', $param);
}

sub save {
    my $app     = shift;
    my $q       = $app->can('query') ? $app->query : $app->param;
    my $blog_id = $q->param('blog_id');

    # Grab the filters. If many filters were added they each will need to be
    # processed.
    my @filter_object = $q->param('filter_object');
    my @filter_text   = $q->param('filter_text');
	my @filter_status = $q->param('filter_status');

    my $filters_count = scalar @filter_text;
    my $counter = 0;
    my @saved_filters;
    while ( $counter < $filters_count ) {
        # Check if a string has been entered in the text field. No point in
        # saving empty filters.
        if ( $filter_text[$counter] ) {
            push @saved_filters, {
                filter_object => $filter_object[$counter],
                filter_text   => $filter_text[$counter],
                filter_status => $filter_status[$counter],
            };
        }

        $counter++;
    }

    # Set the scope variable to use when saving the filters. If there is no
    # blog, this must be the system level.
    my $scope = $blog_id ? 'blog:'.$blog_id : '';

    # Save the exclusion filters. This will also delete any existing filters
    # that the admin may be trying to remove.
    my $plugin = $app->component('dontpublishthis');
    $plugin->set_config_value('filters', \@saved_filters, $scope);

    # Redirect back to the Edit screen.
    $app->redirect(
        $app->uri( mode => 'publish_exclusion_filters.edit',
                   args => { blog_id => $blog_id, saved => 1 } )
    );
}

1;
