final List<String> searchFilters = [
  'Открыто сейчас',
  'Бронь',
  'Предзаказ',
  'Предзаказ',
];

class SearchItemsData {
  final String title;
  final String address;
  final String workingHours;

  SearchItemsData(
      {required this.title, required this.address, required this.workingHours});
}

final List<SearchItemsData> searchItems = [
  SearchItemsData(
    title: "Грузинский дворик",
    address: "15 Abdulla Kaxxar ko'chasi, Tashkent",
    workingHours: "Работает до 2:00",
  ),
  SearchItemsData(
    title: "Ресторан Караван",
    address: "30А Shota Rustaveli, Tashkent",
    workingHours: "Работает до 2:00",
  ),
  SearchItemsData(
    title: "Basilic Restaurant",
    address: "19 Амир Темур шоҳ кўчаси, Tashkent",
    workingHours: "Работает до 23:00",
  ),
  SearchItemsData(
    title: "Кафе-ресторан Огни Ташкента",
    address: "15 Abdulla Kaxxar ko'chasi, Tashkent",
    workingHours: "Работает до 22:00",
  ),
  SearchItemsData(
    title: "Грузинский дворик",
    address: "15 Abdulla Kaxxar ko'chasi, Tashkent",
    workingHours: "Работает до 22:00",
  ),
  SearchItemsData(
    title: "Грузинский дворик",
    address: "15 Abdulla Kaxxar ko'chasi, Tashkent",
    workingHours: "Работает до 12:00",
  ),
];
