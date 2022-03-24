import sys
from PyQt6.QtCore import Qt
from PyQt6.QtWidgets import (
    QMainWindow,
    QApplication,
    QWidget,
    QVBoxLayout,
    QLabel,
    QPushButton,
)


class Window(QMainWindow):
    def __init__(self):
        super().__init__()
        self._width = 500
        self._height = 250
        self._xPos = 700
        self._yPos = 400
        self.initUI()

    def initUI(self):
        self.setGeometry(self._xPos, self._yPos, self._width, self._height)
        self.setWindowTitle('App Window Title')

        self.vBox = QVBoxLayout()

        self.title = QLabel()
        self.title.setText('Welcome to your PyQt6 Desktop App!')
        self.title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.vBox.addWidget(self.title)

        self.button = QPushButton()
        self.button.setText('Click Me')
        self.button.clicked.connect(self.buttonPressed)
        self.vBox.addWidget(self.button)

        self.centralWidget = QWidget(self)
        self.centralWidget.setLayout(self.vBox)
        self.setCentralWidget(self.centralWidget)

        self.show()

    def buttonPressed(self):
        self.statusBar().showMessage('Button Press Detected')

if __name__ == '__main__':
    app = QApplication(sys.argv)
    myWin = Window()
    sys.exit(app.exec())
