/*
 Copyright (c) 2011-present, NimbusKit. All rights reserved.

 This source code is licensed under the BSD-style license found at http://nimbuskit.info/license
 */

import Foundation
import UIKit

extension Actions {
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forObject object: NSObject, atIndexPath indexPath: NSIndexPath) -> Bool {
    if !self.isActionableObject(object) {
      return false
    }

    cell.accessoryType = self.accessoryTypeForObject(object)
    cell.selectionStyle = self.selectionStyleForObject(object)

    return true
  }

  func tableView(tableView: UITableView, didSelectObject object: NSObject, atIndexPath indexPath: NSIndexPath) {
    let actions = self.actionsForObject(object)
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

  func tableView(tableView: UITableView, accessoryButtonTappedForObject object: NSObject, withIndexPath indexPath: NSIndexPath) {
    let actions = self.actionsForObject(object)
    if !actions.hasActions() {
      return
    }
    actions.performDetailAction(object, indexPath: indexPath)
  }
}

extension Actions : UITableViewDelegate {
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

// Private
extension Actions {
  private func accessoryTypeForObject(object: NSObject) -> UITableViewCellAccessoryType {
    let actions = self.actionsForObject(object)
    if actions.hasDetailAction() {
      return .DetailDisclosureButton
    } else if actions.hasNavigateAction() {
      return .DisclosureIndicator
    }
    return .None
  }

  private func selectionStyleForObject(object: NSObject) -> UITableViewCellSelectionStyle {
    let actions = self.actionsForObject(object)
    if (actions.hasNavigateAction() || actions.hasTapAction()) {
      return .Default
    }
    return .None
  }

  private func actionableObjectForTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> NSObject? {
    if let model = tableView.dataSource as? TableModel {
      if let object = model.objectAtPath(indexPath) as? NSObject {
        return object
      }
    }
    return nil
  }
}
