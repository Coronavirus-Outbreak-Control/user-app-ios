import Foundation

func getTimeBlock(_ date : Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd-"
    let s = dateFormatter.string(from: date)
    let hour = Calendar.current.component(.hour, from: date)
    let moduleHour : Int = hour / 4
    return s + String(moduleHour)
}

var a = Date()
print(getTimeBlock(a))
