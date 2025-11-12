import AnsiEscapes
import Foundation

public class NormalRenderer: Renderer {
    var linesRendered = 0

    /// Even though we only redraw invalidated parts of the screen, terminal
    /// drawing is currently still slow, as it involves moving the cursor
    /// position and printing a character there.
    /// This cache stores the screen content to see if printing is necessary.
    private var cache: [[Cell?]] = []

    /// The current cursor position, which might need to be updated before
    /// printing.
    private var currentPosition: Position = .zero

    private var currentForegroundColor: Color? = nil
    private var currentBackgroundColor: Color? = nil

    private var currentAttributes = CellAttributes()

    public weak var application: Application?

    var layer: Layer {
        get {
            guard let layer = application?.window.layer else {
                fatalError("Tried to access Renderer.layer but application is nil")
            }
            return layer
        }
    }

    var contentLayer: Layer {
        get {
            guard let layer = application?.window.controls.first?.layer else {
                fatalError("Tried to access Renderer.contentLayer but application is nil")
            }
            return layer
        }
    }

    public init() {}

    /// Draw only the invalidated part of the layer.
    public func update() {
        if let invalidated = layer.invalidated {
            draw(rect: invalidated)
            layer.invalidated = nil
        }
    }

    public func didChangeLayer() {}

    func draw(rect: Rect? = nil) {
        if rect == nil { layer.invalidated = nil }
        let rect = rect ?? Rect(position: .zero, size: layer.frame.size)
        guard rect.size.width > 0, rect.size.height > 0 else {
            assertionFailure("Trying to draw in empty rect")
            return
        }

        // Window dimentsions
        let windowWidth = layer.frame.size.width.intValue
        let windowHeight = layer.frame.size.height.intValue

        // Calculate number of rows that needs to be re-rendered
        let contentHeight = contentLayer.frame.size.height.intValue
        var offset = 0
        if contentHeight < windowHeight {
            offset = 0
        } else {
            offset = contentHeight - windowHeight
        }

        // Extend terminal window to cover new lines
        var linesAdded = 0
        if contentHeight > linesRendered {
            for _ in linesRendered ..< contentHeight {
                write("\n")
                linesAdded += 1
            }
        }

        // Move cursor back required lines
        let renderedHeight = max(contentHeight, linesRendered)
        if renderedHeight <= windowHeight {
            write(ANSIEscapeCode.moveCursorTo(x: 0, y: windowHeight - renderedHeight + rect.minLine.intValue))

            // Erase lines that were rendered previously
            let linesToErase = renderedHeight - contentHeight
            if linesToErase > 0 {
                let emptyCell = Cell(char: " ")
                for _ in 0 ..< linesToErase {
                    for _ in 0 ..< windowWidth {
                        drawPixel(emptyCell)
                    }
                    write(ANSIEscapeCode.CursorNextLine)
                }
            }
        } else {
            write(ANSIEscapeCode.moveCursorTo(x: 0, y: rect.minLine.intValue))
        }

        // Render those lines again
        let minLine = rect.minLine.intValue + offset
        for line in minLine ..< contentHeight {
            for column in 0 ..< windowWidth {
                let position = Position(column: Extended(column), line: Extended(line))
                if let cell = layer.cell(at: position) {
                    drawPixel(cell)
                }
            }
            write(ANSIEscapeCode.CursorNextLine)
        }

        linesRendered = renderedHeight
    }

    public func start() {
        write(ANSIEscapeCode.CursorHide)
    }

    public func stop() {
        write(ANSIEscapeCode.CursorShow)
    }

    private func drawPixel(_ cell: Cell) {
        if self.currentForegroundColor != cell.foregroundColor {
            write(cell.foregroundColor.foregroundEscapeSequence)
            self.currentForegroundColor = cell.foregroundColor
        }
        let backgroundColor = cell.backgroundColor ?? .default
        if self.currentBackgroundColor != backgroundColor {
            write(backgroundColor.backgroundEscapeSequence)
            self.currentBackgroundColor = backgroundColor
        }
        self.updateAttributes(cell.attributes)
        write(String(cell.char))
        self.currentPosition.column += 1
    }

    private func updateAttributes(_ attributes: CellAttributes) {
        if currentAttributes.bold != attributes.bold {
            if attributes.bold { write(EscapeSequence.enableBold) }
            else { write(EscapeSequence.disableBold) }
        }
        if currentAttributes.italic != attributes.italic {
            if attributes.italic { write(EscapeSequence.enableItalic) }
            else { write(EscapeSequence.disableItalic) }
        }
        if currentAttributes.underline != attributes.underline {
            if attributes.underline { write(EscapeSequence.enableUnderline) }
            else { write(EscapeSequence.disableUnderline) }
        }
        if currentAttributes.strikethrough != attributes.strikethrough {
            if attributes.strikethrough { write(EscapeSequence.enableStrikethrough) }
            else { write(EscapeSequence.disableStrikethrough) }
        }
        if currentAttributes.inverted != attributes.inverted {
            if attributes.inverted { write(EscapeSequence.enableInverted) }
            else { write(EscapeSequence.disableInverted) }
        }
        currentAttributes = attributes
    }
}

private func write(_ str: String) {
    str.withCString { _ = write(STDOUT_FILENO, $0, strlen($0)) }
}
