import Foundation
import Swifter
import Dispatch

@main
public struct RealTimeLogs {
    public static func main() {
        let server = HttpServer()
        let _ = MobileLogCollector(server: server)
        try? server.start(8080)
        print("Started RealTimeLogs")
        dispatchMain()
    }
}
