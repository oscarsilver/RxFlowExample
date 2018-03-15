//
//  AppFlow.swift
//  TestingFlow
//
//  Created by Alexander Cyon on 2018-02-01.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import UIKit
import RxFlow
import Swinject
import SwinjectAutoregistration

final class AppFlow: Flow {
    private let container: Container
    private lazy var authService = container ~> AuthService.self
    private lazy var appConfigService = container ~> AppConfigService.self

    private weak var window: UIWindow?
    
    init(container parent: Container, window: UIWindow) {
        self.window = window
        container = makeContainer(parent: parent)
    }
    
    deinit {
        print("❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️ APPFLOW DEINIT ❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️")
    }
}

private func makeContainer(parent: Container) -> Container {
    return Container(parent: parent) { c in
        c.autoregister(AuthService.self, initializer: AuthService.init).inObjectScope(.container)
        c.autoregister(AppConfigService.self, initializer: AppConfigService.init).inObjectScope(.container)
    }
}

extension AppFlow {
    var rootWindow: UIWindow {
        guard let window = window else { fatalError("No window..") }
        return window
    }

    var root: Presentable { return rootWindow }
    
    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .start: return navigate(to: initialStep)
            
        case .first(.start): return startFirstRunFlow()
        case .first(.done): return navigate(to: AppStep.versionStart)
            
        case .version(.start): return startVersionFlow()
        case .version(.done): return navigate(to: AppStep.authStart)
        case .auth(.start): return startAuthFlow()
        case .auth(.done): return navigate(to: AppStep.mainStart)
            
        case .main(.start): return startMainFlow()
        default: return .none
        }
    }
}

extension NextFlowItem {
    init<N>(_ next: N) where N: Presentable & Stepper {
        self.init(nextPresentable: next, nextStepper: next)
    }
}

private extension AppFlow {
    var initialStep: Step {
        guard !isFirstRun else { return AppStep.firstStart }
        let step: AppStep = isLoggedIn ? .mainStart : .authStart
        return step
    }
    var isLoggedIn: Bool { return false }
    var isFirstRun: Bool { return true }
    
    func startFirstRunFlow() -> NextFlowItems {
        print("💜💜💜💜💜 Start First Flow")
        let firstRunFlow = FirstRunFlow(service: authService)
        return startTemporaryFlow(firstRunFlow, initialStep: .firstStart)
    }
    
    func startVersionFlow() -> NextFlowItems {
        print("💚💚💚💚💚💚 Start Version Flow")
        let flow = VersionFlow(service: appConfigService)
        return startTemporaryFlow(flow, initialStep: .versionStart)
    }
    
    func startAuthFlow() -> NextFlowItems {
        print("💙💙💙💙💙💙 Start Auth Flow")
        let flow = AuthFlow(service: authService)
        return startTemporaryFlow(flow, initialStep: .authStart)
    }
    
    func startMainFlow() -> NextFlowItems {
        print("💛💛💛💛💛 STARTING APP 💛")
        
        let tabbarController = UITabBarController()
        let myStaysFlow = MyStaysFlow(bookingService: BookingService())
        let myPageFlow = MyPageFlow(authService: authService)
        Flows.whenReady(flow1: myStaysFlow, flow2: myPageFlow, block: { [unowned self] (tab1Root: UINavigationController, tab2Root: UINavigationController) in
            let tabBarItem1 = UITabBarItem(title: "My stays", image: nil, selectedImage: nil)
            let tabBarItem2 = UITabBarItem(title: "Profile", image: nil, selectedImage: nil)
            tab1Root.tabBarItem = tabBarItem1
            tab2Root.tabBarItem = tabBarItem2
            
            tabbarController.setViewControllers([tab1Root, tab2Root], animated: false)
            self.window?.rootViewController = tabbarController
        })
        
        return .multiple(flowItems: [
            NextFlowItem(nextPresentable: myStaysFlow, nextStepper: myStaysFlow),
            NextFlowItem(nextPresentable: myPageFlow, nextStepper: myPageFlow)
            ])
    }
}

private extension AppFlow {

    func startTemporaryFlow<TemporaryFlow>(_ flow: TemporaryFlow, initialStep: AppStep) -> NextFlowItems where TemporaryFlow: Flow {
        Flows.whenReady(flow1: flow) { [unowned self] (root) in
            self.rootWindow.rootViewController = root
        }
        return .one(flowItem: NextFlowItem(nextPresentable: flow, nextStepper: OneStepper(withSingleStep: initialStep)))
    }
}

final class AppStepper: Stepper {
    private let container: Container
    init(container: Container) {
        self.container = container
        step(to: AppStep.firstStart)
    }
}
