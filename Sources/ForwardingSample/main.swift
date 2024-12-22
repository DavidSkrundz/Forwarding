import Forwarding

@Forward("AAA", "BBB")
protocol ForwardedProtocol {
	func AAA_function()
}

extension ForwardedProtocol {
	func BBB_function() {
		print("ForwardedProtocol => BBB_function")
	}
}

struct ForwardedStruct: ForwardedProtocol {}

struct OverrideStruct: ForwardedProtocol {
	func AAA_function() {
		print("OverrideStruct => AAA_function")
		BBB_function()
	}
}

func main() {
	ForwardedStruct().AAA_function()
	OverrideStruct().AAA_function()
}
main()

