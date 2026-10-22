/// Placeholder model names, sizes, speeds, and the 6 GB floor.
/// Task 3 replaces this file with the real catalog. Do not scatter these
/// strings through the UI.
class ModelSpec {
  const ModelSpec({
    required this.id,
    required this.name,
    required this.sizeLabel,
    required this.gigabytes,
    required this.speedLabel,
    this.reason,
    this.note,
  });

  final String id;
  final String name;
  final String sizeLabel;
  final double gigabytes;
  final String speedLabel;
  final String? reason;
  final String? note;
}

class ModelCatalog {
  const ModelCatalog._();

  static const minimumMemoryGb = 6.0;

  /// Placeholder device copy from the prototype. Not a live device read.
  static const supportedDevice = 'iPhone 15 Pro · 8 GB 内存';
  static const supportedDeviceNote = '下面这些都能流畅运行';
  static const placeholderMemoryGb = 8.0;
  static const unsupportedDevice = 'iPhone XR · 3 GB 内存';
  static const unsupportedDeviceNote = '这台手机';

  static const mid = ModelSpec(
    id: 'mid',
    name: '均衡',
    sizeLabel: '1.1 GB',
    gigabytes: 1.1,
    speedLabel: '快 · 回应大约 4 秒',
    reason: '这台手机有 8 GB 内存，跑它刚刚好：回应细腻，也不会让手机发烫。',
  );

  static const small = ModelSpec(
    id: 'small',
    name: '轻巧',
    sizeLabel: '420 MB',
    gigabytes: 0.42,
    speedLabel: '很快 · 大约 2 秒',
    note: '最省空间，回应会短一些',
  );

  static const large = ModelSpec(
    id: 'large',
    name: '细腻',
    sizeLabel: '1.9 GB',
    gigabytes: 1.9,
    speedLabel: '稍慢 · 大约 8 秒',
    note: '读得更仔细，适合写得长的日子',
  );

  static const all = [mid, small, large];

  static ModelSpec byId(String id) =>
      all.firstWhere((model) => model.id == id, orElse: () => mid);

  /// 6 GB → 轻巧, 8 GB → 均衡, ≥12 GB still 均衡. 细腻 stays optional.
  static String? recommendedId(double memoryGb) {
    if (memoryGb < minimumMemoryGb) return null;
    if (memoryGb < 8) return small.id;
    return mid.id;
  }
}
