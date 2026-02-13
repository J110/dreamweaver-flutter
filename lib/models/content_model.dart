/// This file provides a generic Content type alias and exports all content-related models.
///
/// The Content type is used in providers for generic content operations.
/// Individual content implementations (Story, Poem, Song) extend ContentBase.

export 'content/content_base.dart';
export 'content/story_model.dart';
export 'content/poem_model.dart';
export 'content/song_model.dart';
export 'content/content_category.dart';

// Type alias for generic content references in providers
// Represents any content type (Story, Poem, Song) that extends ContentBase
typedef Content = ContentBase;
