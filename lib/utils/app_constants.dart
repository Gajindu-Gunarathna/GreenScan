class AppConstants {
  // Replace with your FastAPI server URL when ready
  static const String aiBaseUrl = 'http://10.252.208.239:8000';
  static const String predictEndpoint = '/predict';

  // WhatsApp
  static const String whatsappNumber = '94702201920';
  static const String whatsappDefaultMessage =
      'Hello! I need help with my betel leaf crop.';

  // Hive box names
  static const String scansBox = 'scans_box';
  static const String treatmentsBox = 'treatments_box';
  static const String districtBox = 'district_box';
  static const String userBox = 'user_box';

  // Sri Lanka districts list
  static const List<String> sriLankaDistricts = [
    'Colombo',
    'Gampaha',
    'Kalutara',
    'Kandy',
    'Matale',
    'Nuwara Eliya',
    'Galle',
    'Matara',
    'Hambantota',
    'Jaffna',
    'Kilinochchi',
    'Mannar',
    'Vavuniya',
    'Mullaitivu',
    'Batticaloa',
    'Ampara',
    'Trincomalee',
    'Kurunegala',
    'Puttalam',
    'Anuradhapura',
    'Polonnaruwa',
    'Badulla',
    'Moneragala',
    'Ratnapura',
    'Kegalle',
  ];
}
