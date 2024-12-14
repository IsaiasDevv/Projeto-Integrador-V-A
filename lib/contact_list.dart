import 'package:flutter/material.dart';
import 'contact_form.dart';
import 'contact_database.dart';
import 'contact.dart';
import 'contact_details.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  String searchQuery = '';
  bool isLoading = true; // Controle de carregamento

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    await Future.delayed(const Duration(seconds: 2)); // Atraso maior para o carregamento (2 segundos)
    final data = await ContactDatabase.instance.readAllContacts();
    setState(() {
      contacts = data..sort((a, b) => a.name.compareTo(b.name)); // Ordenando os contatos por nome
      filteredContacts = contacts; // Inicializa com todos os contatos
      isLoading = false; // Indica que o carregamento terminou
    });
  }

  void _filterContacts(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredContacts = contacts; // Restaura a lista original quando não há pesquisa
      } else {
        filteredContacts = contacts
            .where((contact) => contact.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Agrupando os contatos pela primeira letra do nome
    Map<String, List<Contact>> groupedContacts = {};
    for (var contact in filteredContacts) {
      String firstLetter = contact.name[0].toUpperCase(); // Pegando a primeira letra
      if (!groupedContacts.containsKey(firstLetter)) {
        groupedContacts[firstLetter] = [];
      }
      groupedContacts[firstLetter]!.add(contact);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Contatos'),
        actions: [
          // Ícone de adicionar com transição personalizada
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const ContactFormScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); // Inicia da direita
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(position: offsetAnimation, child: child);
                    },
                  ),
                ).then((_) => _loadContacts());
              },
              child: Container(
                width: 31, // Define o tamanho do botão
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.green, // Cor do botão
                  shape: BoxShape.circle, // Faz o botão ficar redondo
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white, // Cor do ícone
                  size: 30, // Tamanho do ícone
                ),
              ),
            ),
          ),
          // Ícone de lupa para pesquisar
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: ContactSearchDelegate(
                    onQueryChanged: _filterContacts,
                    initialContacts: contacts,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Mostra um indicador de carregamento enquanto os dados são carregados
          : FadeTransition(
              opacity: AlwaysStoppedAnimation(1.0), // Opacidade constante para a animação suave
              child: Column(
                children: [
                  // Mostra o número de contatos encontrados
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${filteredContacts.length} contatos encontrados', // Exibe o número de contatos encontrados
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: groupedContacts.keys.isEmpty
                          ? [Center(child: Text('Nenhum contato encontrado'))] // Mensagem caso não haja contatos filtrados
                          : groupedContacts.keys.map((letter) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Exibe a letra do grupo
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      letter,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  // Exibe os contatos do grupo
                                  Column(
                                    children: groupedContacts[letter]!
                                        .map((contact) => Card(
                                              child: ExpansionTile(
                                                title: Text(contact.name),
                                                subtitle: Text(contact.phone),
                                                leading: const CircleAvatar(
                                                  backgroundColor: Colors.blue,
                                                  child: Icon(Icons.person, color: Colors.white),
                                                ),
                                                trailing: const Icon(Icons.arrow_drop_down),
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('Nome: ${contact.name}', style: const TextStyle(fontSize: 16)),
                                                              const SizedBox(height: 8),
                                                              Text('Telefone: ${contact.phone}', style: const TextStyle(fontSize: 16)),
                                                              const SizedBox(height: 8),
                                                              Text('E-mail: ${contact.email}', style: const TextStyle(fontSize: 16)),
                                                            ],
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(Icons.info, color: Colors.grey),
                                                          iconSize: 35,
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => ContactDetailsScreen(contact: contact),
                                                              ),
                                                            ).then((_) => _loadContacts());
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              );
                            }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ContactSearchDelegate extends SearchDelegate<String> {
  final Function(String) onQueryChanged;
  final List<Contact> initialContacts;

  ContactSearchDelegate({
    required this.onQueryChanged,
    required this.initialContacts,
  });

  @override
  String get searchFieldLabel => 'Buscar Contatos...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onQueryChanged(query); // Atualiza a lista de contatos
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Fecha a busca
        onQueryChanged(''); // Restaura a lista de contatos sem filtro
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('Encontre algum Contato'));
    }

    final results = initialContacts
        .where((contact) => contact.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return results.isEmpty
        ? Center(child: Text('Nenhum contato encontrado'))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${results.length} contatos encontrados', // Exibe o número de contatos encontrados
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView(
                  children: results.map((contact) {
                    return Card(
                      child: ExpansionTile(
                        title: Text(contact.name),
                        subtitle: Text(contact.phone),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        trailing: const Icon(Icons.arrow_drop_down),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Nome: ${contact.name}', style: const TextStyle(fontSize: 16)),
                                      const SizedBox(height: 8),
                                      Text('Telefone: ${contact.phone}', style: const TextStyle(fontSize: 16)),
                                      const SizedBox(height: 8),
                                      Text('E-mail: ${contact.email}', style: const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info, color: Colors.grey),
                                  iconSize: 35,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ContactDetailsScreen(contact: contact),
                                      ),
                                    ).then((_) => onQueryChanged('')); // Restaura a lista de contatos
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('Encontre algum Contato'));
    }

    final suggestions = initialContacts
        .where((contact) => contact.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return suggestions.isEmpty
        ? Center(child: Text('Nenhum contato encontrado'))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${suggestions.length} contatos encontrados', // Exibe o número de contatos encontrados nas sugestões
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView(
                  children: suggestions.map((contact) {
                    return Card(
                      child: ExpansionTile(
                        title: Text(contact.name),
                        subtitle: Text(contact.phone),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        trailing: const Icon(Icons.arrow_drop_down),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Nome: ${contact.name}', style: const TextStyle(fontSize: 16)),
                                      const SizedBox(height: 8),
                                      Text('Telefone: ${contact.phone}', style: const TextStyle(fontSize: 16)),
                                      const SizedBox(height: 8),
                                      Text('E-mail: ${contact.email}', style: const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info, color: Colors.grey),
                                  iconSize: 35,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ContactDetailsScreen(contact: contact),
                                      ),
                                    ).then((_) => onQueryChanged('')); // Restaura a lista de contatos
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
  }
}
