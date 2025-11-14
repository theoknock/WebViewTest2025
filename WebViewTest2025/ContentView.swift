import SwiftUI
import WebKit
import Combine
import Observation

@Observable class MyWebViewModel {
    var webPage = WebPage()
    
    func load(url: URL) async {
        webPage.load(URLRequest(url: url))
    }
}

struct ContentView: View {
    @State var viewModel = MyWebViewModel()
    
    var body: some View {
        NavigationView {
            WebView(viewModel.webPage)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
                .task {
                    await viewModel.load(url: URL(string: "https://chatgpt.com")!)
                    print("done loading")
                }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

//struct WebView: UIViewRepresentable {
//    let url: URL
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> WKWebView {
//        // Configure WKWebView with navigation delegate
//        let configuration = WKWebViewConfiguration()
//        configuration.websiteDataStore = .default()
//
//        // Enable JavaScript
//        configuration.preferences.javaScriptEnabled = true
//
//        // Create WebView
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.navigationDelegate = context.coordinator
//
//        // Load the URL
//        let request = URLRequest(url: url)
//        webView.load(request)
//
//        return webView
//    }
//
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        // No updates needed for this simple implementation
//    }
//
//    class Coordinator: NSObject, WKNavigationDelegate {
//        var parent: WebView
//
//        init(_ parent: WebView) {
//            self.parent = parent
//        }
//
//        // Called when the page finishes loading
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            print("✅ Page finished loading: \(webView.url?.absoluteString ?? "unknown")")
//
//            // JavaScript to get all DOM elements
//            let jsScript = """
//            (function() {
//                // Get all elements on the page
//                const allElements = document.getElementsByTagName('*');
//                const elementInfo = [];
//
//                // Collect information about each element
//                for (let i = 0; i < allElements.length; i++) {
//                    const elem = allElements[i];
//                    const info = {
//                        tagName: elem.tagName,
//                        id: elem.id || 'none',
//                        className: elem.className || 'none',
//                        textContent: elem.textContent ? elem.textContent.substring(0, 50) : 'none',
//                        elementIndex: i
//                    };
//                    elementInfo.push(info);
//                }
//
//                return {
//                    totalElements: allElements.length,
//                    elements: elementInfo
//                };
//            })();
//            """
//
//            // Execute the JavaScript
//            webView.evaluateJavaScript(jsScript) { (result, error) in
//                if let error = error {
//                    print("❌ JavaScript Error: \(error.localizedDescription)")
//                    return
//                }
//
//                if let resultDict = result as? [String: Any],
//                   let totalElements = resultDict["totalElements"] as? Int,
//                   let elements = resultDict["elements"] as? [[String: Any]] {
//
//                    print("\n" + String(repeating: "=", count: 80))
//                    print("📊 DOM ELEMENTS ANALYSIS")
//                    print(String(repeating: "=", count: 80))
//                    print("Total DOM Elements Found: \(totalElements)")
//                    print(String(repeating: "-", count: 80))
//
//                    // Print each element's information
//                    for (index, element) in elements.enumerated() {
//                        let tagName = element["tagName"] as? String ?? "unknown"
//                        let elementId = element["id"] as? String ?? "none"
//                        let className = element["className"] as? String ?? "none"
//                        let textPreview = element["textContent"] as? String ?? "none"
//
//                        print("\n🏷️  Element #\(index + 1):")
//                        print("   Tag: <\(tagName)>")
//
//                        if elementId != "none" {
//                            print("   ID: #\(elementId)")
//                        }
//
//                        if className != "none" && !className.isEmpty {
//                            print("   Classes: .\(className.replacingOccurrences(of: " ", with: ", ."))")
//                        }
//
//                        if textPreview != "none" && !textPreview.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                            let trimmedText = textPreview
//                                .trimmingCharacters(in: .whitespacesAndNewlines)
//                                .replacingOccurrences(of: "\n", with: " ")
//                            if trimmedText.count > 0 {
//                                print("   Text: \"\(trimmedText)...\"")
//                            }
//                        }
//                    }
//
//                    print("\n" + String(repeating: "=", count: 80))
//                    print("✅ DOM Analysis Complete!")
//                    print(String(repeating: "=", count: 80) + "\n")
//
//                    // Also print a summary of tag types
//                    self.printTagSummary(elements: elements)
//                }
//            }
//        }
//
//        // Print a summary of tag types found
//        func printTagSummary(elements: [[String: Any]]) {
//            var tagCounts: [String: Int] = [:]
//
//            for element in elements {
//                if let tagName = element["tagName"] as? String {
//                    tagCounts[tagName] = (tagCounts[tagName] ?? 0) + 1
//                }
//            }
//
//            print("\n📈 TAG SUMMARY:")
//            print(String(repeating: "-", count: 40))
//
//            // Sort by count (descending) and print
//            let sortedTags = tagCounts.sorted { $0.value > $1.value }
//            for (tag, count) in sortedTags.prefix(20) {  // Show top 20 most common tags
//                print("   \(tag): \(count) elements")
//            }
//
//            if sortedTags.count > 20 {
//                print("   ... and \(sortedTags.count - 20) more tag types")
//            }
//
//            print(String(repeating: "-", count: 40) + "\n")
//        }
//
//        // Handle navigation errors
//        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//            print("❌ Navigation failed: \(error.localizedDescription)")
//        }
//
//        // Handle provisional navigation failures
//        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//            print("❌ Provisional navigation failed: \(error.localizedDescription)")
//        }
//
//        // Log when navigation starts
//        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//            print("🔄 Starting to load: \(webView.url?.absoluteString ?? "unknown")")
//        }
//    }
//}


