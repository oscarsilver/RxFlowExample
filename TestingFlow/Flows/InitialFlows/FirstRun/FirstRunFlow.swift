//
//  FirstRunFlow.swift
//  TestingFlow
//
//  Created by Alexander Cyon on 2018-02-05.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import UIKit
import RxFlow

final class FirstRunFlow: Flow {
    
    private let navigationController = UINavigationController()
    private let authService: AuthService
    
    init(service: AuthService) {
        self.authService = service
    }
    
    deinit {
        print("❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️ FirstRun flow DEINIT ❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️")
    }
}

extension FirstRunFlow {
    var root: Presentable { return navigationController }
    
    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .first(.start): return navigate(to: AppStep.first(.applePay))
        case .first(.applePay): return navigateToApplePaySplashScreen()
        case .first(.applePayDone): return navigate(to: AppStep.first(.permissions))
        case .first(.permissions): return navigateToPermissionsScreen()
        case .first(.permissionsDone): return .end(withStepForParentFlow: AppStep.first(.done))
        default: return .none
        }
    }
}

private extension FirstRunFlow {
    
    func navigateToApplePaySplashScreen() -> NextFlowItems {
        let viewModel = ApplePaySpashViewModel()
        let viewController = ApplePaySplashViewController(viewModel: viewModel)
        Flows.whenReady(flow1: self, block: { [weak self] _ in self?.navigationController.viewControllers = [viewController] })
        return .one(flowItem: NextFlowItem(nextPresentable: viewController, nextStepper: viewModel))
    }
    
    func navigateToPermissionsScreen() -> NextFlowItems {
        let viewModel = PermissionsViewModel()
        let viewController = PermissionsViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        return .one(flowItem: NextFlowItem(nextPresentable: viewController, nextStepper: viewModel))
    }

}

