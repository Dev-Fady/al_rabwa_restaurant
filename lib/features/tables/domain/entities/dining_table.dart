/// A dine-in table returned by `GET /api/tables`.
class DiningTable {
  const DiningTable({required this.id, required this.name});

  final int id;
  final String name;
}
