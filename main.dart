import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user.dart';
import 'package:email_validator/email_validator.dart';
import 'model/config.dart';

void main() {
  print("Server configuration: ${Configure.server}");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users CRUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/login': (context) => const Login(),
        '/userform': (context) => const UserForm(),
        '/userdetail': (context) => UserDetail(
            user: ModalRoute.of(context)!.settings.arguments as Users),
      },
    );
  }
}

/// Home ///
class Home extends StatefulWidget {
  static const routeName = "/";
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget mainBody = Container();
  List<Users> _userList = [];

  @override
  void initState() {
    super.initState();
    print("Home InitState - Configure.login: ${Configure.login}");
    if (Configure.login.id != null) {
      print("Calling getUsers()");
      getUsers();
    } else {
      print("User ID is null, not calling getUsers()");
    }
  }

  Widget showUsers() {
    print("Showing ${_userList.length} users");
    return ListView.builder(
      itemCount: _userList.length,
      itemBuilder: (context, index) {
        Users user = _userList[index];
        return Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          child: Card(
            child: ListTile(
              title: Text("${user.fullname}"),
              subtitle: Text("${user.email}"),
              onTap: () {
                _showUserDetailDialog(context, user);
              },
              trailing: IconButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/userform',
                    arguments: user,
                  );
                },
                icon: const Icon(Icons.edit),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> getUsers() async {
  var url = Uri.http(Configure.server, "users");
  try {
    print("Fetching users from: $url");
    var resp = await http.get(url);
    print("Response status: ${resp.statusCode}");
    print("Response body: ${resp.body}");

    if (resp.statusCode == 200) {
      List<Users> users = usersFromJson(resp.body);
      print("Users fetched: ${users.length}");
      setState(() {
        _userList = users;
        mainBody = showUsers();
      });
    } else {
      print("Server responded with status code: ${resp.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch users: ${resp.statusCode}")),
      );
    }
  } catch (e) {
    print("Error fetching users: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      drawer: const SideMenu(),
      body: mainBody,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("FloatingActionButton pressed"); // Debug print
          Navigator.pushNamed(context, '/userform');
        },
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}

/// User Detail Page ///
class UserDetail extends StatelessWidget {
  final Users user;

  const UserDetail({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.fullname ?? 'User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Full Name: ${user.fullname}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${user.email}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Password: ${user.password}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

void _showUserDetailDialog(BuildContext context, Users user) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(user.fullname ?? 'User Details'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Full Name: ${user.fullname}'),
              Text('Email: ${user.email}'),
              Text('Password: ${user.password}'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

/// Side Menu ///
class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    String accountName = "Panupong Kittanart";
    String accountEmail = "deadhunter587@gmail.com";
    String accountUrl =
        "https://scontent-bkk1-2.xx.fbcdn.net/v/t39.30808-6/270049357_1265200223984237_2913968203246576789_n.jpg?_nc_cat=100&ccb=1-7&_nc_sid=a5f93a&_nc_eui2=AeHIAW8y-qGSLzKCLy8ucJXb-2ho-mNpI537aGj6Y2kjnQc4DXBIeCc6MXvRZIkNCHIlKUw7MtrdeQdYRgv1XEX1&_nc_ohc=SRvjUjp8g1wQ7kNvgHtE5b9&_nc_ht=scontent-bkk1-2.xx&oh=00_AYCdmnhXwAUh005ipKLN4otVkS_gsXAuP8PffbxIDa_CEw&oe=66D3AA50";
    Users user = Configure.login;

    if (user.id != null) {
      accountName = user.fullname ?? accountName;
      accountEmail = user.email ?? accountEmail;
    }

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(accountName),
            accountEmail: Text(accountEmail),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(accountUrl),
              backgroundColor: Colors.white,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pushNamed(context, Home.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Login"),
            onTap: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}

/// Login Page ///
class Login extends StatefulWidget {
  static const routeName = "/login";

  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final Users user = Users();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Login",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              emailInputField(),
              passwordInputField(),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .start, // Aligns items to the start of the row
                children: [
                  submitButton(),
                  const SizedBox(width: 10.0),
                  backButton(),
                  const SizedBox(width: 10.0),
                  registerLink(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget emailInputField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Email:",
        icon: Icon(Icons.email),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "This field is required";
        }
        if (!EmailValidator.validate(value)) {
          return "Invalid email format";
        }
        return null;
      },
      onSaved: (newValue) => user.email = newValue,
    );
  }

  Widget passwordInputField() {
    return TextFormField(
      obscureText: true,
      decoration: const InputDecoration(
        labelText: "Password:",
        icon: Icon(Icons.lock),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.password = newValue,
    );
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          login(user, context);
        }
      },
      child: const Text("Login"),
    );
  }

  Widget backButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text("Back"),
    );
  }

  Widget registerLink() {
    return InkWell(
      child: const Text("Sign Up"),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign Up Link Pressed")),
        );
      },
    );
  }
}

/// User Form ///
class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final Users user = Users();

  @override
  Widget build(BuildContext context) {
    Users? userToEdit = ModalRoute.of(context)!.settings.arguments as Users?;

    if (userToEdit != null) {
      user.id = userToEdit.id;
      user.fullname = userToEdit.fullname;
      user.email = userToEdit.email;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(userToEdit == null ? "New User" : "Edit User"),
      ),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "User Form",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              fullnameInputField(),
              emailInputField(),
              passwordInputField(),
              const SizedBox(height: 10.0),
              submitButton(),
              const SizedBox(width: 10.0),
              backButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget fullnameInputField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Fullname:",
        icon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.fullname = newValue,
    );
  }

  Widget emailInputField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Email:",
        icon: Icon(Icons.email),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "This field is required";
        }
        if (!EmailValidator.validate(value)) {
          return "Invalid email format";
        }
        return null;
      },
      onSaved: (newValue) => user.email = newValue,
    );
  }

  Widget passwordInputField() {
    return TextFormField(
      obscureText: true,
      decoration: const InputDecoration(
        labelText: "Password:",
        icon: Icon(Icons.lock),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.password = newValue,
    );
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          if (user.id == null) {
            addNewUser(user, context);
          } else {
            updateData(user, context);
          }
        }
      },
      child: const Text("Submit"),
    );
  }

  Widget backButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text("Back"),
    );
  }
}

Future<void> login(Users user, BuildContext context) async {
  var url = Uri.parse('http://172.16.43.216:3000/users');

  try {
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> users = jsonDecode(response.body);
      var loggedInUser = users.firstWhere(
          (u) => u['email'] == user.email && u['password'] == user.password,
          orElse: () => null);

      if (loggedInUser != null) {
        Configure.login = Users.fromJson(loggedInUser);
        print("User logged in successfully: ${Configure.login.fullname}");
        Navigator.pushReplacementNamed(context, Home.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Server error: ${response.statusCode} - ${response.reasonPhrase}")),
      );
    }
  } catch (e) {
    print("Error during login: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Network error")),
    );
  }
}

Future<void> addNewUser(Users user, BuildContext context) async {
  var url = Uri.parse('http://172.16.43.216:3000/users');

  try {
    var response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()));

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User created successfully")),
      );

      // Refresh user list on Home page
      Navigator.pop(context); // Close the current page
      Navigator.of(context)
          .popUntil((route) => route.isFirst); // Go back to Home page
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Ensure to pop to the Home route
      }
      Navigator.pushReplacementNamed(context, Home.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Failed to create user: ${response.statusCode} - ${response.reasonPhrase}")),
      );
    }
  } catch (e) {
    print("Error during user creation: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Network error")),
    );
  }
}

Future<void> updateData(Users user, BuildContext context) async {
  if (user.id == null) {
    print("User ID is null. Cannot update.");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User ID is missing")),
    );
    return;
  }

  var url = Uri.parse('http://172.16.43.216:3000/users/${user.id}');
  print("Update URL: $url");

  try {
    var response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User updated successfully")),
      );

      // Refresh user list on Home page
      Navigator.popUntil(
          context, (route) => route.settings.name == Home.routeName);
      // Optionally, navigate to Home again to ensure it reloads
      Navigator.pushReplacementNamed(context, Home.routeName);
    } else {
      print(
          "Failed to update user: ${response.statusCode} - ${response.reasonPhrase}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Failed to update user: ${response.statusCode} - ${response.reasonPhrase}"),
        ),
      );
    }
  } catch (e) {
    print("Error during user update: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Network error")),
    );
  }
}
