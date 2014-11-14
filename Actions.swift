/*
 Copyright (c) 2011-present, NimbusKit. All rights reserved.

 This source code is licensed under the BSD-style license found at http://nimbuskit.info/license
 */

import Foundation

public typealias Action = (object: AnyObject, target: AnyObject?, indexPath: NSIndexPath) -> Bool

protocol ActionsInterface {
  typealias O

  func isActionableObject(object: O) -> Bool

  mutating func setObject(object: O, enabled: Bool)
  mutating func setClass(theClass: AnyClass, enabled: Bool)

  mutating func attachToObject(object: O, tap: Action) -> O
  mutating func attachToObject(object: O, navigate: Action) -> O
  mutating func attachToObject(object: O, detail: Action) -> O
  mutating func attachToObject<T: AnyObject>(object: O, target: T, tap: (T) -> () -> Bool) -> O
  mutating func attachToObject<T: AnyObject>(object: O, target: T, navigate: (T) -> () -> ()) -> O
  mutating func attachToObject<T: AnyObject>(object: O, target: T, detail: (T) -> () -> ()) -> O

  mutating func attachToClass(theClass: AnyClass, tap: Action) -> AnyClass
  mutating func attachToClass(theClass: AnyClass, navigate: Action) -> AnyClass
  mutating func attachToClass(theClass: AnyClass, detail: Action) -> AnyClass
  mutating func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, tap: (T) -> () -> Bool) -> AnyClass
  mutating func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, navigate: (T) -> () -> ()) -> AnyClass
  mutating func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, detail: (T) -> () -> ()) -> AnyClass

  mutating func removeAllActionsForObject(object: O)
  mutating func removeAllActionsForClass(theClass: AnyClass)
}

protocol TargetAction {
  func performAction()
}

struct BoolObjectAction <T: AnyObject> : TargetAction {
  weak var target: T?
  let action: (T) -> () -> Bool

  func performAction() {
    if let t = target {
      action(t)()
    }
  }
}

struct VoidObjectAction <T: AnyObject> : TargetAction {
  weak var target: T?
  let action: (T) -> () -> ()

  func performAction() {
    if let t = target {
      action(t)()
    }
  }
}

struct ObjectActions {
  var tap: Action?
  var navigate: Action?
  var detail: Action?

  var tapSelector: TargetAction?
  var navigateSelector: TargetAction?
  var detailSelector: TargetAction?

  var enabled: Bool = true

  init() {}

  func hasActions() -> Bool {
    return (tap != nil) || (navigate != nil) || (detail != nil) || (tapSelector != nil) || (navigateSelector != nil) || (detailSelector != nil)
  }

  mutating func reset() {
    self.tap = nil
    self.navigate = nil
    self.detail = nil
    self.tapSelector = nil
    self.navigateSelector = nil
    self.detailSelector = nil
  }
}

struct Actions <O where O: AnyObject, O: Hashable> {
  var objectToAction = Dictionary<Int, ObjectActions>()
  var classToAction = Dictionary<String, ObjectActions>()
}

extension Actions : ActionsInterface {

  // Querying Actionable State

  func isActionableObject(object: O) -> Bool {
    return self.actionsForObject(object).hasActions()
  }

  // Enabling/Disabling Actions

  mutating func setObject(object: O, enabled: Bool) {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.enabled = enabled
  }

  mutating func setClass(theClass: AnyClass, enabled: Bool) {
    let theClassName = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(theClassName)
    self.classToAction[theClassName]!.enabled = enabled
  }

  // Object Mapping

  mutating func attachToObject(object: O, tap: Action) -> O {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.tap = tap
    return object
  }

  mutating func attachToObject(object: O, navigate: Action) -> O {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.navigate = navigate
    return object
  }

  mutating func attachToObject(object: O, detail: Action) -> O {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.detail = detail
    return object
  }

  mutating func attachToObject<T: AnyObject>(object: O, target: T, tap: (T) -> () -> Bool) -> O {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.tapSelector = BoolObjectAction(target: target, action: tap)
    return object
  }

  mutating func attachToObject<T: AnyObject>(object: O, target: T, navigate: (T) -> () -> ()) -> O {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.navigateSelector = VoidObjectAction(target: target, action: navigate)
    return object
  }

  mutating func attachToObject<T: AnyObject>(object: O, target: T, detail: (T) -> () -> ()) -> O {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.detailSelector = VoidObjectAction(target: target, action: detail)
    return object
  }

  // Class Mapping

  mutating func attachToClass(theClass: AnyClass, tap: Action) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.tap = tap
    return theClass
  }

  mutating func attachToClass(theClass: AnyClass, navigate: Action) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.navigate = navigate
    return theClass
  }

  mutating func attachToClass(theClass: AnyClass, detail: Action) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.detail = detail
    return theClass
  }

  mutating func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, tap: (T) -> () -> Bool) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.tapSelector = BoolObjectAction(target: target, action: tap)
    return theClass
  }

  mutating func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, navigate: (T) -> () -> ()) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.navigateSelector = VoidObjectAction(target: target, action: navigate)
    return theClass
  }

  mutating func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, detail: (T) -> () -> ()) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.detailSelector = VoidObjectAction(target: target, action: detail)
    return theClass
  }

  // Removing Actions

  mutating func removeAllActionsForObject(object: O) {
    self.objectToAction[object.hashValue]?.reset()
  }

  mutating func removeAllActionsForClass(theClass: AnyClass) {
    self.classToAction[NSStringFromClass(theClass)]?.reset()
  }
}

// Private
extension Actions {
  func actionsForObject(object: O) -> ObjectActions {
    var actions = self.objectToAction[object.hashValue]
    if actions != nil && actions!.hasActions() {
      return actions!
    }

    // If not, see if its class is actionable

    let objectClass: AnyClass! = object.dynamicType
    let objectClassName = NSStringFromClass(objectClass)
    actions = self.classToAction[objectClassName]
    if actions != nil {
      return actions!
    }

    // If not, see if any parent class to this object's class is actionable

    var superClass: AnyClass?

    // PERF: This is a linear lookup. In practice it's unlikely that this will be the biggest perf
    //       bottleneck compared to cell rendering.
    for (className, actions) in self.classToAction {
      let theClass: AnyClass! = NSClassFromString(className)
      if objectClass.isSubclassOfClass(theClass) && (superClass == nil || theClass.isSubclassOfClass(superClass!)) {
        superClass = theClass
      }
    }

    // Did we find a superclass of this object?

    if superClass != nil {
      // We did, use superclass's actions
      actions = self.classToAction[NSStringFromClass(superClass)]

    } else {
      // No class or superclass found, let's just create a dummy object then
      actions = ObjectActions()
    }
    
    return actions!
  }

  mutating func ensureActionsExistForObject(object: O) {
    if self.objectToAction[object.hashValue] == nil {
      self.objectToAction[object.hashValue] = ObjectActions()
    }
  }

  mutating func ensureActionsExistForClass(theClass: String) {
    if self.classToAction[theClass] == nil {
      self.classToAction[theClass] = ObjectActions()
    }
  }
}
