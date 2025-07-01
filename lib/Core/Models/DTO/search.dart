class SearchPageModel {}

class FetchedContactModel {
  String username;
  String displayName;
  String? profilePhotoId;
  int mobileNumber;
  FetchedContactModel({required this.mobileNumber,required this.profilePhotoId,required this.displayName,required this.username});
}
