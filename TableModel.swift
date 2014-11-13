/*
 Copyright (c) 2011-present, NimbusKit. All rights reserved.

 This source code is licensed under the BSD-style license found at http://nimbuskit.info/license
 */

@objc public protocol TableModelDelegate {
  func tableModel (tableModel: TableModel, cellForTableView tableView: UITableView, indexPath: NSIndexPath, object: AnyObject) -> UITableViewCell?
}

/**
An instance of TableModel is meant to be the data source for a UITableView.

TableModel stores a collection of sectioned objects. Each object must conform to the TableCellObject
protocol. Each section can have a header and/or footer title.

Sections are tuples of the form:

    ((header: String?, footer: String?)?, objects: [TableCellObject])

When provided as the dataSource for a UITableView, the following occurs each time a cell needs to be
displayed:

- The table view requests a cell for a given index path.
- The model retrieves the object corresponding to the index path and:
- determines the object's cell class,
- recycles or instantiates the cell, and
- returns the cell to the table view.
*/
public class TableModel : NSObject {
  typealias TableCellObjectModel = Model<AnyObject>

  let model: TableCellObjectModel
  weak var delegate: TableModelDelegate?

  public init(sections: [TableCellObjectModel.Section], delegate: TableModelDelegate) {
    self.model = TableCellObjectModel(sections: sections)
    self.delegate = delegate
    super.init()
  }

  public convenience init(list: [TableCellObject], delegate: TableModelDelegate) {
    self.init(sections: [(nil, objects: list)], delegate: delegate)
  }

  public convenience init(delegate: TableModelDelegate) {
    self.init(sections: [(nil, objects: [])], delegate: delegate)
  }

  func typedModel() -> TableCellObjectModel {
    return self.model
  }
}

extension TableModel : ModelObjectInterface {
  /**
  Returns the object at the given index path.

  Providing a non-existent index path will throw an exception.

  :param:   path    A two-index index path referencing a specific object in the receiver.
  :returns: The object found at path.
  */
  public func objectAtPath(path: NSIndexPath) -> AnyObject {
    return self.typedModel().objectAtPath(path)
  }

  /**
  Returns the index path for an object matching needle if it exists in the receiver.

  :param:   needle    The object to search for in the receiver.
  :returns: The index path of needle, if it was found, otherwise nil.
  */
  public func pathForObject(needle: AnyObject) -> NSIndexPath? {
    return self.typedModel().pathForObject(needle)
  }
}

extension TableModel : UITableViewDataSource {
  public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.typedModel().sections.count
  }

  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.typedModel().sections[section].objects.count
  }

  public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return self.typedModel().sections[section].0?.header
  }

  public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return self.typedModel().sections[section].0?.footer
  }

  public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }

  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let object: AnyObject = self.typedModel().objectAtPath(indexPath)
    return self.delegate!.tableModel(self, cellForTableView: tableView, indexPath: indexPath, object: object)!
  }
}
