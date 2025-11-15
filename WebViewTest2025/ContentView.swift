import SwiftUI
import WebKit
import Combine
import Observation

@Observable class MyWebViewModel {
    var webPage = WebPage()
    
    func load(url: URL) async {
        webPage.load(URLRequest(url: url))
    }
    
    func restrictToVertical(webPage: WebPage) async {
        // Wait until the page has finished loading
        while webPage.isLoading {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 s
        }
        
        let js = """
        const style = document.createElement('style');
        style.textContent = `
          html, body {
            overflow-x: hidden !important;
            overscroll-behavior-x: none;
          }
          * {
            max-width: 100vw !important;
            box-sizing: border-box;
          }
        `;
        document.head.appendChild(style);
        """
        
        do {
            _ = try await webPage.callJavaScript(js)
        } catch {
            print("Failed to inject vertical-only CSS:", error)
        }
    }
    
    func list(webPage: WebPage) async {
        // Wait until the page has finished loading
        do {
            try await Task(operation: {
                // After the page has finished loading, list DOM elements
                let js = """
                const all = document.getElementsByTagName('*');
                const elements = [];
                for (let i = 0; i < all.length; i++) {
                    const el = all[i];
                    const tagName = el.tagName;
                    const id = el.id || '';
                    const className = el.className || '';
                    const text = (el.textContent || '').trim().slice(0, 80);
                    elements.push(tagName + "|" + id + "|" + className + "|" + text);
                }
                return elements;
                """
                
                if let elements = try await webPage.callJavaScript(js) as? [String] {
                    print("\n================ DOM ELEMENTS ================")
                    print("Total elements: \(elements.count)")
                    
                    for (index, line) in elements.enumerated() {
                        let parts = line.components(separatedBy: "|")
                        let tagName = parts.count > 0 ? parts[0] : ""
                        let elementId = parts.count > 1 ? parts[1] : ""
                        let className = parts.count > 2 ? parts[2] : ""
                        let textPreview = parts.count > 3 ? parts[3] : ""
                        
                        print("\n[\(index)] <\(tagName)>")
                        
                        if !elementId.isEmpty {
                            print("   id: \(elementId)")
                        }
                        
                        if !className.isEmpty {
                            print("   class: \(className)")
                        }
                        
                        if !textPreview.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            print("   text: \"\(textPreview)\"")
                        }
                    }
                    print("\n============== END DOM ELEMENTS ==============\n")
                } else {
                    let result = try await webPage.callJavaScript(js)
                    print("DOM script returned unexpected result:", result as Any)
                }
            })
            .value
        } catch {
            print("JavaScript error:", error.localizedDescription)
        }
    }
}


struct ContentView: View {
    @State private var viewModel = MyWebViewModel()
    
    var body: some View {
        WebView(viewModel.webPage)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .ignoresSafeArea(edges: [.bottom])
            .padding()
            .task {
                await viewModel.load(url: URL(string: "https://chatgpt.com")!)
                await viewModel.restrictToVertical(webPage: viewModel.webPage)
                await viewModel.list(webPage: viewModel.webPage)
            }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
        .dynamicTypeSize(DynamicTypeSize.small)
}
