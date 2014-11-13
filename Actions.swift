/*
 Copyright (c) 2011-present, NimbusKit. All rights reserved.

 This source code is licensed under the BSD-style license found at http://nimbuskit.info/license
 */

public typealias Action = (object: AnyObject, target: AnyObject?, indexPath: NSIndexPath) -> Bool

protocol ActionsInterface {
  typealias ObjectType

  func isActionableObject(object: ObjectType) -> Bool

  mutating func setObject(object: ObjectType, enabled: Bool)
  mutating func setClass(theClass: AnyClass, enabled: Bool)

  mutating func attachToObject(object: ObjectType, tap: Action) -> ObjectType
  mutating func attachToObject(object: ObjectType, navigate: Action) -> ObjectType
  mutating func attachToObject(object: ObjectType, detail: Action) -> ObjectType
  mutating func attachToObject(object: ObjectType, tap: Selector) -> ObjectType
  mutating func attachToObject(object: ObjectType, navigate: Selector) -> ObjectType
  mutating func attachToObject(object: ObjectType, detail: Selector) -> ObjectType

  mutating func attachToClass(theClass: AnyClass, tap: Action) -> AnyClass
  mutating func attachToClass(theClass: AnyClass, navigate: Action) -> AnyClass
  mutating func attachToClass(theClass: AnyClass, detail: Action) -> AnyClass
  mutating func attachToClass(theClass: AnyClass, tap: Selector) -> AnyClass
  mutating func attachToClass(theClass: AnyClass, navigate: Selector) -> AnyClass
  mutating func attachToClass(theClass: AnyClass, detail: Selector) -> AnyClass

  mutating func removeAllActionsForObject(object: ObjectType)
  mutating func removeAllActionsForClass(theClass: AnyClass)
}

struct ObjectActions {
  var tap: Action?
  var navigate: Action?
  var detail: Action?

  var tapSelector: Selector?
  var navigateSelector: Selector?
  var detailSelector: Selector?

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

struct Actions <T where T: AnyObject, T: Hashable> {
  weak var target: AnyObject?
  var objectToAction = Dictionary<Int, ObjectActions>()
  var classToAction = Dictionary<String, ObjectActions>()

  init(_ target: AnyObject) {
    self.target = target
  }
}

extension Actions : ActionsInterface {

  // Querying Actionable State

  func isActionableObject(object: T) -> Bool {
    return self.actionsForObject(object).hasActions()
  }

  // Enabling/Disabling Actions

  mutating func setObject(object: T, enabled: Bool) {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.enabled = enabled
  }

  mutating func setClass(theClass: AnyClass, enabled: Bool) {
    let theClassName = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(theClassName)
    self.classToAction[theClassName]!.enabled = enabled
  }

  // Object Mapping

  mutating func attachToObject(object: T, tap: Action) -> T {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.tap = tap
    return object
  }

  mutating func attachToObject(object: T, navigate: Action) -> T {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.navigate = navigate
    return object
  }

  mutating func attachToObject(object: T, detail: Action) -> T {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.detail = detail
    return object
  }

  mutating func attachToObject(object: T, tap: Selector) -> T {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.tapSelector = tap
    return object
  }

  mutating func attachToObject(object: T, navigate: Selector) -> T {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.navigateSelector = navigate
    return object
  }

  mutating func attachToObject(object: T, detail: Selector) -> T {
    self.ensureActionsExistForObject(object)
    self.objectToAction[object.hashValue]!.detailSelector = detail
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

  mutating func attachToClass(theClass: AnyClass, tap: Selector) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.tapSelector = tap
    return theClass
  }

  mutating func attachToClass(theClass: AnyClass, navigate: Selector) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.navigateSelector = navigate
    return theClass
  }

  mutating func attachToClass(theClass: AnyClass, detail: Selector) -> AnyClass {
    let className = NSStringFromClass(theClass)
    self.ensureActionsExistForClass(className)
    self.classToAction[className]!.detailSelector = detail
    return theClass
  }

  // Removing Actions

  mutating func removeAllActionsForObject(object: T) {
    self.objectToAction[object.hashValue]?.reset()
  }

  mutating func removeAllActionsForClass(theClass: AnyClass) {
    self.classToAction[NSStringFromClass(theClass)]?.reset()
  }
}

// Private
extension Actions {
  func actionsForObject(object: T) -> ObjectActions {
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

  mutating func ensureActionsExistForObject(object: T) {
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
