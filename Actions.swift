/*
 Copyright (c) 2011-present, NimbusKit. All rights reserved.

 This source code is licensed under the BSD-style license found at http://nimbuskit.info/license
 */

import Foundation

public typealias Action = (object: AnyObject, indexPath: NSIndexPath) -> Bool
public typealias BoolTargetSignature = (object: NSObject, indexPath: NSIndexPath) -> Bool
public typealias VoidTargetSignature = (object: NSObject, indexPath: NSIndexPath) -> ()

protocol TargetAction {
  func performAction(object: NSObject, indexPath: NSIndexPath) -> Bool?
}

private struct BoolObjectAction <T: AnyObject> : TargetAction {
  weak var target: T?
  let action: (T) -> BoolTargetSignature

  func performAction(object: NSObject, indexPath: NSIndexPath) -> Bool? {
    if let t = target {
      return action(t)(object: object, indexPath: indexPath)
    }
    return nil
  }
}

private struct VoidObjectAction <T: AnyObject> : TargetAction {
  weak var target: T?
  let action: (T) -> VoidTargetSignature

  func performAction(object: NSObject, indexPath: NSIndexPath) -> Bool? {
    if let t = target {
      action(t)(object: object, indexPath: indexPath)
    }
    return nil
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
    return (hasTapAction() || hasNavigateAction() || hasDetailAction())
  }

  func hasTapAction() -> Bool {
    return (tap != nil || tapSelector != nil)
  }

  func hasNavigateAction() -> Bool {
    return (navigate != nil || navigateSelector != nil)
  }

  func hasDetailAction() -> Bool {
    return (detail != nil || detailSelector != nil)
  }

  func performTapAction(object: NSObject, indexPath: NSIndexPath) -> Bool? {
    if !hasTapAction() {
      return nil
    }
    var shouldDeselect = false
    if let tap = tap {
      shouldDeselect |= tap(object: object, indexPath: indexPath)
    }
    if let tapSelector = tapSelector {
      shouldDeselect |= tapSelector.performAction(object, indexPath: indexPath)!
    }
    return shouldDeselect
  }

  func performNavigateAction(object: NSObject, indexPath: NSIndexPath) {
    navigate?(object: object, indexPath: indexPath)
    navigateSelector?.performAction(object, indexPath: indexPath)
  }

  func performDetailAction(object: NSObject, indexPath: NSIndexPath) {
    detail?(object: object, indexPath: indexPath)
    detailSelector?.performAction(object, indexPath: indexPath)
  }

  mutating func unionWith(otherActions: ObjectActions?) {
    if nil == otherActions {
      return
    }
    if (tap == nil && otherActions!.tap != nil) {
      tap = otherActions!.tap
    }
    if (navigate == nil && otherActions!.navigate != nil) {
      navigate = otherActions!.navigate
    }
    if (detail == nil && otherActions!.detail != nil) {
      detail = otherActions!.detail
    }
    if (tapSelector == nil && otherActions!.tapSelector != nil) {
      tapSelector = otherActions!.tapSelector
    }
    if (navigateSelector == nil && otherActions!.navigateSelector != nil) {
      navigateSelector = otherActions!.navigateSelector
    }
    if (detailSelector == nil && otherActions!.detailSelector != nil) {
      detailSelector = otherActions!.detailSelector
    }
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

public class Actions : NSObject {
  var objectToAction = Dictionary<Int, ObjectActions>()
  var classToAction = Dictionary<String, ObjectActions>()
}

extension Actions {

  // Querying Actionable State

  public func isActionableObject<O where O: AnyObject, O: Hashable>(object: O) -> Bool {
    return self.actionsForObject(object).hasActions()
  }

  // Enabling/Disabling Actions

  public func setObject<O where O: AnyObject, O: Hashable>(object: O, enabled: Bool) {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.enabled = enabled
  }

  public func setClass(theClass: AnyClass, enabled: Bool) {
    let theClassName = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(theClassName)
    self.classToAction[theClassName]!.enabled = enabled
  }

  // Object Mapping

  public func attachToObject<O where O: AnyObject, O: Hashable>(object: O, tap: Action) -> O {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.tap = tap
    return object
  }

  public func attachToObject<O where O: AnyObject, O: Hashable>(object: O, navigate: Action) -> O {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.navigate = navigate
    return object
  }

  public func attachToObject<O where O: AnyObject, O: Hashable>(object: O, detail: Action) -> O {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.detail = detail
    return object
  }

  public func attachToObject<O, T where O: AnyObject, O: Hashable, T: AnyObject>(object: O, target: T, tap: (T) -> BoolTargetSignature) -> O {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.tapSelector = BoolObjectAction(target: target, action: tap)
    return object
  }

  public func attachToObject<O, T where O: AnyObject, O: Hashable, T: AnyObject>(object: O, target: T, navigate: (T) -> VoidTargetSignature) -> O {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.navigateSelector = VoidObjectAction(target: target, action: navigate)
    return object
  }

  public func attachToObject<O, T where O: AnyObject, O: Hashable, T: AnyObject>(object: O, target: T, detail: (T) -> VoidTargetSignature) -> O {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.detailSelector = VoidObjectAction(target: target, action: detail)
    return object
  }

  // Class Mapping

  public func attachToClass(theClass: AnyClass, tap: Action) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.tap = tap
    return theClass
  }

  public func attachToClass(theClass: AnyClass, navigate: Action) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.navigate = navigate
    return theClass
  }

  public func attachToClass(theClass: AnyClass, detail: Action) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.detail = detail
    return theClass
  }

  public func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, tap: (T) -> BoolTargetSignature) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.tapSelector = BoolObjectAction(target: target, action: tap)
    return theClass
  }

  public func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, navigate: (T) -> VoidTargetSignature) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.navigateSelector = VoidObjectAction(target: target, action: navigate)
    return theClass
  }

  public func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, detail: (T) -> VoidTargetSignature) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.detailSelector = VoidObjectAction(target: target, action: detail)
    return theClass
  }

  // Removing Actions

  public func removeAllActionsForObject<O where O: AnyObject, O: Hashable>(object: O) {
    self.objectToAction[object.hashValue]?.reset()
  }

  public func removeAllActionsForClass(theClass: AnyClass) {
    self.classToAction[NSStringFromClass(theClass)]?.reset()
  }
}

// Internal
extension Actions {
  /**
  Returns all attached actions for a given object.
  
  "Attached actions" are:

  1) actions attached to the provided object, and
  2) actions attached to classes in the object's class ancestry.
  
  Priority is as follows:
  
  1) Object actions
  2) Object.class actions
  3) Object.superclass.class actions
  4) etc... up the class ancestry

  ## Example

  Consider the following class hierarchy:

      NSObject -> Widget (tap) -> DetailWidget (detail)

  The actions for an instance of DetailWidget are Widget's tap and DetailWidget's detail actions.

  Attaching a tap action to the DetailWidget instance would override the Widget tap action.
  */
  func actionsForObject<O where O: AnyObject, O: Hashable>(object: O) -> ObjectActions {
    var actions = ObjectActions()
    actions.unionWith(self.objectToAction[object.hashValue])

    var objectClass: AnyClass! = object.dynamicType
    while objectClass != nil {
      actions.unionWith(self.classToAction[NSStringFromClass(objectClass)])
      objectClass = objectClass.superclass()
    }

    return actions
  }
}

// Private
extension Actions {
  private func ensureActionsExistForObject<O where O: AnyObject, O: Hashable>(object: O) {
    if self.objectToAction[object.hashValue] == nil {
      self.objectToAction[object.hashValue] = ObjectActions()
    }
  }

  private func ensureActionsExistForClass(theClass: String) {
    if self.classToAction[theClass] == nil {
      self.classToAction[theClass] = ObjectActions()
    }
  }
}
