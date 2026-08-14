/// The shared component set, built once and reused.
///
/// CLAUDE.md section 6 lists these by name. A screen that needs a button, a
/// status, a gauge, or a choice card takes it from here rather than assembling
/// its own, because the product rules these encode are judged and are easy to
/// lose one screen at a time.
library;

export 'disclaimer_band.dart';
export 'hold_to_confirm_button.dart';
export 'option_card.dart';
export 'pikir_bottom_nav.dart';
export 'pikir_button.dart';
export 'pikir_card.dart';
export 'pikir_mark.dart';
export 'pikir_scaffold.dart';
export 'pikir_segmented.dart';
export 'source_chip.dart';
export 'status_chip.dart';
export 'threshold_gauge.dart';
export 'tier_progress_bar.dart';
