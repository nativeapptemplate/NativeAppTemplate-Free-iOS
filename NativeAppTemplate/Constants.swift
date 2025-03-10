//
//  Constants.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2024/10/01.
//

import typealias Foundation.TimeInterval

extension Int {
  static let minimumPasswordLength: Int = 8
  static let invitationCodeLength: Int = 6
}

extension String {
#if DEBUG
  //  static let scheme: String = "http"
  //  static let domain: String = "192.168.1.21"
  //  static let port: String = "3000"
  static let scheme: String = "https"
  static let domain: String = "api.nativeapptemplate.com"
  static let port: String = ""
#else
  static let scheme: String = "https"
  static let domain: String = "api.nativeapptemplate.com"
  static let port: String = ""
#endif
  
  static let androidAar: String = "com.nativeapptemplate.nativeapptemplatefree"
  static let androidAarNfcndefPayloadType: String = "android.com:pkg"
  
  // This is for MyTurnTag Creator. Replace this.
  static let appStoreUrl: String = "https://apps.apple.com/app/myturntag-creator/id1516198303"
  
  static let scanPath: String = "scan"
  static let scanPathCustomer: String = "scan_customer"
  
  static let placeholderFullName: String = "John Smith"
  static let placeholderEmail: String = "you@example.com"
  static let placeholderPassword: String = "password"
  
  static let defaultTimeZone: String = "London"
  
  static let keychainAccountLoggedInShopkeeper = "com.nativeapptemplate.NativeAppTemplateFree.LoggedInShopkeeperAccount"
  static let keychainServiceLoggedInShopkeeper = "com.nativeapptemplate.NativeAppTemplateFree.LoggedInShopkeeperService"
  
  static let shops = "Shops"
  static let scan = "Scan"
  static let settings = "Settings"
  static let loading = "Loading..."
  
  // MARK: Resend Confirmation Instructions View
  static let buttonSendMeConfirmationInstructions = "Resend confirmation instructions"
  static let didntReceiveConfirmationInstructions = "Didn't receive confirmation instructions?"
  
  // MARK: Forgot Password View
  static let buttonSendMeResetPasswordInstructions = "Send me reset password instructions"
  static let forgotYourPassword = "Forgot your password?"
  
  // MARK: Shop View
  static let shopName = "Shop Name"
  static let createShop = "Create Shop"
  static let editShop = "Edit Shop"
  static let addShop = "Add Shop"
  static let addShopDescription = "Add a new shop."
  static let deleteShop = "Delete Shop"
  static let shopNameIsRequired = "Shop name is required."
  static let timeZone = "Time Zone"
  static let createShopsLabel = "Create shops"
  static let tapShopBelow = "Tap a shop below."
  static let haveFun = "Have fun!"
  
  // MARK: Shop Detail View
  static let swipeNumberTagBelow = "Swipe a number tag below."
  static let tapDisplayedButton = "Tap the displayed button."
  static let serverNumberTagsWebpageWillBeUpdated = "The Server Number Tags Webpage will be updated."
  static let readInstructions = "Read Instructions"
  static let serverNumberTagsWebpage = "Server Number Tags Webpage"
  
  // MARK: Shop Settings View
  static let shopSettingsLabel = "Shop Settings"
  static let shopSettingsBasicSettingsLabel = "Basic Settings"
  static let shopSettingsManageNumberTagsLabel = "Manage Number Tags"
  static let shopSettingsNumberTagsWebpageLabel = "Number Tags Webpage"
  static let resetNumberTagsDescription = "Reset all number tag statuses."
  static let resetNumberTags = "Reset Number Tags"
  
  // MARK: Number Tags Web Pages
  static let copyWebpageUrl = "Copy the above webpage URL"
  static let webpageUrlCopied = "Webpage URL copied."
  
  // MARK: Item Tag View
  static let tagNumber = "Tag Number"
  static let editTag = "Edit Tag"
  static let addTag = "Add Tag"
  static let addTagDescription = "Add a new number tag and start changing the tag status."
  static let deleteTag = "Delete tag"
  static let buttonDeleteTag = "Delete Tag"
  static let tagNumberIsInvalid = "Tag number is invalid."
  static let writeServerTag = "Write Server Tag"
  static let writeCustomerTag = "Write Customer Tag"
  static let youCannotUndoAfterLockingTag = "You cannot undo. After locking the tag, you can no longer write data to it."
  static let zeroPadding = "Zero padding(e.g. 07)."
  static let writingSucceeded = "Writing succeeded!"
  
  // MARK: Scan View
  static let completeScan = "Complete Scan"
  static let showTagInfoScan = "Show Tag Info Scan"
  static let tagInfo = "Tag info"
  static let readOnly = "Read Only"
  static let writable = "Writable"
  static let completeScanHelp = "Read a NFC Number Tag for changing the Number Tag status."
  static let showTagInfoScanHelp = "Read a NFC Number Tag for showing the Number Tag information."
  static let deviceDoesNotSupportScan = "This device doesn't support tag scanning."
  static let holdYourIPhoneNearTheItem = "Hold your iPhone near the item to learn more about it."
  static let tagNotValid = "Tag not valid."
  static let moreThan1TagsWasFound = "More than 1 tags was found. Please present only 1 tag."
  static let tagIsNotWritable = "Tag is not writable."
  static let tagIsNotNdefFormatted = "Tag is not NDEF formatted."
  
  // MARK: Settings View
  static let supportMail: String = "support@nativeapptemplate.com"
  static let supportWebsiteUrl: String = "https://nativeapptemplate.com"
  static let howToUseUrl: String = "https://myturntag.com/how"
  static let faqsUrl: String = "https://nativeapptemplate.com/faqs"
  static let discussionsUrl: String = "https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/discussions"
  static let privacyPolicyUrl: String = "https://nativeapptemplate.com/privacy"
  static let termsOfUseUrl: String = "https://nativeapptemplate.com/terms"
  
  static let myAccount = "My Account"
  static let profile = "Profile"
  static let information = "Information"
  static let supportWebsite = "Support Website"
  static let howToUse = "How To Use"
  static let faqs = "FAQs"
  static let discussions = "Discussions"
  static let rateApp = "Rate or Review the App"
  static let emailUs = "Email Us"
  static let contact = "Contact"
  static let privacyPolicy = "Privacy Policy"
  static let termsOfUse = "Terms of Use"
  static let editProfile = "Edit Profile"
  static let deleteMyAccount = "Delete My Account"
  static let updatePassword = "Update Password"
  static let currentPassword = "Current Password"
  static let newPassword = "New Password"
  static let confirmNewPassword = "Confirm New Password"
  static let currentPasswordIsRequired = "Current password is required."
  static let newPasswordIsRequired = "New password is required."
  static let confirmNewPasswordIsRequired = "Confirm new password is required."
  static let weNeedYourCurrentPassword = "We need your current password to confirm your changes."
  static let reconfirmDescription = "A message with a confirmation link has been sent to your new email address. Please follow the link to update to your new email address. Your email address will not be updated until confirming."
  
  // MARK: Messaging
  static let shopCreated = "Shop created successfully."
  static let basicSettingsUpdated = "Basic settings updated successfully."
  static let shopDeleted = "Shop deleted successfully."
  static let shopDeletedError = "There was a problem deleting the shop."
  static let shopReset = "All number tags reset."
  static let shopResetError = "There was a problem resetting number tags."
  
  static let itemTagCreated = "Tag created successfully."
  static let itemTagUpdated = "Tag updated successfully."
  static let itemTagDeleted = "Tag deleted successfully."
  static let itemTagDeletedError = "There was a problem deleting the tag."
  static let itemTagCompleted = "Tag completed successfully."
  static let itemTagCompletedError = "There was a problem completing the tag."
  static let itemTagReset = "Tag reset successfully."
  static let itemTagResetError = "There was a problem resetting the tag."
  static let itemTagAlreadyCompleted = "Tag already completed."
  static let messageWrittenOnTagIsWrong = "The message written on the tag is wrong."
  static let scanServerTag = "This tag is a \"CUSTOMER\" tag. Scan a \"SERVER\" tag!"
  
  static let customerQrCodeImageSavedToPhotoAlbum = "Customer QR code image saved to Photo Album successfully."
  static let customerQrCodeImageSavedToPhotoAlbumError = "There was a problem saving Customer QR code image to Photo Album."
  static let saveToPhotoAlbum = "Save to Photo Album"
  static let generateCustomerQrCode = "Generate Customer QR code"
  
  static let shopkeeperCreated = "Account created successfully."
  static let shopkeeperCreatedError = "There was a problem creating the account."
  static let signedUpButUnconfirmed = "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
  
  static let shopkeeperUpdated = "Account updated successfully."
  static let shopkeeperDeleted = "Account deleted successfully."
  static let shopkeeperDeletedError = "There was a problem deleting the account."
  
  static let confirmedPrivacyVersionUpdated = "Privacy policy accepted successfully."
  static let confirmedPrivacyVersionUpdatedError = "There was a problem accepting the privacy policy."
  
  static let confirmedTermsVersionUpdated = "Terms of use accepted successfully."
  static let confirmedTermsVersionUpdatedError = "There was a problem accepting the terms of use."
  
  static let signedOut = "Signed out successfully."
  static let signedOutError = "There was a problem signing out."
  
  static let passwordUpdated = "Password updated successfully."
  static let passwordUpdatedError = "There was a problem updating the password."
  
  static let sentResetPasswordInstruction = "An email has been sent the email containing instructions for resetting your password."
  static let sentResetPasswordInstructionError = "Unable to find user with the email."
  
  static let sentConfirmationInstruction = "An email has been sent the email containing instructions for confirming your email address."
  static let sentConfirmationInstructionError = "Unable to find user with the email."
  
  static let pleaseSignIn = "Please sign in."
  static let updateApp = "Update App"
  static let installNewVersionApp = "Please install new version app."
  
  // MARK: Onboarding
  static let signIn = "Sign In"
  static let signUp = "Sign Up"
  static let signUpForAnAccount = "Sign Up for an Account"
  static let signInToYourAccount = "Sign In to Your Account"
  static let email = "Email"
  static let password = "Password"
  
  static let onboardingDescription1 = String(localized: "A **Server Tag** and a **Customer Tag** are NFCs.")
  static let onboardingDescription2 = String(localized: "The staff gives the **Customer Tag** to the customer.")
  static let onboardingDescription3 = String(localized: "The customer scans the **Customer Tag** or the **Customer QR code**.")
  static let onboardingDescription4 = String(localized: "The customer can view the **Number Tags Webpage** on his mobile browser.")
  static let onboardingDescription5 = String(localized: "The staff is cooking KILITANPOs.")
  static let onboardingDescription6 = String(localized: "The staff completed cooking KILITANPOs. The staff scans the **Server Tag**.")
  static let onboardingDescription7 = String(localized: "Tag completed with Background Tag Reading.")
  static let onboardingDescription8 = String(localized: "If you do not want to scan, you can complete the tag by swiping the tag(Shops > [Shop]).")
  static let onboardingDescription9 = String(localized: "**Number Tags Webpage** displays the completed number tag.")
  static let onboardingDescription10 = String(localized: "The customer's **Number Tags Webpage** updated.")
  static let onboardingDescription11 = String(localized: "The customer\'s **Number Tags Webpage** displays the completed **Customer Tag**(A07).")
  static let onboardingDescription12 = String(localized: "The customer returns the **Customer Tag**.")
  static let onboardingDescription13 = String(localized: "The customer finally got the delicious KILITANPO!")
  
  // MARK: Other
  static let yes = "Yes"
  static let ok = "OK" // swiftlint:disable:this identifier_name
  static let no = "No" // swiftlint:disable:this identifier_name
  static let cancel = "Cancel"
  static let close = "Close"
  static let save = "Save"
  static let edit = "Edit"
  static let delete = "Delete"
  static let areYouSure = "Are you sure?"
  static let name = "Name"
  static let accept = "Accept"
  static let decline = "Decline"
  static let descriptionString = "Description"
  static let nameIsRequired = "Name is required."
  static let emailIsRequired = "Email is required."
  static let emailIsInvalid = "Email is invalid."
  static let passwordIsRequired = "Password is required."
  static let passwordIsInvalid = "Password is invalid."
  static let role = "Role"
  static let createShops = "Create shops."
  static let createTags = "Create tags."
  static let complete = "Complete"
  static let open = "Open"
  static let learnMore = "Learn More"
  static let instructions = "Instructions"
  static let forceSignOut = "Force Sign Out?"
  static let signOut = "Sign Out"
  static let noConnection = "No Connection"
  static let checkInternetConnection = "Please check internet connection and try again."
  static let privacyPolicyUpdated = "Privacy Policy Updated"
  static let termsOfUseUpdated = "Terms of Use Updated"
  static let backToStartScreen = "Back to Start Screen"
  static let fullName = "Full Name"
  static let fullNameIsRequired = "Full name is required."
  static let reset = "Reset"
  static let unknownNdefStatus = "Unknown NDEF status"
  static let noRecrodsFound = "No recrods found"
  static let thisDeviceDoesNotSupportTagScanning = "This device doesn't support tag scanning."
}

extension TimeInterval {
  // MARK: Message Banner
  static let autoDismissTime: Self = 3
}
