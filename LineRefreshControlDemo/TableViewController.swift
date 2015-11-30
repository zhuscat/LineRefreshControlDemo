//
//  TableViewController.swift
//  LineRefreshControlDemo
//
//  Created by zhuscat on 15/11/29.
//  Copyright © 2015 zhuscat. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, LineRefreshControlDelegate {

    var freshControl: LineRefreshControl!
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        freshControl = LineRefreshControl(frame: CGRect(x: 0, y: -tableView.bounds.height, width: tableView.bounds.width, height: tableView.bounds.height))
        freshControl.delegate = self
        edgesForExtendedLayout = UIRectEdge.None
        tableView.addSubview(freshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        NSLog("refresh")
        isLoading = true
        
        // -- DO SOMETHING AWESOME --
        // This is where you'll make requests to an API, reload data, or process information
        let delayInSeconds = 2.0
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.isLoading = false
            self.freshControl.lineRefreshScrollViewDataSourceDidFinishedLoading(self.tableView)
        }
        // -- FINISHED SOMETHING AWESOME, WOO! --
    }
    
    func lineRefreshTableHeaderDataSourceIsLoading(view: LineRefreshControl) -> Bool {
        return isLoading
    }
    
    func lineRefreshTableHeaderDidTriggerRefresh(view: LineRefreshControl) {
        refresh()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = String(indexPath.row)

        return cell
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        freshControl.lineFreshScrollViewDidScroll(scrollView)
        //print(scrollView.contentOffset)
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        freshControl.lineFreshScrollViewDidEndDragging(scrollView)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
