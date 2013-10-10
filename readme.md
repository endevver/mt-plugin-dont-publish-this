# Don't Publish This for Movable Type

Don't Publish This is a plugin for Movable Type that helps streamline
publishing by letting administrators identify conditions when a job does
**not** need to be republished. In a high-activity environment, needlessly
republishing files can be detrimental to performance. Said differently, there
are times Movable Type will republish files unnecessarily, and this plugin will
help administrators to work around that problem.

A very specific example from a client's install: a simple location check-in
system allows users to easily submit a "I checked in here" comment. Those
"comments" are never published through the templates, but Movable Type still
republishes the associated files. Eliminating that publishing job is a good
idea, and that's what this plugin allows.


# Prerequisites

* Movable Type Pro 5+

# Installation

To install this plugin follow the instructions found here:

http://tinyurl.com/easy-plugin-install

# Configuration

Visit Settings > Publishing Exclusion Filters at the System, Website, or Blog
level to created and edit filters. Select the object the filter should effect,
the text that must match to cause the object to not publish, and choose if the
publish status should be changed. Be sure to save.

The text match field can contain Perl-flavored regular expressions. Below are
many examples:

* Simple plain-text match: `do not publish`
* Regular expression to match the first words in the field: `^Check-in from`
* Regular expression to match a 10-digit phone number:
  `[0-9]{3}-?[0-9]{3}-?[0-9]{4}`

This plugin uses Movable Type "callbacks" to execute. In other words,
submitting a comment or creating an entry will cause these filters to be tested
-- no extra work required.

# License

This plugin is licensed under the same terms as Perl itself.

# Copyright

Copyright 2013, Endevver LLC. All rights reserved.
