class AboutItem {
  final String title;
  final String subtitle;

  AboutItem({
    required this.title,
    required this.subtitle,
  });
}

List<AboutItem> aboutItems = [
  AboutItem(
    title: 'Application Version',
    subtitle: '1.0.0',
  ),
  AboutItem(
    title: 'Application Description',
    subtitle:
        'Application for tracking location with Firebase Realtime Database.',
  ),
  AboutItem(
    title: 'Developer',
    subtitle: 'Developed by UINAM Students',
  ),
];
