//
//  VersionFlow.swift
//  TestingFlow
//
//  Created by Alexander Cyon on 2018-02-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import UIKit
import RxFlow

final class VersionFlow: Flow, Stepper {
    
    private let navigationController = UINavigationController()
    private let service: AppConfigService
    
    init(service: AppConfigService) {
        self.service = service
        step(to: .versionStart)
    }
    
    
    deinit {
        print("❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️ VERSION flow DEINIT ❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️")
    }
}

extension VersionFlow {
    var root: Presentable { return navigationController }
    
    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .version(.start): return navigate(to: AppStep.version(.forceUpdate))
        case .version(.forceUpdate): return navigateToMockForceUpdateScreen()
        case .version(.forceUpdateBlock): return navigateToForceUpdateBlockingScreen()
        case .version(.onboarding): return navigateToOnboardingScreen()
        case .version(.onboardingDone): return .end(withStepForParentFlow: AppStep.version(.done))
        default: return .none
        }
    }
}

private extension VersionFlow {
    func navigateToMockForceUpdateScreen() -> NextFlowItems {
        let viewModel = MockForceUpdateViewModel(service: service)
        let viewController = MockForceUpdateViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        return .one(flowItem: NextFlowItem(nextPresentable: viewController, nextStepper: viewModel))
    }
    
    func navigateToForceUpdateBlockingScreen() -> NextFlowItems {
        let viewModel = MockForceUpdateViewModel(service: service)
        let viewController = ForceUpdateViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        return .one(flowItem: NextFlowItem(nextPresentable: viewController, nextStepper: viewModel))
    }
    
    func navigateToOnboardingScreen() -> NextFlowItems {
        let viewModel = OnboardingViewModel()
        let viewController = OnboardingViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        return .one(flowItem: NextFlowItem(nextPresentable: viewController, nextStepper: viewModel))
    }
}

