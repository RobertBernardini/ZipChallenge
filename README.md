# ZipChallenge



## Peter and Siavash ##
I found an issue when testing on a device with iOS 13.3.1 due to using a CocoaPod that has Alamofire as a dependency, most likely due to RxAlamofire. I thought it was due to my code but it with the Signing of a Pod which uses the Alamofire pod as a dependency, and is specifically happening on a device with that iOS version. Maybe you have already had the problem since you use RxAlamofire. If so, I'd recommend not upgrading any device until it has been solved otherwise you can only test with the simulator, like I was doing before coming across this bug.

