import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'YOUR_APP_ID_HERE';
  final keyClientKey = 'YOUR_CLIENT_KEY_HERE';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MaterialApp(
    home: HomePage(),
  ));
}

enum RegistrationType { GENRE, PUBLISHER, AUTHOR }

extension RegistrationTypeMembers on RegistrationType {
  String get description => const {
        RegistrationType.GENRE: 'Genre',
        RegistrationType.PUBLISHER: 'Publisher',
        RegistrationType.AUTHOR: 'Author',
      }[this];

  String get className => const {
        RegistrationType.GENRE: 'Genre',
        RegistrationType.PUBLISHER: 'Publisher',
        RegistrationType.AUTHOR: 'Author',
      }[this];
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Associations'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Container(
                height: 200,
                child: Image.network(
                    'https://blog.back4app.com/wp-content/uploads/2017/11/logo-b4a-1-768x175-1.png'),
              ),
              Center(
                child: const Text('Flutter on Back4app - Associations',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 50,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, backgroundColor: Colors.blue),
                  child: Text('Add Genre'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationPage(
                              registrationType: RegistrationType.GENRE)),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 50,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, backgroundColor: Colors.blue),
                  child: Text('Add Publisher'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationPage(
                              registrationType: RegistrationType.PUBLISHER)),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 50,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, backgroundColor: Colors.blue),
                  child: Text('Add Author'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationPage(
                              registrationType: RegistrationType.AUTHOR)),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 50,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, backgroundColor: Colors.blue),
                  child: Text('Add Book'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookPage()),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 50,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, backgroundColor: Colors.blue),
                  child: Text('List Publisher/Book'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookListPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class RegistrationPage extends StatefulWidget {
  final RegistrationType registrationType;

  RegistrationPage({@required this.registrationType});
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  RegistrationType get registrationType => widget.registrationType;

  final controller = TextEditingController();

  void addRegistration() async {
    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
            'Empty ${registrationType.description}',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.blue,
        ));
      return;
    }
    await doSaveRegistration(controller.text.trim());
    controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New ${registrationType.description}'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      controller: controller,
                      decoration: InputDecoration(
                          labelText: "New ${registrationType.description}",
                          labelStyle: TextStyle(color: Colors.blue)),
                    ),
                  ),
                  ElevatedButton(child: Text("ADD"), onPressed: addRegistration)
                ],
              )),
          Expanded(
              child: FutureBuilder<List<ParseObject>>(
                  future: doListRegistration(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator()),
                        );
                      default:
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error..."),
                          );
                        } else {
                          return ListView.builder(
                              padding: EdgeInsets.only(top: 10.0),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                      snapshot.data[index].get<String>('name')),
                                );
                              });
                        }
                    }
                  }))
        ],
      ),
    );
  }

  Future<List<ParseObject>> doListRegistration() async {
    QueryBuilder<ParseObject> queryRegistration =
        QueryBuilder<ParseObject>(ParseObject(registrationType.className));
    final ParseResponse apiResponse = await queryRegistration.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results;
    } else {
      return [];
    }
  }

  Future<void> doSaveRegistration(String name) async {
    final registration = ParseObject(registrationType.className)
      ..set('name', name);
    await registration.save();
  }
}

class BookPage extends StatefulWidget {
  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final controllerTitle = TextEditingController();
  final controllerYear = TextEditingController();
  ParseObject genre;
  ParseObject publisher;
  List<ParseObject> authors;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              autocorrect: false,
              controller: controllerTitle,
              decoration: InputDecoration(
                  labelText: 'Title', border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              autocorrect: false,
              keyboardType: TextInputType.number,
              controller: controllerYear,
              maxLength: 4,
              decoration: InputDecoration(
                  labelText: 'Year', border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'Publisher',
              style: TextStyle(fontSize: 16),
            ),
            CheckBoxGroupWidget(
              registrationType: RegistrationType.PUBLISHER,
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  publisher = value.first;
                } else {
                  publisher = null;
                }
              },
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'Genre',
              style: TextStyle(fontSize: 16),
            ),
            CheckBoxGroupWidget(
              registrationType: RegistrationType.GENRE,
              onChanged: (value) {
                print(value);
                if (value != null && value.isNotEmpty) {
                  genre = value.first;
                } else {
                  genre = null;
                }
              },
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'Author',
              style: TextStyle(fontSize: 16),
            ),
            CheckBoxGroupWidget(
              multipleSelection: true,
              registrationType: RegistrationType.AUTHOR,
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  authors = value;
                } else {
                  authors = null;
                }
              },
            ),
            SizedBox(
              height: 24,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 50,
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white, backgroundColor: Colors.blue),
                child: Text('Save Book'),
                onPressed: () async {
                  if (controllerTitle.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(
                          'Empty Book Title',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.blue,
                      ));
                    return;
                  }

                  if (controllerYear.text.trim().length != 4) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(
                          'Invalid Year',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.blue,
                      ));
                    return;
                  }

                  if (genre == null) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(
                          'Select Genre',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.blue,
                      ));
                    return;
                  }

                  if (publisher == null) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(
                          'Select Publisher',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.blue,
                      ));
                    return;
                  }

                  if (authors == null) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(
                          'Select Author',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.blue,
                      ));
                    return;
                  }

                  doSaveBook();

                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text(
                        'Book save',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.blue,
                    ));
                  await Future.delayed(Duration(seconds: 3));
                  Navigator.of(context).pop();
                },
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> doSaveBook() async {}
}

class CheckBoxGroupWidget extends StatefulWidget {
  final Function(List<ParseObject>) onChanged;
  final RegistrationType registrationType;
  final bool multipleSelection;

  const CheckBoxGroupWidget(
      {this.registrationType, this.onChanged, this.multipleSelection = false});

  @override
  _CheckBoxGroupWidgetState createState() => _CheckBoxGroupWidgetState();
}

class _CheckBoxGroupWidgetState extends State<CheckBoxGroupWidget> {
  List<ParseObject> selectedItems = [];
  List<ParseObject> items = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    doListRegistration(widget.registrationType).then((value) {
      if (value != null) {
        setState(() {
          items = value;
          isLoading = false;
        });
      }
    });
  }

  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Container(
            width: 100, height: 100, child: CircularProgressIndicator()),
      );
    }

    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(top: 8.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return checkBoxTile(items[index]);
        });
  }

  Future<List<ParseObject>> doListRegistration(
      RegistrationType registrationType) async {
    QueryBuilder<ParseObject> queryRegistration =
        QueryBuilder<ParseObject>(ParseObject(registrationType.className));
    final ParseResponse apiResponse = await queryRegistration.query();

    if (apiResponse.success && apiResponse.results != null) {
      items.addAll(apiResponse.results.map((e) => e as ParseObject));
      return apiResponse.results;
    } else {
      return [];
    }
  }

  Widget checkBoxTile(ParseObject data) {
    return CheckboxListTile(
      title: Text(data.get<String>('name')),
      value: selectedItems.contains(data),
      onChanged: (value) {
        if (value) {
          setState(() {
            if (!widget.multipleSelection) {
              selectedItems.clear();
            }
            selectedItems.add(data);
            widget.onChanged(selectedItems);
          });
        } else {
          setState(() {
            selectedItems.remove(data);
            widget.onChanged(selectedItems);
          });
        }
      },
    );
  }
}

class BookListPage extends StatefulWidget {
  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book List"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ParseObject>>(
          future: getPublisherList(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Container(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator()),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error..."),
                  );
                } else {
                  return ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        final varPublisher = snapshot.data[index];
                        final varName = varPublisher.get<String>('name');
                        return ExpansionTile(
                          title: Text(varName),
                          //tilePadding: Icon,
                          children: [BookTile(varPublisher.objectId)],
                        );
                      });
                }
            }
          }),
    );
  }

  Future<List<ParseObject>> getPublisherList() async {
    QueryBuilder<ParseObject> queryPublisher =
        QueryBuilder<ParseObject>(ParseObject('Publisher'));
    final ParseResponse apiResponse = await queryPublisher.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results;
    } else {
      return [];
    }
  }
}

class BookTile extends StatefulWidget {
  final String publisherId;

  BookTile(this.publisherId);

  @override
  _BookTileState createState() => _BookTileState();
}

class _BookTileState extends State<BookTile> {
  final controllerBook = TextEditingController();
  String get publisherId => widget.publisherId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ParseObject>>(
        future: getBookList(publisherId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Container(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator()),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text("Error..."),
                );
              } else {
                if (snapshot.hasData) {
                  return ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        final book = snapshot.data[index];
                        return ListTile(
                          trailing: Icon(Icons.arrow_forward_ios),
                          title: Text(book.get<String>('title')),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookDetailPage(book),
                                ));
                          },
                        );
                      });
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Center(
                          child: Text('Books not Found'),
                        ),
                      ],
                    ),
                  );
                }
              }
          }
        });
  }

  Future<List<ParseObject>> getBookList(String publisherId) async {
    QueryBuilder<ParseObject> queryBook =
        QueryBuilder<ParseObject>(ParseObject('Book'))
          ..whereEqualTo('publisher',
              (ParseObject('Publisher')..objectId = publisherId).toPointer())
          ..orderByAscending('title');
    final ParseResponse apiResponse = await queryBook.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results;
    } else {
      return [];
    }
  }
}

class BookDetailPage extends StatefulWidget {
  final ParseObject book;

  BookDetailPage(this.book);

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  ParseObject get book => widget.book;

  bool loadedData = false;
  bool isLoading = true;

  String bookTitle;
  int bookYear;
  String bookGenre;
  String bookPublisher;
  List<String> bookAuthors;

  @override
  void initState() {
    super.initState();
    getBookDetail(book).then((value) {
      {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(book.get<String>('title')),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: bodyWidget(),
        ));
  }

  Widget bodyWidget() {
    if (isLoading) {
      return Center(
        child: Container(
            width: 100, height: 100, child: CircularProgressIndicator()),
      );
    }

    if (!loadedData) {
      return Center(
          child: Text(
        'Error retrieving data ...',
        style: TextStyle(fontSize: 18, color: Colors.red),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Title: $bookTitle'),
        SizedBox(
          height: 8,
        ),
        Text('Year: $bookYear'),
        SizedBox(
          height: 8,
        ),
        Divider(),
        Text('Genre: $bookGenre'),
        SizedBox(
          height: 8,
        ),
        Divider(),
        Text('Publisher: $bookPublisher'),
        SizedBox(
          height: 8,
        ),
        Divider(),
        Text('Authors'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: bookAuthors.map((a) => Text(a)).toList(),
        )
      ],
    );
  }

  Future getBookDetail(ParseObject book) async {}
}
