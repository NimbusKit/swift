/*
 Copyright (c) 2011-present, NimbusKit. All rights reserved.

 This source code is licensed under the BSD-style license found at http://nimbuskit.info/license
 */

import Foundation
import UIKit

public class TableActions : NSObject {
  var actions: Actions<NSObject> = Actions()

  public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forObject object: NSObject, atIndexPath indexPath: NSIndexPath) -> Bool {
    if !self.actions.isActionableObject(object) {
      return false
    }

    cell.accessoryType = self.accessoryTypeForObject(object)
    cell.selectionStyle = self.selectionStyleForObject(object)

    return true
  }

  public func tableView(tableView: UITableView, didSelectObject object: NSObject, atIndexPath indexPath: NSIndexPath) {
    let actions = self.actions.actionsForObject(object)
    if !actions.hasActions() {
      return
    }

    if let shouldDeselect = actions.performTapAction(object, indexPath: indexPath) {
      if shouldDeselect {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
      }
    }

    actions.performNavigateAction(object, indexPath: indexPath)
  }

  public func tableView(tableView: UITableView, accessoryButtonTappedForObject object: NSObject, withIndexPath indexPath: NSIndexPath) {
    let actions = self.actions.actionsForObject(object)
    if !actions.hasActions() {
      return
    }
    actions.performDetailAction(object, indexPath: indexPath)
  }
}

extension TableActions : UITableViewDelegate {
  public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.accessoryType = .None
    cell.selectionStyle = .None

    if let object = self.actionableObjectForTableView(tableView, atIndexPath: indexPath) {
      self.tableView(tableView, willDisplayCell: cell, forObject: object, atIndexPath: indexPath)
    }
  }

  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let object = self.actionableObjectForTableView(tableView, atIndexPath: indexPath) {
      self.tableView(tableView, didSelectObject: object, atIndexPath: indexPath)
    }
  }

  public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
    if let object = self.actionableObjectForTableView(tableView, atIndexPath: indexPath) {
      self.tableView(tableView, accessoryButtonTappedForObject: object, withIndexPath: indexPath)
    }
  }
}

extension TableActions : ActionsInterface {
  public func isActionableObject(object: NSObject) -> Bool {
    return self.actions.isActionableObject(object)
  }

  public func setObject(object: NSObject, enabled: Bool) {
    self.actions.setObject(object, enabled: enabled)
  }
  public func setClass(theClass: AnyClass, enabled: Bool) {
    self.actions.setClass(theClass, enabled: enabled)
  }

  public func attachToObject(object: NSObject, tap: Action) -> NSObject {
    return self.actions.attachToObject(object, tap: tap)
  }
  public func attachToObject(object: NSObject, navigate: Action) -> NSObject {
    return self.actions.attachToObject(object, navigate: navigate)
  }
  public func attachToObject(object: NSObject, detail: Action) -> NSObject {
    return self.actions.attachToObject(object, detail: detail)
  }
  public func attachToObject<T: AnyObject>(object: NSObject, target: T, tap: (T) -> BoolTargetSignature) -> NSObject {
    return self.actions.attachToObject(object, target: target, tap: tap)
  }
  public func attachToObject<T: AnyObject>(object: NSObject, target: T, navigate: (T) -> VoidTargetSignature) -> NSObject {
    return self.actions.attachToObject(object, target: target, navigate: navigate)
  }
  public func attachToObject<T: AnyObject>(object: NSObject, target: T, detail: (T) -> VoidTargetSignature) -> NSObject {
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
  public func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, tap: (T) -> BoolTargetSignature) -> AnyClass {
    return self.actions.attachToClass(theClass, target: target, tap: tap)
  }
  public func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, navigate: (T) -> VoidTargetSignature) -> AnyClass {
    return self.actions.attachToClass(theClass, target: target, navigate: navigate)
  }
  public func attachToClass<T: AnyObject>(theClass: AnyClass, target: T, detail: (T) -> VoidTargetSignature) -> AnyClass {
    return self.actions.attachToClass(theClass, target: target, detail: detail)
  }

  public func removeAllActionsForObject(object: NSObject) {
    self.actions.removeAllActionsForObject(object)
  }
  public func removeAllActionsForClass(theClass: AnyClass) {
    self.actions.removeAllActionsForClass(theClass)
  }
}

// Private
extension TableActions {
  func accessoryTypeForObject(object: NSObject) -> UITableViewCellAccessoryType {
    let actions = self.actions.actionsForObject(object)
    if actions.hasDetailAction() {
      return .DetailDisclosureButton
    } else if actions.hasNavigateAction() {
      return .DisclosureIndicator
    }
    return .None
  }

  func selectionStyleForObject(object: NSObject) -> UITableViewCellSelectionStyle {
    let actions = self.actions.actionsForObject(object)
    if (actions.hasNavigateAction() || actions.hasTapAction()) {
      return .Default
    }
    return .None
  }

  func actionableObjectForTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> NSObject? {
    if let model = tableView.dataSource as? TableModel {
      if let object = model.objectAtPath(indexPath) as? NSObject {
        return object
      }
    }
    return nil
  }
}
