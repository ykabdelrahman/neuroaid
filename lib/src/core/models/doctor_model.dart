class DoctorModel {
  final int id;
  final String name;
  final String specialty;
  final String experience;
  final double rating;
  final int reviews;
  final String distance;
  final bool available;
  final String nextAvailable;
  final String image;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.available,
    required this.nextAvailable,
    required this.image,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown Doctor',
      specialty: json['specialty'] as String? ?? 'General',
      experience: json['experience'] as String? ?? 'N/A',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] as int? ?? 0,
      distance: json['distance'] as String? ?? 'Unknown',
      available: json['available'] as bool? ?? false,
      nextAvailable: json['nextAvailable'] as String? ?? 'N/A',
      image: json['image'] as String? ?? 'https://i.pravatar.cc/150',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'experience': experience,
      'rating': rating,
      'reviews': reviews,
      'distance': distance,
      'available': available,
      'nextAvailable': nextAvailable,
      'image': image,
    };
  }
}
