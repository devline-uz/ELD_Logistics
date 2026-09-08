/// Komponentlar katalogi — **faqat debug** (`Env.devMenuVisible`).
///
/// Bu ekran foydalanuvchiga ko'rinmaydi va lokalizatsiya qilinmaydi: matnlar
/// token/komponent **nomlari** (`body13`, `Neutral 5`) — ular tarjima
/// qilinmaydi. Shu sababli `// i18n-exempt` belgilari qo'yilgan.
///
/// Marshrut `/dev/components` sifatida `core/router` da ro'yxatdan o'tkaziladi
/// (TODO(M1-router): `AppRoute.devComponents`, faqat `Env.devMenuVisible`).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/config/env.dart';
import '../../core/ui/ui.dart';
import 'gallery_previews.dart';

/// Katalog ekrani ko'rsatilishi mumkinmi.
bool get devGalleryEnabled => kDebugMode || Env.devMenuVisible;

class ComponentsGalleryScreen extends StatefulWidget {
  const ComponentsGalleryScreen({super.key});

  @override
  State<ComponentsGalleryScreen> createState() => _ComponentsGalleryScreenState();
}

class _ComponentsGalleryScreenState extends State<ComponentsGalleryScreen> {
  int _chip = 0;
  DateTime _selectedDay = DateTime.utc(2025, 5, 20);

  @override
  Widget build(BuildContext context) {
    if (!devGalleryEnabled) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: const AppBarPrimary(title: 'Components'), // i18n-exempt
      body: ListView(
        padding: EdgeInsets.all(screenPaddingH(context)),
        children: <Widget>[
          const GallerySection(title: 'Colors', child: ColorsPreview()), // i18n-exempt
          const GallerySection(title: 'Typography', child: TypographyPreview()), // i18n-exempt
          GallerySection(
            title: 'Buttons', // i18n-exempt
            child: Column(
              children: <Widget>[
                AppButton.primary(label: 'Primary', onPressed: () {}), // i18n-exempt
                const SizedBox(height: Spacing.s10),
                AppButton.secondary(label: 'Secondary', onPressed: () {}), // i18n-exempt
                const SizedBox(height: Spacing.s10),
                AppButton.primary(label: 'Destructive', destructive: true, onPressed: () {}),
                const SizedBox(height: Spacing.s10),
                const AppButton.primary(label: 'Disabled'), // i18n-exempt
                const SizedBox(height: Spacing.s10),
                const AppButton.primary(label: 'Busy', busy: true), // i18n-exempt
                const SizedBox(height: Spacing.s10),
                AppButton.text(label: 'Text button', onPressed: () {}), // i18n-exempt
              ],
            ),
          ),
          const GallerySection(
            title: 'Text field', // i18n-exempt
            child: Column(
              children: <Widget>[
                AppTextField(label: 'Label', hint: 'Placeholder'), // i18n-exempt
                SizedBox(height: Spacing.s15),
                AppTextField(
                  label: 'With error', // i18n-exempt
                  hint: 'Placeholder', // i18n-exempt
                  errorText: 'This field is required', // i18n-exempt
                ),
              ],
            ),
          ),
          GallerySection(
            title: 'Chips & badges', // i18n-exempt
            child: Wrap(
              spacing: Spacing.s10,
              runSpacing: Spacing.s10,
              children: <Widget>[
                for (int i = 0; i < 3; i++)
                  AppChip(
                    label: 'Filter $i', // i18n-exempt
                    selected: _chip == i,
                    onTap: () => setState(() => _chip = i),
                  ),
                const StatusBadge(label: 'Certified', tone: StatusTone.success),
                const StatusBadge(label: 'Pending', tone: StatusTone.warning),
                const StatusBadge(label: 'Violation', tone: StatusTone.error),
                const StatusBadge(label: 'Draft', tone: StatusTone.neutral),
                const StatusBadge(label: 'Active', tone: StatusTone.accent),
              ],
            ),
          ),
          const GallerySection(
            title: 'Banners', // i18n-exempt
            child: Column(
              children: <Widget>[
                BannerStrip(message: 'Offline — 3 records queued', tone: BannerTone.offline),
                SizedBox(height: Spacing.s5),
                BannerStrip(message: '2 days not certified', tone: BannerTone.warning),
                SizedBox(height: Spacing.s5),
                BannerStrip(message: 'Violation: 11-hour driving', tone: BannerTone.violation),
                SizedBox(height: Spacing.s5),
                BannerStrip(message: 'ELD disconnected', tone: BannerTone.eld),
              ],
            ),
          ),
          const GallerySection(title: 'HOS — phone', child: HosLinearPreview()), // i18n-exempt
          const GallerySection(title: 'HOS — tablet', child: HosRingPreview()), // i18n-exempt
          const GallerySection(title: 'Duty grid 24h', child: DutyGridPreview()), // i18n-exempt
          GallerySection(
            title: 'Date strip', // i18n-exempt
            child: DateStripPreview(
              selected: _selectedDay,
              onSelected: (DateTime d) => setState(() => _selectedDay = d),
            ),
          ),
          const GallerySection(
            title: 'Sync indicator', // i18n-exempt
            child: Row(
              children: <Widget>[
                SyncIndicator(status: SyncStatus.idle),
                SyncIndicator(status: SyncStatus.syncing),
                SyncIndicator(status: SyncStatus.error),
                SyncIndicator(status: SyncStatus.offline, pendingCount: 3),
              ],
            ),
          ),
          const GallerySection(
            title: 'Empty state', // i18n-exempt
            child: SizedBox(
              height: 240,
              child: EmptyState(
                title: 'No DVIR Found', // i18n-exempt
                message: 'There is no data to show you right now.', // i18n-exempt
              ),
            ),
          ),
          const GallerySection(
            title: 'Error state', // i18n-exempt
            child: SizedBox(
              height: 240,
              child: ErrorState(
                message: 'Something went wrong. Please try again.', // i18n-exempt
                retryLabel: 'Retry', // i18n-exempt
              ),
            ),
          ),
          const GallerySection(
            title: 'Loading skeleton', // i18n-exempt
            child: SizedBox(height: 280, child: LoadingSkeleton(itemCount: 2)),
          ),
          const GallerySection(
            title: 'Bottom sheet', // i18n-exempt
            child: AppBottomSheet(
              title: 'Change Status', // i18n-exempt
              child: SizedBox(height: 80),
            ),
          ),
          const GallerySection(
            title: 'Tablet modal', // i18n-exempt
            child: TabletModal(
              title: 'Add DVIR', // i18n-exempt
              cancelLabel: 'Cancel', // i18n-exempt
              actionLabel: 'Save', // i18n-exempt
              width: 420,
              child: SizedBox(height: 80),
            ),
          ),
          const GallerySection(
            title: 'Confirm dialog', // i18n-exempt
            child: ConfirmDialog(
              title: 'Are you absolutely sure?', // i18n-exempt
              message: 'This action cannot be undone.', // i18n-exempt
              cancelLabel: 'Cancel', // i18n-exempt
              confirmLabel: 'Confirm', // i18n-exempt
              destructive: true,
            ),
          ),
          GallerySection(
            title: 'Signature pad', // i18n-exempt
            child: SignaturePad(
              clearLabel: 'Clear', // i18n-exempt
              saveLabel: 'Save', // i18n-exempt
              hint: 'Sign here', // i18n-exempt
              onSaved: (_) {},
            ),
          ),
        ],
      ),
    );
  }
}

/// Katalog bo'limi sarlavhasi + tarkibi.
class GallerySection extends StatelessWidget {
  const GallerySection({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Spacing.s30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: context.text.body5.copyWith(color: context.colors.textPrimary)),
        const SizedBox(height: Spacing.s15),
        child,
      ],
    ),
  );
}
