import 'package:flutter/material.dart';
import 'package:pr_11/models/api_service.dart';
import 'package:pr_11/components/item.dart';
import 'package:pr_11/components/note_card.dart';
import 'package:pr_11/models/note.dart';
import 'package:pr_11/models/cart.dart';
import 'fav_page.dart';
import 'prof_page.dart';
import 'create_note_page.dart';
import 'basket.dart';
import 'edit_page.dart';
import 'note_page.dart';



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Note> notes = [];
  List<Note> favorites = [];
  List<CartItem> cart = [];
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      List<Note> products = await apiService.getProducts();
      setState(() {
        notes = products;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки товаров: $e')),
      );
    }
  }

  void _addNote(Note note) {
    setState(() {
      notes.add(note);
    });
  }

  void _editNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPage(
          note: note,
          onUpdate: (updatedNote) {
            setState(() {
              int index = notes.indexWhere((n) => n.id == updatedNote.id);
              if (index != -1) {
                notes[index] = updatedNote;
              }
            });
          },
        ),
      ),
    );
  }

  void _addToCart(Note note) {
    setState(() {
      cart.add(CartItem(note: note));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${note.title} добавлен в корзину')),
    );
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotePage(
          note: note,
          onUpdate: (updatedNote) {
            setState(() {
              int index = notes.indexWhere((n) => n.id == updatedNote.id);
              if (index != -1) {
                notes[index] = updatedNote; // Обновляем заметку
              }
            });
          },
        ),
      ),
    );
  }

  void _deleteNote(int id) {
    setState(() {
      notes.removeWhere((note) => note.id == id);
    });
  }


  void _toggleFavorite(Note note) {
    setState(() {
      if (favorites.contains(note)) {
        favorites.remove(note);
        note.isFav = false;
      } else {
        favorites.add(note);
        note.isFav = true;
      }
    });
  }

  void _removeFromFavorites(Note note) {
    setState(() {
      favorites.remove(note);
      note.isFav = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget getCurrentPage() {
      switch (_selectedIndex) {
        case 0:
          return _buildNoteList();
        case 1:
          return FavPage(
            favorites: favorites,
            onOpenNote: _openNote, // Передаем функцию для открытия
            onRemoveFromFavorites: _removeFromFavorites, // Передаем функцию для удаления
            onAddToCart: _addToCart,
          );
        case 2:
          return ProfPage();
        default:
          return _buildNoteList();
      }
    }
    return Container(
      decoration: const BoxDecoration(
        color:  Color.fromARGB(211, 181, 169, 165), // Здесь можно установить свой цвет фона
      ),


      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Лавочка'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateNotePage(onCreate: _addNote),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart), // Иконка корзины
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(cartItems: cart), // Передаем корзину
                  ),
                );
              },
            ),
          ],
        ),

        body: getCurrentPage(),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Избранные',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color.fromARGB(211, 181, 169, 165),
          unselectedItemColor: const Color.fromARGB(211, 193, 193, 193),
        ),
      ),
    );
  }

  Widget _buildNoteList() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),

      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: (note) => _openNote(note), // Передаем note
          onToggleFavorite: (note) {
            _toggleFavorite(note);
          },
          onAddToCart: (note) => _addToCart(note), // Передаем note
        );
      },
    );
  }
}