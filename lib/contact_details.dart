import 'package:flutter/material.dart';
import 'contact_database.dart';
import 'contact.dart';
import 'contact_form.dart';  // Para editar o contato

class ContactDetailsScreen extends StatelessWidget {
  final Contact contact;

  const ContactDetailsScreen({super.key, required this.contact});

  // Função para excluir o contato
  void _deleteContact(BuildContext context) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Contato'),
          content: Text(
            'Você tem certeza que deseja excluir o contato "${contact.name}"?\nTelefone: ${contact.phone}\nE-mail: ${contact.email}',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false); // Não excluir
              },
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmou a exclusão
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await ContactDatabase.instance.deleteContact(contact.id!);
      Navigator.pop(context); // Volta para a tela anterior após excluir
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Contato'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),  // Cor personalizada da AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${contact.name}', style: const TextStyle(fontSize: 18)),
            Text('Telefone: ${contact.phone}', style: const TextStyle(fontSize: 18)),
            Text('E-mail: ${contact.email}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão de editar com ícone abaixo
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Editar'),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // Navega para a tela de edição
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactFormScreen(contact: contact),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                // Botão de excluir com ícone abaixo
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Excluir'),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteContact(context),  // Excluir o contato
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
