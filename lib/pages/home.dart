import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/models/band.dart';



class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: '1', name: 'Metalica', votes: 5 ),
    Band(id: '2', name: 'Queen', votes: 1 ),
    Band(id: '3', name: 'Heroes del solencio', votes: 2 ),
    Band(id: '4', name: 'Bon Jovi', votes: 3 ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNAmes', style: TextStyle(color: Colors.black87) ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: ( context, i ) => _bandTitle(bands[i])
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon( Icons.add),
      ),
   );
  }

  Widget _bandTitle(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print('direction: $direction');
        // Llamar el borrado del server
      },
      background: Container(
        padding: EdgeInsets.only( left: 8.0),
        color: Colors.redAccent,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle(color: Colors.white) ),
        ),

      ),
      child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text( band.name.substring(0,2)),
            ),
            title: Text( band.name),
            trailing: Text('${ band.votes }', style: const TextStyle( fontSize: 20)),
            onTap: () {
              print(band.name);
            },
          ),
    );
  }

  addNewBand() {

    final textController = TextEditingController();

    if ( Platform.isAndroid ) {
      // Android
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('New band name:'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                textColor: Colors.blue,
                elevation: 5,
                onPressed: () => addBandToList( textController.text),
                child: const Text('Add'),
              )
            ],
          );
        },
      );
    }

    showCupertinoDialog(
      context: context,
      builder: ( _ ) {
        return CupertinoAlertDialog(
          title: const Text('New band name'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'),
              onPressed: () => addBandToList( textController.text),
            ),

            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Dismiss'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );

    
  }

  void addBandToList( String name) {

    if ( name.length > 1 ) {
      // podemos agregar
      bands.add( Band(id: DateTime.now().toString(), name: name, votes: 0 ) );
      setState(() {});
    }

    Navigator.pop(context);

  }


}