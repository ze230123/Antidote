//
//  SettingsTabCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SafariServices

private struct Options {
    static let ToShowKey = "ToShowKey"

    enum Controller {
        case AdvancedSettings
    }
}

private struct Constants {
    static let FAQURL = "https://github.com/Antidote-for-Tox/Antidote/blob/FAQ/en.md"
}

protocol SettingsTabCoordinatorDelegate: class {
    func settingsTabCoordinatorRecreateCoordinatorsStack(coordinator: SettingsTabCoordinator, options: CoordinatorOptions)
}

class SettingsTabCoordinator: ActiveSessionNavigationCoordinator {
    weak var delegate: SettingsTabCoordinatorDelegate?

    override func startWithOptions(options: CoordinatorOptions?) {
        let controller = SettingsMainController(theme: theme)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: false)

        if let toShow = options?[Options.ToShowKey] as? Options.Controller {
            switch toShow {
                case .AdvancedSettings:
                    let advanced = SettingsAdvancedController(theme: theme)
                    advanced.delegate = self

                    navigationController.pushViewController(advanced, animated: false)
            }
        }
    }
}

extension SettingsTabCoordinator: SettingsMainControllerDelegate {
    func settingsMainControllerShowAboutScreen(controller: SettingsMainController) {
        let controller = SettingsAboutController(theme: theme)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: true)
    }

    func settingsMainControllerShowFaqScreen(controller: SettingsMainController) {
        let url = NSURL(string: Constants.FAQURL)!

        if #available(iOS 9.0, *) {
            let controller = SFSafariViewController(URL: url)
            controller.title = String(localized: "settings_faq")
            controller.hidesBottomBarWhenPushed = true

            navigationController.presentViewController(controller, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    func settingsMainControllerChangeAutodownloadImages(controller: SettingsMainController) {
        let controller = ChangeAutodownloadImagesController(theme: theme)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: true)
    }

    func settingsMainControllerShowAdvancedSettings(controller: SettingsMainController) {
        let controller = SettingsAdvancedController(theme: theme)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: true)
    }
}

extension SettingsTabCoordinator: SettingsAboutControllerDelegate {
    func settingsAboutControllerShowAcknowledgements(controller: SettingsAboutController) {
        let controller = TextViewController(
                resourceName: "antidote-acknowledgements",
                backgroundColor: theme.colorForType(.NormalBackground),
                titleColor: theme.colorForType(.NormalText),
                textColor: theme.colorForType(.NormalText))
        controller.title = String(localized: "settings_acknowledgements")

        navigationController.pushViewController(controller, animated: true)
    }
}

extension SettingsTabCoordinator: ChangeAutodownloadImagesControllerDelegate {
    func changeAutodownloadImagesControllerDidChange(controller: ChangeAutodownloadImagesController) {
        navigationController.popViewControllerAnimated(true)
    }
}

extension SettingsTabCoordinator: SettingsAdvancedControllerDelegate {
    func settingsAdvancedControllerToxOptionsChanged(controller: SettingsAdvancedController) {
        delegate?.settingsTabCoordinatorRecreateCoordinatorsStack(self, options: [
            Options.ToShowKey: Options.Controller.AdvancedSettings
        ])
    }
}
