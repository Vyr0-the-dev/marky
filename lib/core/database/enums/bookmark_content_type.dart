/// Classification of the saved link's primary content.
///
/// Used by the feed to pick the right card layout (video thumb vs
/// article hero vs audio cover) and by filters to narrow a user's
/// library to a single medium.
///
/// Stored with [EnumType.name] so reordering/appending values never
/// corrupts existing rows — only *renaming* a value breaks old data,
/// which is an intentional guardrail: renames require a real
/// migration, not a silent ordinal shift.
enum BookmarkContentType {
  /// Default when detection fails or the content is plain HTML.
  article,

  /// YouTube, Vimeo, Twitch clip, native video embed.
  video,

  /// Standalone image link (direct image URL, Imgur, etc.).
  image,

  /// Reddit / Hacker News / Twitter thread or other discussion page.
  discussion,

  /// Podcast episode, Spotify track, SoundCloud clip.
  audio,

  /// GitHub repo, GitLab project, npm / pub / crates package.
  code,

  /// Amazon, Shopify, product landing page.
  product,

  /// PDF / Google Docs / other document formats.
  document,

  /// Unknown or unparseable — keep the bookmark, show a neutral card.
  unknown,
}
