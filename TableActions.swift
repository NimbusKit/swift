/*
 Copyright (c) 2011-present, NimbusKit. All rights reserved.

 This source code is licensed under the BSD-style license found at http://nimbuskit.info/license
 */

import Foundation
import UIKit

public class ActionableObject : NSObject, Hashable {
}

public func ==(lhs: ActionableObject, rhs: ActionableObject) -> Bool {
  return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

public class TableActions : NSObject, UITableViewDelegate {
  var actions: Actions<ActionableObject> = Actions()

  public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forObject object: ActionableObject, atIndexPath indexPath: NSIndexPath) -> Bool {
    if !self.actions.isActionableObject(object) {
      return false
    }

    cell.accessoryType = .DisclosureIndicator
    cell.selectionStyle = .Default
    return true
  }

  @objc(tableView:didSelectObject:atIndexPath:)
  public func tableView(tableView: UITableView, didSelectObject object: ActionableObject, atIndexPath indexPath: NSIndexPath) {
    let actions = self.actions.actionsForObject(object)
    actions.tapSelector?.performAction()
  }

  public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.accessoryType = .None
    cell.selectionStyle = .None

    if let actionableObject = self.actionableObjectForTableView(tableView, atIndexPath: indexPath) {
      self.tableView(tableView, willDisplayCell: cell, forObject: actionableObject, atIndexPath: indexPath)
    }
  }

  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let actionableObject = self.actionableObjectForTableView(tableView, atIndexPath: indexPath) {
      self.tableView(tableView, didSelectObject: actionableObject, atIndexPath: indexPath)
    }
  }
}

extension TableActions : ActionsInterface {
  public func isActionableObject(object: ActionableObject) -> Bool {
    return self.actions.isActionableObject(object)
  }

  public func setObject(object: ActionableObject, enabled: Bool) {
    self.actions.setObject(object, enabled: enabled)
  }
  public func setClass(theClass: AnyClass, enabled: Bool) {
    self.actions.setClass(theClass, enabled: enabled)
  }

  public func attachToObject(object: ActionableObject, tap: Action) -> ActionableObject {
    return self.actions.attachToObject(object, tap: tap)
  }
  public func attachToObject(object: ActionableObject, navigate: Action) -> ActionableObject {
    return self.actions.attachToObject(object, navigate: navigate)
  }
  public func attachToObject(object: ActionableObject, detail: Action) -> ActionableObject {
    return self.actions.attachToObject(object, detail: detail)
  }
  public func attachToObject<T: AnyObject>(object: ActionableObject, target: T, tap: (T) -> () -> Bool) -> ActionableObject {
    return self.actions.attachToObject(object, target: target, tap: tap)
  }
  public func attachToObject<T: AnyObject>(object: ActionableObject, target: T, navigate: (T) -> () -> ()) -> ActionableObject {
    return self.actions.attachToObject(object, target: target, navigate: navigate)
  }
  public func attachToObject<T: AnyObject>(object: ActionableObject, target: T, detail: (T) -> () -> ()) -> ActionableObject {
    return self.actions.attachToObject(object, target: target, detail: detail)
  }

  public func attachToClass(theClass: AnyClass, tap: Action) -> AnyClass {
    return self.actions.attachToClass(theClass, tap: tap)
  }
  public func attachToClass(theClass: AnyClass, navigate: Action) -> AnyClass {
    return self.actions.attachToClass(theClass, navigate: navigate)
  }
  public func attachToClass(theClass: AnyClass, detail: Action) -> AnyClass {
    return self.actions.attachToClass(theClass, detail: detail)
  }
  public func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, tap: (T) -> () -> Bool) -> AnyClass {
    return self.actions.attachToClass(theClass, target: target, tap: tap)
  }
  public func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, navigate: (T) -> () -> ()) -> AnyClass {
    return self.actions.attachToClass(theClass, target: target, navigate: navigate)
  }
  public func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, detail: (T) -> () -> ()) -> AnyClass {
    return self.actions.attachToClass(theClass, target: target, detail: detail)
  }

  public func removeAllActionsForObject(object: ActionableObject) {
    self.actions.removeAllActionsForObject(object)
  }
  public func removeAllActionsForClass(theClass: AnyClass) {
    self.actions.removeAllActionsForClass(theClass)
  }
}

// Private
extension TableActions {
  func actionableObjectForTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> ActionableObject? {
    if let model = tableView.dataSource as? TableModel {
      if let actionableObject = model.objectAtPath(indexPath) as? ActionableObject {
        return actionableObject
      }
    }
    return nil
  }
}
