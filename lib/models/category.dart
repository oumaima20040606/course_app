class Category {
  final String name;
  final String thumbnail;
  final String subtitle;

  Category({
    required this.name,
    required this.thumbnail,
    required this.subtitle,
  });
}

List<Category> categoryList = [
  Category(
    name: "Backend Engineer",
    subtitle: "Full-stack Web & Mobile\nDeveloper",
    thumbnail: "assets/icons/backend_ilust.jpg",
  ),
  Category(
    name: "Frontend Engineer",
    subtitle: "ReactJS & VueJS\nFrontend Developer",
    thumbnail: "assets/icons/frontend_ilust.jpg",
  ),
  Category(
    name: "Mobile Engineer",
    subtitle: "Flutter Dart\nMobile Developer",
    thumbnail: "assets/icons/mobile_ilust.jpg",
  ),
  Category(
    name: "UI/UX Designer",
    subtitle: "UI UX & Graphic Design",
    thumbnail: "assets/icons/uiux_ilust.jpg",
  ),
];
