---
title:  "Core Data Tips"

categories:
  - core-data
tags:
  - core-data
  - model
---
# Core Data Tips




    
## How to initiate core data object without inserting it to the context
~~~
let gif = Gif(entity: NSEntityDescription.entity(forEntityName: String(describing: Gif.self), in: DataController.shared.persistentContainer.viewContext)!, insertInto: nil)
~~~
{: .language-swift}
## remove All Data
~~~
let fetchRequest = NSFetchRequest(entityName: String(describing: Gif.self))
let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

do {
    let moc = DataController.shared.persistentContainer.viewContext
    try moc.execute(deleteRequest)
    try moc.save()
} catch let error as NSError {
    fatalError("Failure to delete context: \(error)")
}
~~~
{: .language-swift}
  
## Search
  
### Event if the data has it's id, I cannot change or set objectId of core data entity object. So even if you find a object with that kind of id, you need to use predicate
 
~~~
let moc = DataController.shared.persistentContainer.viewContext
let fetchRequest = NSFetchRequest(entityName: String(describing: Gif.self))
fetchRequest.predicate = NSPredicate(format: "id == %@", gif.id)

isFavorite = false
do {
    fetchedGifs = try moc.fetch(fetchRequest) as! [Gif]
    if !fetchedGifs.isEmpty {
        isFavorite = true
    }
} catch {
    fatalError("Failed to fetch favorite gifs: \(error)")
}
~~~
{: .language-swift}


        



