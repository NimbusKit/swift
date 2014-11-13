/*
 Copyright (c) 2011-present, NimbusKit. All rights reserved.

 This source code is licensed under the BSD-style license found at http://nimbuskit.info/license
 */

import Foundation

class ActionableObject : NSObject, Hashable {
  override var hashValue: Int {
    get {
      return self.hashValue
    }
  }
}

func ==(lhs: ActionableObject, rhs: ActionableObject) -> Bool {
  return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

public class TableActions : NSObject {
  var actions: Actions<ActionableObject>

  init(target: AnyObject) {
    self.actions = Actions(target)
  }
}

extension TableActions : UITableViewDelegate {

}

extension TableActions : ActionsInterface {
  func isActionableObject(object: ActionableObject) -> Bool {
    return self.actions.isActionableObject(object)
  }

  func setObject(object: ActionableObject, enabled: Bool) {
    self.actions.setObject(object, enabled: enabled)
  }
  func setClass(theClass: AnyClass, enabled: Bool) {
    self.actions.setClass(theClass, enabled: enabled)
  }

  func attachToObject(object: ActionableObject, tap: Action) -> ActionableObject {
    return self.actions.attachToObject(object, tap: tap)
  }
  func attachToObject(object: ActionableObject, navigate: Action) -> ActionableObject {
    return self.actions.attachToObject(object, navigate: navigate)
  }
  func attachToObject(object: ActionableObject, detail: Action) -> ActionableObject {
    return self.actions.attachToObject(object, detail: detail)
  }
  func attachToObject(object: ActionableObject, tap: Selector) -> ActionableObject {
    return self.actions.attachToObject(object, tap: tap)
  }
  func attachToObject(object: ActionableObject, navigate: Selector) -> ActionableObject {
    return self.actions.attachToObject(object, navigate: navigate)
  }
  func attachToObject(object: ActionableObject, detail: Selector) -> ActionableObject {
    return self.actions.attachToObject(object, detail: detail)
  }

  func attachToClass(theClass: AnyClass, tap: Action) -> AnyClass {
    return self.actions.attachToClass(theClass, tap: tap)
  }
  func attachToClass(theClass: AnyClass, navigate: Action) -> AnyClass {
    return self.actions.attachToClass(theClass, navigate: navigate)
  }
  func attachToClass(theClass: AnyClass, detail: Action) -> AnyClass {
    return self.actions.attachToClass(theClass, detail: detail)
  }
  func attachToClass(theClass: AnyClass, tap: Selector) -> AnyClass {
    return self.actions.attachToClass(theClass, tap: tap)
  }
  func attachToClass(theClass: AnyClass, navigate: Selector) -> AnyClass {
    return self.actions.attachToClass(theClass, navigate: navigate)
  }
  func attachToClass(theClass: AnyClass, detail: Selector) -> AnyClass {
    return self.actions.attachToClass(theClass, detail: detail)
  }

  func removeAllActionsForObject(object: ActionableObject) {
    self.actions.removeAllActionsForObject(object)
  }
  func removeAllActionsForClass(theClass: AnyClass) {
    self.actions.removeAllActionsForClass(theClass)
  }
}
