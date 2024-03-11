/// This error is thrown when the plugin reports an error.
final class PicTrimException implements Exception {
  /// Create a new native_image_cropper exception with the given error code
  /// and description.
  const PicTrimException(this.code, [this.description]);

  /// Error code.
  final String code;

  /// Textual description of the error.
  final String? description;

  @override
  String toString() => 'NativeImageCropperException($code, $description)';
}
