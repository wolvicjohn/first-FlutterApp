import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign In Account',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: AuthScreen(),
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color:
                Colors.transparent, // Set the background color to transparent
          ),
          child: child!,
        );
      },
    );
  }
}

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In Account'),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/huh.png',
                  height: 280,
                ),
                SizedBox(height: 20),
                LoginForm(),
                SizedBox(height: 20),
                GoogleSignInButton(),
                SizedBox(height: 20),
                FacebookSignInButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnotherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Account'),
      ),
      body: LoginForm(),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn();

      // Sign out the current user if there is one
      await _googleSignIn.signOut();

      // Perform the Google sign-in
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = authResult.user;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoggedInPage(user: user),
          ),
        );
      }
    } catch (error) {
      print("Google Sign-In Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ElevatedButton(
        onPressed: () => _handleGoogleSignIn(context),
        style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(255, 232, 240, 239),
          onPrimary: Colors.white,
          padding: EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.google, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'Sign in with Google',
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FacebookSignInButton extends StatelessWidget {
  Future<void> _handleFacebookSignIn(BuildContext context) async {
    try {
      FacebookAuth _facebookAuth = FacebookAuth.instance;

      // Log out the current user if there is one
      await _facebookAuth.logOut();

      // Perform the Facebook sign-in
      final result = await _facebookAuth.login();
      final AccessToken accessToken = result.accessToken!;

      if (accessToken != null) {
        AuthCredential credential =
            FacebookAuthProvider.credential(accessToken.token);

        UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = authResult.user;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoggedInPage(user: user),
          ),
        );
      }
    } catch (error) {
      print("Facebook Sign-In Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ElevatedButton(
        onPressed: () => _handleFacebookSignIn(context),
        style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(255, 59, 89, 152), // Facebook blue color
          onPrimary: Colors.white,
          padding: EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Sign in with Facebook',
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String loggedInEmail = '';

  void _login(BuildContext context) async {
    try {
      if (emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        loggedInEmail = emailController.text;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoggedInPage(email: loggedInEmail),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              height: 60, // Set the desired height
              child: Center(
                child: Text(
                  'Email and password cannot be empty.',
                  style: TextStyle(fontSize: 18), // Set the desired font size
                ),
              ),
            ),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      print("Firebase Sign-In Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in. Please check your credentials.'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _register(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Builder(
        builder: (BuildContext scaffoldContext) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(scaffoldContext),
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _register(scaffoldContext),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _register(BuildContext context) async {
    try {
      if (emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoggedInPage(email: emailController.text),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              height: 60, // Set the desired height
              child: Center(
                child: Text(
                  'Email and password cannot be empty.',
                  style: TextStyle(fontSize: 18), // Set the desired font size
                ),
              ),
            ),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      print("Firebase Registration Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to register. Please check your credentials.'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating, // Added to make it centered
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Builder(
        builder: (BuildContext scaffoldContext) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/huh.png',
                  height: 280,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _register(scaffoldContext),
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// cut
class LoggedInPage extends StatelessWidget {
  final String? email;
  final User? user;

  const LoggedInPage({Key? key, this.email, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello!'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthScreen(),
                ),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : AssetImage('assets/huh.png')
                            as ImageProvider<Object>?,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 3, 3, 3), // Text color
                    ),
                  ),
                  SizedBox(height: 10),
                  if (email != null)
                    Text(
                      'Email: $email',
                      style: TextStyle(
                        fontSize: 18,
                        color:
                            const Color.fromARGB(255, 20, 18, 18), // Text color
                      ),
                    )
                  else if (user != null)
                    Text(
                      'Email: ${user!.email}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 31, 26, 26), // Text color
                      ),
                    )
                  else
                    Text(
                      'Unable to fetch user information',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white, // Text color
                      ),
                    ),
                  SizedBox(height: 20),
                  // Add your image and text widgets below
                  SizedBox(height: 2), // Adjust this value to reduce space
                  Text(
                    'Recommended Shows',
                    style: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(255, 74, 74, 74), // Text color
                    ),
                  ),
                  Image.asset(
  'assets/1.png',
  height: 300,
  width: 300,
),
SizedBox(height: 2),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    for (int i = 0; i < 5; i++)
      Icon(
        Icons.star,
        color: Colors.amber,
        size: 20,
      ),
  ],
),

SizedBox(height: 1),
Text(
  'The Masterful Cat is depressed again today',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 35,
    color: Color.fromARGB(255, 74, 74, 74),
  ),
),
                  SizedBox(height: 2), // Adjust this value to reduce space
                  Text(
                    'The young employee Saku lives alone with her cat Yukichi, a feline as big as it is special. Yukichi is in fact extraordinarily intelligent, doing his utmost to take care of the house and of his mistress, who on the contrary is far from conscientious and has a habit of neglecting herself and her house.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 74, 74, 74), // Text color
                    ),
                  ),

                  // 2.png
Image.asset(
  'assets/2.png',
  height: 300,
  width: 300,
),
SizedBox(height: 2),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    for (int i = 0; i < 4; i++) // Adjust the rating as needed
      Icon(
        Icons.star,
        color: Colors.amber,
        size: 20,
      ),
    Icon(
      Icons.star_half,
      color: Colors.amber,
      size: 20,
    ),
  ],
),
SizedBox(height: 1),
Text(
  'One Piece',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 35,
    color: Color.fromARGB(255, 74, 74, 74),
  ),
),
                  SizedBox(height: 2), // Adjust this value to reduce space
                  Text(
                    'A long-running Japanese anime and manga series created by Eiichiro Oda. It follows the adventures of Monkey D. Luffy and his diverse crew of pirates as they search for the legendary treasure known as One Piece. The series is known for its rich world-building, memorable characters, and epic battles.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 74, 74, 74), // Text color
                    ),
                  ),

                  // 3.png
Image.asset(
  'assets/3.png',
  height: 300,
  width: 300,
),
SizedBox(height: 1),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    for (int i = 0; i < 3; i++) // Adjust the rating as needed
      Icon(
        Icons.star,
        color: Colors.amber,
        size: 20,
      ),
    Icon(
      Icons.star_half,
      color: Colors.amber,
      size: 20,
    ),
  ],
),
SizedBox(height: 1),
Text(
  'Frieren Beyond Journeys End',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 35,
    color: Color.fromARGB(255, 74, 74, 74),
  ),
),
                  SizedBox(height: 2), // Adjust this value to reduce space
                  Text(
                    'a manga series written and illustrated by Kanehito Yamada. The story revolves around Frieren, an elf who embarks on a journey to defeat a powerful demon lord. However, the twist is that Frieren is an immortal who has witnessed centuries of history. The series explores themes of immortality, friendship, and the passage of time.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 74, 74, 74), // Text color
                    ),
                  ),
                  

                  // 4.png
Image.asset(
  'assets/4.png',
  height: 300,
  width: 300,
),
SizedBox(height: 1),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    for (int i = 0; i < 5; i++)
      Icon(
        Icons.star,
        color: Colors.amber,
        size: 20,
      ),
  ],
),
SizedBox(height: 1),
Text(
  'Jujutsu Kaisend',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 35,
    color: Color.fromARGB(255, 74, 74, 74),
  ),
),

                  SizedBox(height: 2), // Adjust this value to reduce space
                  Text(
                    'a Japanese anime and manga series written and illustrated by Gege Akutami. It follows the story of Yuji Itadori, a high school student with extraordinary physical abilities, who gets involved in the world of curses and jujutsu sorcery. The series is known for its intense battles, unique magic system, and compelling characters.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 74, 74, 74), // Text color
                    ),
                  ),

                  // 5.png
Image.asset(
  'assets/5.png',
  height: 300,
  width: 300,
),
SizedBox(height: 1),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    for (int i = 0; i < 4; i++) // Adjust the rating as needed
      Icon(
        Icons.star,
        color: Colors.amber,
        size: 20,
      ),
    Icon(
      Icons.star_border,
      color: Colors.amber,
      size: 20,
    ),
  ],
),
SizedBox(height: 1),
Text(
  'Spongebob Squarepants',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 35,
    color: Color.fromARGB(255, 74, 74, 74),
  ),
),
                  SizedBox(height: 2), // Adjust this value to reduce space
                  Text(
                    'an animated television series created by marine science educator and animator Stephen Hillenburg. The show chronicles the adventures of SpongeBob SquarePants, a sea sponge who lives in a pineapple under the sea, and his friends in the underwater city of Bikini Bottom. The series is beloved for its humor, quirky characters, and lighthearted yet often surreal storytelling.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 74, 74, 74), // Text color
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
