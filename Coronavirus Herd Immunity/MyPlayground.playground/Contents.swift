import UIKit

var str = "12345"
var sum = 0
for char in str{
    sum += Int(char.description) ?? 0
}
print(sum)
let x = sum.description.last ?? "0"
print(x)
