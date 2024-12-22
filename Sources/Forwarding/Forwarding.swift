@attached(extension, names: arbitrary)
public macro Forward(_ protoPrefix: String, _ forwardPrefix: String) = #externalMacro(module: "ForwardingMacros", type: "ForwardMacro")
