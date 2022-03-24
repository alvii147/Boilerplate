# ----------------------------------------------------------------------
# Django Boilerplate Script
# ----------------------------------------------------------------------
# Options:
# -p = project name
# ----------------------------------------------------------------------
# Requirements:
# - Django
# - Django Rest Framework
# - Django CORS Headers
# ----------------------------------------------------------------------

django_boilerplate() {
    # Check for installation requirements
    echo -e "Verifying requirements..."
    FREEZE=`${PIP_CMD} freeze 2>&1`
    django_installation=`echo "$FREEZE" | grep -E "Django==[\d.]*"`
    djangorestframework_installation=`echo "$FREEZE" | grep -E "djangorestframework==[\d.]*"`
    djangocorsheaders_installation=`echo "$FREEZE" | grep -E "django-cors-headers==[\d.]*"`

    if [ -z "${django_installation}" ] || [ -z "${djangorestframework_installation}" ] || [ -z "${djangocorsheaders_installation}" ]; then
        echo -e "Error: Requirements not installed"
        echo -e "Please install requirements by running \"pip3 install django djangorestframework django-cors-headers\""
        exit 127
    fi

    # Create project
    echo -e "Creating Django project \"${PROJ_NAME}\"..."
    django-admin startproject --template ${SCRIPT_DIR}/templates/Django/project_template ${PROJ_NAME}

    # Create app
    echo -e "Creating Django app \"accounts\"..."
    cd ${PROJ_NAME}
    django-admin startapp --template ${SCRIPT_DIR}/templates/Django/accounts_app_template accounts

    echo -e "Finished creating boilerplate Django project!"
}

# ----------------------------------------------------------------------
# Flask Boilerplate Script
# ----------------------------------------------------------------------
# Options:
# -p = project name
# ----------------------------------------------------------------------
# Requirements:
# - Flask
# - Flask SQLAlchemy
# ----------------------------------------------------------------------

flask_boilerplate() {
    # Check for flask and flasksqlalchemy installation
    echo -e "Verifying requirements..."
    flask_installation=`echo "${FREEZE}" | grep -E "Flask==[\d.]*"`
    flasksqlalchemy_installation=`echo "${FREEZE}" | grep -E "Flask-SQLAlchemy==[\d.]*"`

    if [ -z "${flask_installation}" ] || [ -z "${flasksqlalchemy_installation}" ]; then
        echo -e "Warning: Requirements not installed"
        echo -e "Please install requirements by running \"pip3 install Flask Flask-SQLAlchemy\""
    fi

    mkdir -p ${PROJ_NAME}
    cp -r ${SCRIPT_DIR}/templates/Flask/* ${PROJ_NAME}
    mv ${PROJ_NAME}/app.py ${PROJ_NAME}/${PROJ_NAME}.py

    echo -e "Finished creating boilerplate Django project!"
}

# ----------------------------------------------------------------------
# PyQt5 Boilerplate Script
# ----------------------------------------------------------------------
# Options:
# -a = app name
# ----------------------------------------------------------------------
# Requirements:
# - PyQt5
# ----------------------------------------------------------------------

pyqt5_boilerplate() {
    # Check for pyqt5 installation
    echo -e "Verifying requirements..."
    pyqt5_install=`$PYTHON_CMD -c "import PyQt5" 2>&1`
    if [ ! -z "$pyqt5_install" ]; then
        echo -e "\nWARNING: PyQt5 is not installed"
        echo -e "Please install PyQt5"
        echo -e "Run \"pip install pyqt5\""
    else
        echo -e "Found PyQt5 installation"
    fi

    mkdir -p $APP_NAME
    cd $APP_NAME

    # Write to main PyQt5 file
    echo -e "Creating $APP_NAME.py..."
    cat <<EOF > $APP_NAME.py
import sys
from PyQt5.QtWidgets import QMainWindow, QApplication, QWidget, QVBoxLayout, QLabel, QPushButton
from PyQt5.QtCore import Qt

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
        self.setWindowTitle('My PyQt5 App')

        self.vBox = QVBoxLayout()

        self.title = QLabel()
        self.title.setText('Welcome to your PyQt5 App!')
        self.title.setAlignment(Qt.AlignCenter)
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
        self.statusBar().showMessage('Button pressed!')

if __name__ == '__main__':
    app = QApplication(sys.argv)
    myWin = Window()
    sys.exit(app.exec_())
EOF
}

# ----------------------------------------------------------------------
# React Native Boilerplate Script
# ----------------------------------------------------------------------
# Options:
# -a = app name
# ----------------------------------------------------------------------
# Requirements:
# - npm
# - expo cli
# ----------------------------------------------------------------------

reactnative_boilerplate() {
    # Check for npm installation
    which npm >/dev/null 2>&1
    if [[ "$?" -ne 0 ]]; then
        echo -e "\nERROR: npm is not installed"
        echo -e "Please install npm"
        echo -e "https://nodejs.org/en/download/"
        requirements_err=1
    else
        if [[ ! "$requirements_err" -eq 1 ]]; then
            echo -e "Found npm installation"
        fi
    fi

    # Checking for expo cli installation
    which expo >/dev/null 2>&1
    if [[ "$?" -ne 0 ]]; then
        echo -e "\nERROR: expo cli is not installed"
        echo -e "Run \"npm install -g expo-cli\""
        requirements_err=1
    else
        if [[ ! "$requirements_err" -eq 1 ]]; then
            echo -e "Found expo cli installation"
        fi
    fi

    if [[ "$requirements_err" -eq 1 ]]; then
        exit 127
    fi

    # Create new expo app
    echo -e "Creating expo app..."
    expo init $APP_NAME --template blank
    cd $APP_NAME

    # Install react native paper
    echo -e "Installing react-native-paper..."
    npm install react-native-paper

    # Install react native navigation
    echo -e "Installing react-native-navigation..."
    npm install react-navigation
    expo install react-native-gesture-handler
    expo install react-native-reanimated
    expo install react-native-screens
    expo install react-native-safe-area-context
    expo install @react-native-community/masked-view
    npm install react-navigation-stack
    npm install react-navigation-material-bottom-tabs


    # Install react native vector icons
    echo -e "Installing react-native-vector-icons..."
    npm install react-native-vector-icons

    # Writing App.js
    echo -e "Writing App.js..."
    cat <<EOF > App.js
import React, { Component } from 'react';
import AppContainer from './src/routes/AppContainer';

export default class App extends Component {
    state = {
        isUserAuth: false,
    }

    componentDidMount() {
        //this.setState({isUserAuth: true});
    }

    render() {
        return (
            <AppContainer />
        );
    }
}
EOF

    mkdir -p src/{constants,routes,screens}

    cd src/routes
    # Writing AppContainer.js
    echo -e "Writing AppContainer.js..."
    cat <<EOF > AppContainer.js
import { createAppContainer, createSwitchNavigator } from 'react-navigation';
import AuthStack from './AuthStack';
import AppStack from './AppStack';

export default createAppContainer (
    createSwitchNavigator
    (
        {
            Auth: AuthStack,
            App: AppStack,
        },
        {
            initialRouteName: 'Auth',
        }
    )
);
EOF

    # Writing AuthStack.js
    echo -e "Writing AuthStack.js..."
    cat <<EOF > AuthStack.js
import { createStackNavigator } from 'react-navigation-stack';
import Login from '../screens/Login';
import Register from '../screens/Register';

const AuthScreens = {
    Login: {
        screen: Login,
        navigationOptions: {
            header: () => false,
        },
    },
    Register: {
        screen: Register,
        navigationOptions: {
            header: () => false,
        },
    }
}

export default createStackNavigator(AuthScreens);
EOF

    # Writing AppStack.js
    echo -e "Writing AppStack.js..."
    cat <<EOF > AppStack.js
import { createMaterialBottomTabNavigator } from 'react-navigation-material-bottom-tabs';
import React from 'react';
import { View } from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';
import Colors from '../constants/Colors';
import Home from '../screens/Home';
import Profile from '../screens/Profile';
import Notifications from '../screens/Notifications';
import Settings from '../screens/Settings';

const AppScreens = {
    Home: {
        screen: Home,
        navigationOptions: {
            tabBarLabel: 'Home',
            tabBarIcon: () => (
                <View>
                    <Icon style={[{color: Colors.tabIcon}]} size={25} name={'home'} />
                </View>
            ),
            activeColor: Colors.tabIcon,
            barStyle: {
                backgroundColor: Colors.primary,
            },
        },
    },
    Profile: {
        screen: Profile,
        navigationOptions: {
            tabBarLabel: 'Profile',
            tabBarIcon: () => (
                <View>
                    <Icon style={[{color: Colors.tabIcon}]} size={25} name={'person-circle'} />
                </View>
            ),
            activeColor: Colors.tabIcon,
            barStyle: {
                backgroundColor: Colors.primary,
            },
        },
    },
    Notifications: {
        screen: Notifications,
        navigationOptions: {
            tabBarLabel: 'Home',
            tabBarIcon: () => (
                <View>
                    <Icon style={[{color: Colors.tabIcon}]} size={25} name={'notifications'} />
                </View>
            ),
            activeColor: Colors.tabIcon,
            barStyle: {
                backgroundColor: Colors.primary,
            },
        },
    },
    Settings: {
        screen: Settings,
        navigationOptions: {
            tabBarLabel: 'Settings',
            tabBarIcon: () => (
                <View>
                    <Icon style={[{color: Colors.tabIcon}]} size={25} name={'settings'} />
                </View>
            ),
            activeColor: Colors.tabIcon,
            barStyle: {
                backgroundColor: Colors.primary,
            },
        },
    },
}

export default createMaterialBottomTabNavigator(AppScreens);
EOF

    cd ../screens
    # Writing Login.js
    echo -e "Writing Login.js..."
    cat <<EOF > Login.js
import React, { Component } from 'react';
import { StyleSheet, Text, View, Image, Keyboard, TouchableWithoutFeedback, TouchableOpacity } from 'react-native';
import { TextInput, Button } from 'react-native-paper';
import Colors from '../constants/Colors';

export default class Login extends Component {
    constructor(props) {
        super(props);
        this.state = {
            username: '',
            password: '',
        };
        this.loginButtonPressHandler.bind(this);
    }

    loginButtonPressHandler = async () => {
        this.props.navigation.navigate('App');
    };

    render() {
        return (
            <TouchableWithoutFeedback onPress={() => {
                Keyboard.dismiss();
            }}>
                <View style={styles.container}>
                    <View style={styles.logoContainer}>
                        <Image source={require('../../assets/react_logo.png')} style={styles.logo}></Image>
                    </View>
                    <View style={styles.loginContainer}>
                        <TextInput
                            style={styles.textInputBox}
                            label='Username'
                            value={this.state.username}
                            placeholder='e.g. wwilson1991'
                            mode='outlined'
                            selectionColor={Colors.primary}
                            underlineColor={Colors.primary}
                            theme={{
                                colors: {
                                    primary: Colors.primary,
                                },
                            }}
                            onChangeText={username => this.setState({ username: username })} />
                        <TextInput
                            style={styles.textInputBox}
                            label='Password'
                            value={this.state.password}
                            secureTextEntry={true}
                            placeholder='e.g. 9#7@P+d3N%'
                            mode='outlined'
                            selectionColor={Colors.primary}
                            underlineColor={Colors.primary}
                            theme={{
                                colors: {
                                    primary: Colors.primary,
                                },
                            }}
                            onChangeText={password => this.setState({ password: password })} />
                    </View>
                    <View style={styles.buttonWrapper}>
                        <Button
                            onPress={this.loginButtonPressHandler}
                            mode='contained'
                            color={Colors.primary}>
                                Log in
                        </Button>
                    </View>
                    <View style={styles.registerWrapper}>
                        <Text>
                            Need an account?&nbsp;
                            <Text style={styles.registerText} onPress={() => {this.props.navigation.navigate('Register');}}>
                                Register
                            </Text>
                        </Text>
                    </View>
                </View>
            </TouchableWithoutFeedback>
        )
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Colors.secondary,
        alignItems: 'center',
        justifyContent: 'center',
    },

    logoContainer: {
        flex: 6,
        alignItems: 'center',
        justifyContent: 'center',
    },

    logo: {
        width: 160,
        height: 160,
    },

    loginContainer: {
        flex: 2,
        justifyContent: 'center',
        width: 250,
        height: 153,
    },

    textInputBox: {
        paddingTop: 5,
        paddingBottom: 5,
    },

    buttonWrapper: {
        flex: 2,
        justifyContent: 'flex-end',
    },

    registerWrapper: {
        flex: 3,
        paddingTop: 15,
    },

    registerText: {
        color: Colors.primary,
    },
});
EOF

    # Writing Register.js
    echo -e "Writing Register.js..."
    cat <<EOF > Register.js
import React, { Component } from 'react';
import { StyleSheet, Text, View, Image, Keyboard, TouchableWithoutFeedback, TouchableOpacity } from 'react-native';
import { TextInput, Button } from 'react-native-paper';
import Colors from '../constants/Colors';

export default class Login extends Component {
    constructor(props) {
        super(props);
        this.state = {
            firstname: '',
            lastname: '',
            username: '',
            password: '',
        };
        this.registerButtonPressHandler.bind(this);
    }

    registerButtonPressHandler = async () => {
        this.props.navigation.navigate('Login');
    };

    render() {
        return (
            <TouchableWithoutFeedback onPress={() => {
                Keyboard.dismiss();
            }}>
                <View style={styles.container}>
                    <View style={styles.logoContainer}>
                        <Image source={require('../../assets/react_logo.png')} style={styles.logo}></Image>
                    </View>
                    <View style={styles.registerContainer}>
                        <TextInput
                            style={styles.textInputBox}
                            label='First Name'
                            value={this.state.firstname}
                            placeholder='e.g. Wade'
                            mode='outlined'
                            selectionColor={Colors.primary}
                            underlineColor={Colors.primary}
                            theme={{
                                colors: {
                                    primary: Colors.primary,
                                },
                            }}
                            onChangeText={firstname => this.setState({ firstname: firstname })} />
                        <TextInput
                            style={styles.textInputBox}
                            label='Last Name'
                            value={this.state.lastname}
                            placeholder='e.g. Wilson'
                            mode='outlined'
                            selectionColor={Colors.primary}
                            underlineColor={Colors.primary}
                            theme={{
                                colors: {
                                    primary: Colors.primary,
                                },
                            }}
                            onChangeText={lastname => this.setState({ lastname: lastname })} />
                        <TextInput
                            style={styles.textInputBox}
                            label='Username'
                            value={this.state.username}
                            placeholder='e.g. wwilson1991'
                            mode='outlined'
                            selectionColor={Colors.primary}
                            underlineColor={Colors.primary}
                            theme={{
                                colors: {
                                    primary: Colors.primary,
                                },
                            }}
                            onChangeText={username => this.setState({ username: username })} />
                        <TextInput
                            style={styles.textInputBox}
                            label='Password'
                            value={this.state.password}
                            secureTextEntry={true}
                            placeholder='e.g. 9#7@P+d3N%'
                            mode='outlined'
                            selectionColor={Colors.primary}
                            underlineColor={Colors.primary}
                            theme={{
                                colors: {
                                    primary: Colors.primary,
                                },
                            }}
                            onChangeText={password => this.setState({ password: password })} />
                    </View>
                    <View style={styles.buttonWrapper}>
                        <Button
                            onPress={this.registerButtonPressHandler}
                            mode='contained'
                            color={Colors.primary}>
                                Register
                        </Button>
                    </View>
                    <View style={styles.loginWrapper}>
                        <Text>
                            Already have an account?&nbsp;
                            <Text style={styles.loginText} onPress={() => {this.props.navigation.navigate('Login');}}>
                                Log in
                            </Text>
                        </Text>
                    </View>
                </View>
            </TouchableWithoutFeedback>
        )
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Colors.secondary,
        alignItems: 'center',
        justifyContent: 'center',
    },

    logoContainer: {
        flex: 6,
        alignItems: 'center',
        justifyContent: 'center',
    },

    logo: {
        width: 160,
        height: 160,
    },

    registerContainer: {
        flex: 2,
        justifyContent: 'center',
        width: 250,
        height: 153,
    },

    textInputBox: {
        paddingTop: 5,
        paddingBottom: 5,
    },

    buttonWrapper: {
        flex: 3,
        justifyContent: 'flex-end',
    },

    loginWrapper: {
        flex: 2,
        paddingTop: 15,
    },

    loginText: {
        color: Colors.primary,
    },
});
EOF

    # Writing Home.js
    echo -e "Writing Home.js..."
    cat <<EOF > Home.js
import React, { Component } from 'react';
import { StyleSheet, View, Text } from 'react-native';
import Colors from '../constants/Colors';

export default class Home extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <View style={styles.container}>
                <Text>
                    Home Tab!
                </Text>
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Colors.secondary,
        alignItems: 'center',
        justifyContent: 'center',
    },
});
EOF

    # Writing Profile.js
    echo -e "Writing Profile.js..."
    cat <<EOF > Profile.js
import React, { Component } from 'react';
import { StyleSheet, View, Text } from 'react-native';
import Colors from '../constants/Colors';

export default class Home extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <View style={styles.container}>
                <Text>
                    Profile Tab!
                </Text>
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Colors.secondary,
        alignItems: 'center',
        justifyContent: 'center',
    },
});
EOF

    # Writing Notifications.js
    echo -e "Writing Notifications.js..."
    cat <<EOF > Notifications.js
import React, { Component } from 'react';
import { StyleSheet, View, Text } from 'react-native';
import Colors from '../constants/Colors';

export default class Home extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <View style={styles.container}>
                <Text>
                    Notifications Tab!
                </Text>
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Colors.secondary,
        alignItems: 'center',
        justifyContent: 'center',
    },
});
EOF

    # Writing Settings.js
    echo -e "Writing Settings.js..."
    cat <<EOF > Settings.js
import React, { Component } from 'react';
import { StyleSheet, View, Text } from 'react-native';
import Colors from '../constants/Colors';

export default class Home extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <View style={styles.container}>
                <Text>
                    Settings Tab!
                </Text>
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Colors.secondary,
        alignItems: 'center',
        justifyContent: 'center',
    },
});
EOF

    cd ../constants
    # Writing Colors.js
    echo -e "Writing Colors.js..."
    cat <<EOF > Colors.js
const primary = '#61dafb';
const secondary = '#ccd9ff';
const tabIcon = '#000000';

export default {
    primary,
    secondary,
    tabIcon,
}
EOF

    cd ../../assets
    # Download react logo
    echo -e "Downloading react logo"
    curl https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/React-icon.svg/1280px-React-icon.svg.png > react_logo.png

    echo -e "\nFinished creating react native project!"
    echo -e "Try navigating into app directory and running"
    echo -e "\"npm start\" or \"expo start\""
}

print_usage() {
    echo -e "\nUsage:"
    echo -e "\tcreateboilerplate.sh [OPTIONS] <framework_name>"
    echo -e "\nOptions:"
    echo -e "\t-p = project name (Django only)"
    echo -e "\t-a = app name"
    echo -e "\t-d,  setup SQLite3 database (Flask only)"
    echo -e "\t-h,  show help"
    echo -e "\nSupported frameworks:"
    echo -e "\t- Django"
    echo -e "\t- Flask"
    echo -e "\t- PyQt5"
    echo -e "\t- React Native"
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

PYTHON_CMD="python3"
which $PYTHON_CMD >/dev/null 2>&1
if [[ "$?" -ne 0 ]]; then
    PYTHON_CMD="python"
fi

PIP_CMD="pip3"
which $PIP_CMD >/dev/null 2>&1
if [[ "$?" -ne 0 ]]; then
    PIP_CMD="pip"
fi

PROJ_NAME="myproject"
APP_NAME="myapp"

while getopts "p:a:dh" flag; do
    case "$flag" in
        p)  PROJ_NAME=${OPTARG};;
        a)  APP_NAME=${OPTARG};;
        d)  SETUP_DATABASE="TRUE";;
        h)  print_usage
            exit 0;;
        *)  exit 128;;
    esac
done

APP=${@:$OPTIND:1}
if [ -z $APP ]; then
    print_usage
    exit 128
fi
APP=${APP,,}

case "$APP" in
    flask)          flask_boilerplate;;
    django)         django_boilerplate;;
    pyqt5)          pyqt5_boilerplate;;
    reactnative)    reactnative_boilerplate;;
    *)              print_usage;;
esac