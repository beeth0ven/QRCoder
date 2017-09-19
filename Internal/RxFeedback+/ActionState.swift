//
//  ActionState.swift
//  Internal
//
//  Created by luojie on 2017/9/18.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFeedback

public enum ActionState<Input, Output> {
    case empty
    case triggered(Input)
    case success(Output)
    case error(Swift.Error)
    
    public enum Event {
        case trigger(Input)
        case result(Result<Output>)
    }
    
    public typealias State = ActionState<Input, Output>
    public typealias Feedback = (ObservableSchedulerContext<State>) -> Observable<Event>

    private static func reduce(_ state: State, event: Event) -> State {
        switch event {
        case .trigger(let input):
            return .triggered(input)
        case .result(.success(let output)):
            return .success(output)
        case .result(.failure(let error)):
            return .error(error)
        }
    }
    
    public static func system(
        inputs: Observable<Input>,
        workFactory: @escaping (Input) -> Observable<Output>,
        scheduler: ImmediateSchedulerType = MainScheduler.asyncInstance
        ) -> Observable<State> {
        
        let trigger: Feedback = { state in
            state.flatMapLatest { state -> Observable<Event> in
                if state.executing {
                    return .empty()
                }
                return inputs.map(Event.trigger)
            }
        }
        
        let reactInput: Feedback = react(query: { $0.input }, effects: { input in
            workFactory(input)
                .mapToResult()
                .map(Event.result)
        })
        
        return Observable.system(
            initialState: State.empty,
            reduce: State.reduce,
            scheduler: scheduler,
            scheduledFeedback:
                trigger,
                reactInput
        )
        
    }
}

extension ActionState {
    
    public var executing: Bool {
        switch self {
        case .triggered:
            return true
        default:
            return false
        }
    }
    
    public var input: Input? {
        switch self {
        case .triggered(let input):
            return input
        default:
            return nil
        }
    }
}
