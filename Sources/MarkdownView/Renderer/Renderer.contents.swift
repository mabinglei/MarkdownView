//
//  Renderer.contents.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Markdown

extension Renderer {
    mutating func contents(of markup: Markup) -> [Result] {
        markup.children.map { visit($0) }
    }
}
