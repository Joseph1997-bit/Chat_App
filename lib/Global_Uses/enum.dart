//Enum değerlerin en büyük avantajı okunulabilir olmayan veya aynı çeşitte sabit değerlerle ifade edilen static değerlerin daha basit yapılara çevrilmesidir
//yani değişkenlerin alabileceği değerlerin sabit (belli) olduğu durumlarda programı daha okunabilir hale getirmek için kullanılır
enum EmailSignUpResults {
  signUpCompleted,
  emailAlreadyPresent,
  signUpNotCompleted,
}

enum EmailSignInResults {
  signInCompleted,
  emailNotVerified,
  emailOrPasswordInvalid,
  unexpectedError,
}

enum GoogleSignInResults {
  SignInCompleted,
  SignInNotCompleted,
  UnexpectedError,
  AlreadySignedIn,
}
enum FBSignInResults {
  SignInCompleted,
  SignInNotCompleted,
  AlreadySignedIn,
  UnExpectedError,
}

enum StatusMediaTypes {
  TextActivity,
  ImageActivity,
}

enum ConnectionStateName {
  Connect,
  Pending,
  Accept,
  Connected,
}

enum ConnectionStateType {
  ButtonNameWidget,
  ButtonBorderColor,
  ButtonOnlyName,
}

enum OtherConnectionStatus {
  Request_Pending,
  Invitation_Came,
  Invitation_Accepted,
  Request_Accepted,
}

enum ChatMessageTypes {
  None,
  Text,
  Image,
  Video,
  Document,
  Audio,
  Location,
}

enum ImageProviderCategory {
  FileImage,
  ExactAssetImage,
  NetworkImage,
}

enum MessageHolderType {
  Me,
  ConnectedUsers,
}

enum GetFieldForImportantDataLocalDatabase {
  UserEmail,
  Token,
  ProfileImagePath,
  ProfileImageUrl,
  About,
  WallPaper,
  MobileNumber,
  Notification,
  AccountCreationDate,
  AccountCreationTime,
}

enum PreviousMessageColTypes {
  ActualMessage,
  MessageDate,
  MessageTime,
  MessageHolder,
  MessageType,
}