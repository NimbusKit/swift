/*
 Copyright (c) 2011-present, NimbusKit. All rights reserved.

 This source code is licensed under the BSD-style license found at http://nimbuskit.info/license
 */

import Foundation

public class MutableTableModel : TableModel {
  var mutableModel: TableCellObjectModel

  public override init(sections: [TableCellObjectModel.Section], delegate: TableModelDelegate) {
    self.mutableModel = TableCellObjectModel(sections: sections)
    super.init(sections: [], delegate: delegate)
  }

  override func typedModel() -> TableCellObjectModel {
    return mutableModel
  }
}

extension MutableTableModel : MutableModelObjectInterface {
  public func addObject(object: AnyObject) -> [NSIndexPath] {
    return self.mutableModel.addObject(object)
  }

  public func addObjects(objects: [AnyObject]) -> [NSIndexPath] {
    return self.mutableModel.addObjects(objects)
  }

  public func addObject(object: AnyObject, toSection sectionIndex: Int) -> [NSIndexPath] {
    return self.mutableModel.addObject(object, toSection: sectionIndex)
  }

  public func addObjects(objects: [AnyObject], toSection sectionIndex: Int) -> [NSIndexPath] {
    return self.mutableModel.addObjects(objects, toSection: sectionIndex)
  }

  public func removeObjectAtIndexPath(indexPath: NSIndexPath) -> [NSIndexPath] {
    return self.mutableModel.removeObjectAtIndexPath(indexPath)
  }

  public func addSectionWithHeader(header: String) -> NSIndexSet {
    return self.mutableModel.addSectionWithHeader(header)
  }

  public func insertSectionWithHeader(header: String, atIndex sectionIndex: Int) -> NSIndexSet {
    return self.mutableModel.insertSectionWithHeader(header, atIndex: sectionIndex)
  }

  public func removeSectionAtIndex(sectionIndex: Int) -> NSIndexSet {
    return self.mutableModel.removeSectionAtIndex(sectionIndex)
  }

  public func setFooterForLastSection(footer: String) -> NSIndexSet {
    return self.mutableModel.setFooterForLastSection(footer)
  }

  public func setFooter(footer: String, atIndex sectionIndex: Int) -> NSIndexSet {
    return self.mutableModel.setFooter(footer, atIndex: sectionIndex)
  }
}
