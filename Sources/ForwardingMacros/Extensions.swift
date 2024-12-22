extension String {
	func stripPrefix(_ prefix: String) -> Substring {
		self.dropFirst(self.hasPrefix(prefix) ? prefix.count : 0)
	}
}
