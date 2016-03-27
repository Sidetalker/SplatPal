// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation
import UIKit

protocol StoryboardSceneType {
  static var storyboardName: String { get }
}

extension StoryboardSceneType {
  static func storyboard() -> UIStoryboard {
    return UIStoryboard(name: self.storyboardName, bundle: nil)
  }

  static func initialViewController() -> UIViewController {
    return storyboard().instantiateInitialViewController()!
  }
}

extension StoryboardSceneType where Self: RawRepresentable, Self.RawValue == String {
  func viewController() -> UIViewController {
    return Self.storyboard().instantiateViewControllerWithIdentifier(self.rawValue)
  }
  static func viewController(identifier: Self) -> UIViewController {
    return identifier.viewController()
  }
}

protocol StoryboardSegueType: RawRepresentable { }

extension UIViewController {
  func performSegue<S: StoryboardSegueType where S.RawValue == String>(segue: S, sender: AnyObject? = nil) {
    performSegueWithIdentifier(segue.rawValue, sender: sender)
  }
}

struct StoryboardScene {
  enum LaunchScreen: StoryboardSceneType {
    static let storyboardName = "LaunchScreen"
  }
  enum Main: String, StoryboardSceneType {
    static let storyboardName = "Main"

    case GearTVCScene = "gearTVC"
    static func instantiateGearTVC() -> GearTableViewController {
      return StoryboardScene.Main.GearTVCScene.viewController() as! GearTableViewController
    }

    case LoadoutEditGearTVCScene = "loadoutEditGearTVC"
    static func instantiateLoadoutEditGearTVC() -> LoadoutEditGearViewController {
      return StoryboardScene.Main.LoadoutEditGearTVCScene.viewController() as! LoadoutEditGearViewController
    }

    case LoadoutEditWeaponTVCScene = "loadoutEditWeaponTVC"
    static func instantiateLoadoutEditWeaponTVC() -> LoadoutEditWeaponViewController {
      return StoryboardScene.Main.LoadoutEditWeaponTVCScene.viewController() as! LoadoutEditWeaponViewController
    }

    case LoadoutGearTVCScene = "loadoutGearTVC"
    static func instantiateLoadoutGearTVC() -> LoadoutGearViewController {
      return StoryboardScene.Main.LoadoutGearTVCScene.viewController() as! LoadoutGearViewController
    }

    case LoadoutReviewTVCScene = "loadoutReviewTVC"
    static func instantiateLoadoutReviewTVC() -> LoadoutReviewController {
      return StoryboardScene.Main.LoadoutReviewTVCScene.viewController() as! LoadoutReviewController
    }

    case ReviewNotificationScene = "reviewNotification"
    static func instantiateReviewNotification() -> ReviewNotificationTableViewController {
      return StoryboardScene.Main.ReviewNotificationScene.viewController() as! ReviewNotificationTableViewController
    }
  }
  enum Matches: String, StoryboardSceneType {
    static let storyboardName = "Matches"

    case KdrScene = "kdr"
    static func instantiateKdr() -> SplatKDRViewController {
      return StoryboardScene.Matches.KdrScene.viewController() as! SplatKDRViewController
    }

    case MainScene = "main"
    static func instantiateMain() -> SplatTrackMainViewController {
      return StoryboardScene.Matches.MainScene.viewController() as! SplatTrackMainViewController
    }
  }
}

struct StoryboardSegue {
  enum Main: String, StoryboardSegueType {
    case EmbedLoadout = "embedLoadout"
    case SegueAddLoadout = "segueAddLoadout"
    case SegueBrandTable = "segueBrandTable"
    case SegueConfigureNotifications = "segueConfigureNotifications"
    case SegueGearTable = "segueGearTable"
    case SegueNewNotification = "segueNewNotification"
    case SegueReviewNotification = "segueReviewNotification"
    case SegueSelectMaps = "segueSelectMaps"
    case SegueSelectTimes = "segueSelectTimes"
  }
}
