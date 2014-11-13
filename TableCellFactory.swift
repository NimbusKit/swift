/*
 Copyright (c) 2011-present, NimbusKit. All rights reserved.

 This source code is licensed under the BSD-style license found at http://nimbuskit.info/license
 */

@objc public protocol TableCellObject {
  func tableCellClass() -> UITableViewCell.Type
  optional func cellStyle() -> UITableViewCellStyle
  optional func shouldAppendClassNameToReuseIdentifier() -> Bool
}

@objc public protocol TableCell {
  func updateCellWithObject(object: TableCellObject)
}

/**
The TableCellFactory class is the binding logic between Objects and Cells and should be used as the
delegate for a TableModel.

A contrived example of creating an empty model with the singleton TableCellFactory instance.

    let model = TableModel(delegate: TableCellFactory.tableModelDelegate())
*/
public class TableCellFactory : NSObject {

  /**
  Returns a singleton TableModelDelegate instance for use as a TableModel delegate.
  */
  public class func tableModelDelegate() -> TableModelDelegate {
    return self.sharedInstance
  }
}

extension TableCellFactory : TableModelDelegate {
  public func tableModel(tableModel: TableModel, cellForTableView tableView: UITableView, indexPath: NSIndexPath, object: AnyObject) -> UITableViewCell? {
    return self.cell(object.tableCellClass(), tableView: tableView, indexPath: indexPath, object: object as? TableCellObject)
  }
}

// Private
extension TableCellFactory {

  /**
  Returns a cell for a given object.
  */
  func cell(tableCellClass: UITableViewCell.Type, tableView: UITableView, indexPath: NSIndexPath, object: TableCellObject?) -> UITableViewCell? {
    if object == nil {
      return nil
    }
    var style = UITableViewCellStyle.Default;
    var identifier = NSStringFromClass(tableCellClass)

    // Append object class to reuse identifier

    if (object!.shouldAppendClassNameToReuseIdentifier? != nil) && object!.shouldAppendClassNameToReuseIdentifier!() {
      let typedObject: AnyObject = object as AnyObject
      identifier = identifier.stringByAppendingString(NSStringFromClass(typedObject.dynamicType))
    }

    // Append cell style to reuse identifier

    if let objectCellStyle = object!.cellStyle?() {
      style = objectCellStyle
      identifier = identifier.stringByAppendingString(String(style.rawValue))
    }

    // Recycle or create the cell

    var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as UITableViewCell?
    if cell == nil {
      cell = tableCellClass(style: style, reuseIdentifier: identifier)
    }

    // Provide the object to the cell

    if let tableCell = cell as TableCell? {
      tableCell.updateCellWithObject(object!)
    }

    return cell!
  }
}

// Singleton Pattern
extension TableCellFactory {
  class var sharedInstance : TableCellFactory {
    struct Singleton {
      static let instance = TableCellFactory()
    }
    return Singleton.instance
  }
}
