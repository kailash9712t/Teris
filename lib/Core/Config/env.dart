class Config {
  static const String baseUrl = "http://10.0.2.2:8080/api/user";
  static const String socketBaseUrl = "http://10.0.2.2:8080";
}

class LocalData {
  static String userDataboxName = "TempData";
  static String homePageBoxName = "HomePageData";

  static void mergeUsername(String username) {
    userDataboxName = "$username $userDataboxName";
    homePageBoxName = "$username $homePageBoxName";
  }
}