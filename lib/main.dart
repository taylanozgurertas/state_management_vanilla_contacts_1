import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/new-contact': (context) => const NewContactsView(),
      },
    );
  }
}

class Contact {
  final String id; //we will use Uuid package thats why we created this
  final String name;

  Contact({required this.name}) : id = const Uuid().v4(); //Uuid use
}

/*
okay so ValueNotifier is holding the thing that we specify as List<Contact> 
and after that he's keeping that value and if the value completely change then its calling its notifyListener() method and its updateing the state 
so we extend our ContactBook class from ValueNotifier<List<Contact>> and after that
we specify the default thing with : super([]) which means its an emtpy list. 
after that for example in our add function now we can use value.add(contact) but this won't change the whole value its not completely changing so we have to
tell the ValueNotifier that it changed. we can add notifyListener(); manually after that code.
 */

class ContactBook extends ValueNotifier<List<Contact>> {
  //this is a SINGLETON STRUCTURE example a named constructor with a static final private thing + factory thing.
  ContactBook._sharedInstance()
      : super(
            []); //we extend the ContactBook class from ValueNotifier<thetypethatweareworking> and here with super([]) we said that our default data will be an empty list when its initialize has no context to manage.
  static final ContactBook _shared = ContactBook._sharedInstance();
  factory ContactBook() => _shared;
  //********************** */

  //final List<Contact> _contacts = [];

  //length getter it gets the contacts's length
  int get length => value.length; //value is coming from ValueNotifier and it means its List<Contact> thing

  //add function
  void add({required Contact contact}) {
    final contacts = value;
    contacts.add(contact);
    notifyListeners();
  }

  //remove function
  void remove({required Contact contact}) {
    final contacts = value;
    if (contacts.contains(contact)) {
      contacts.remove(contact);
      notifyListeners();
    }
  }

  //this function will return contact[givenIndex] if there is enough length in the list
  Contact? contact({required int atIndex}) {
    return value.length > atIndex ? value[atIndex] : null;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  //we need to use ValueListenableBuilder :)

  @override
  Widget build(BuildContext context) {
    final contactBook = ContactBook(); //it was a singleton though its not going to be initialize over and over again
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello World'),
      ),
      body: ValueListenableBuilder(
        //this builder has a valueListenable. it will trigger any changes to inside that class(We give that class as ContactBook()) will trigger this builder
        valueListenable: ContactBook(),
        builder: (context, value, child) {
          //its classic thing that ValueListenableBuilder has this

          final contacts = value as List<Contact>; //this value is the value in the ContactBook()

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Dismissible(
                //dismissible is a good widget

                onDismissed: (direction) {
                  ContactBook().remove(contact: contact);
                },
                key: ValueKey(
                    contact.id), //dismissible needs a key which is unique we have that key. we can give it like this
                child: Material(
                  //its for design of course not necessarily
                  color: Colors.white,
                  elevation: 6.0,
                  child: ListTile(
                    title: Text(contact.name),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed('/new-contact');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NewContactsView extends StatefulWidget {
  const NewContactsView({super.key});

  @override
  State<NewContactsView> createState() => _NewContactsViewState();
}

class _NewContactsViewState extends State<NewContactsView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add a new contact"),
        ),
        body: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Enter a new contact name here...',
              ),
            ),
            TextButton(
                onPressed: () {
                  final contact = Contact(name: _controller.text);
                  ContactBook().add(contact: contact);
                  Navigator.of(context).pop();
                },
                child: const Text("Add contact")),
          ],
        ));
  }
}
