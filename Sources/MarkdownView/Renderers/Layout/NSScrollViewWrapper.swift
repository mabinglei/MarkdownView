//
//  File.swift
//  MarkdownView
//
//  Created by Binglei Ma on 3/11/25.
//

import SwiftUI

#if os(macOS)
struct NSScrollViewWrapper<Content: View>: NSViewRepresentable {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = MTHorizontalScrollView()
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = false
        scrollView.verticalScrollElasticity = .none
        scrollView.horizontalScrollElasticity = .allowed
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        let hostingView = NSHostingView(rootView: content)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.documentView = hostingView
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.widthAnchor)
        ])
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        if let hostingView = nsView.documentView as? NSHostingView<Content> {
            hostingView.rootView = content
        }
    }
}

class MTHorizontalScrollView: NSScrollView {
    
    var currentScrollIsHorizontal = false
    
    override func scrollWheel(with event: NSEvent) {
        if event.phase == NSEvent.Phase.began || (event.phase == NSEvent.Phase.ended && event.momentumPhase == NSEvent.Phase.ended) {
            currentScrollIsHorizontal = abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY)
        }
        if currentScrollIsHorizontal {
            super.scrollWheel(with: event)
        } else {
            self.nextResponder?.scrollWheel(with: event)
        }
    }
    
}

#endif

extension View {
    @ViewBuilder
    func forwardedScrollEvents(_ enabled: Bool = true) -> some View {
#if os(macOS)
        if enabled {
            NSScrollViewWrapper {
                self
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            self
        }
#else
        self
#endif
    }
}
