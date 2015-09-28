//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var businesses: [Business]!
    var searchBusinesses: [Business]!
    var searchBar: UISearchBar!
    var isSearching: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100

        self.searchBar = UISearchBar()
        self.searchBar.delegate = self
        self.searchBar.sizeToFit()
        self.navigationItem.titleView = self.searchBar
        
        let tapGesture = UITapGestureRecognizer(target: self.searchBar, action: Selector("resignFirstResponder"))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        self.isSearching = false
        
        Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }
}

extension BusinessesViewController: FiltersViewControllerDelegate {
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        
        let categories = filters["categories"] as? [String]
        let sortType = YelpSortMode(rawValue: filters["sort"] as! Int)
        let dealOffered = filters["deals"] as? Bool
        let distance = filters["distance"] as? Int
        
        Business.searchWithTerm("Restaurants", distance: distance, sort: sortType, categories: categories, deals: dealOffered) {
            (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
}

extension BusinessesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isSearching!) {
            return (searchBusinesses != nil) ? searchBusinesses!.count : 0
        } else {
            return (businesses != nil) ? businesses!.count : 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = (isSearching!) ? searchBusinesses![indexPath.row] : businesses![indexPath.row]
        
        return cell
    }
}

extension BusinessesViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            isSearching = false
            tableView.reloadData()
            return
        }
        isSearching = true
        searchBusinesses?.removeAll()
        
        let searchPredicate = NSPredicate(format: "name contains %@", searchText)
        searchBusinesses = businesses.filter( { searchPredicate.evaluateWithObject($0) } )
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
