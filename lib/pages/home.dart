import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';



class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    // Band(id: '1', name: 'Metalica', votes: 5 ),
    // Band(id: '2', name: 'Queen', votes: 1 ),
    // Band(id: '3', name: 'Heroes del solencio', votes: 2 ),
    // Band(id: '4', name: 'Bon Jovi', votes: 3 ),
  ];

  @override
  void initState() {

    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands( dynamic payload ) {
    bands = ( payload as List)
        .map( (band) => Band.fromMap(band) )
        .toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNAmes', style: TextStyle(color: Colors.black87) ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only( right: 10 ),
            child: ( socketService.socket.connected  ) //Solucion Profe: socketService.serverStatus == ServerStatus.Online 
            ? Icon( Icons.check_circle, color: Colors.blue[300] )
            : const Icon( Icons.offline_bolt, color: Colors.red,),
          
          )
        ],
      ),
      body: Column(
        children: [

          _showGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: ( context, i ) => _bandTitle(bands[i])
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon( Icons.add),
      ),
   );
  }

  Widget _bandTitle(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ ) => socketService.emit( 'delete-band', { 'id': band.id } ), // Llamar el borrado del server
      background: Container(
        padding: const EdgeInsets.only( left: 8.0),
        color: Colors.redAccent,
        child: const Align(
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
            trailing: Text('${ band.votes }', style: const TextStyle( fontSize: 20) ),
            onTap: () => socketService.socket.emit('vote-band', { 'id': band.id } ),
      ),
    );
  }

  addNewBand() {

    final textController = TextEditingController();

    if ( Platform.isAndroid ) {
      // Android
      return showDialog(
        context: context,
        builder: ( _ ) => AlertDialog(
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
        )
      );
    }

    showCupertinoDialog(
      context: context,
      builder: ( _ ) => CupertinoAlertDialog(
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
      )
    );
  }

  void addBandToList( String name) {

    if ( name.length > 1 ) {
      // podemos agregar
        final socketService = Provider.of<SocketService>(context, listen: false);
        socketService.emit('add-band', { 'name': name } );
    }
    Navigator.pop(context);
  }

// Mostrar Grafica
Widget _showGraph() {


  Map<String, double> dataMap = {
'Bandas:': 0,
  };

  for (var band in bands) { 
    dataMap.putIfAbsent( band.name, () => band.votes.toDouble());
  }

  
  final colorList = <Color>[
    const Color.fromARGB(255, 246, 195, 100),
    const Color.fromARGB(255, 13, 134, 225),
    const Color.fromARGB(255, 243, 102, 151),
    const Color.fromARGB(255, 227, 111, 82),
    const Color.fromARGB(255, 101, 84, 228),
    const Color.fromARGB(255, 21, 138, 156),
    const Color.fromARGB(255, 82, 156, 21),
  ];

  return SizedBox(
    
    width: double.infinity,
    height: 200,
    child: PieChart(
      dataMap: dataMap,
      animationDuration: const Duration(milliseconds: 800),
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 2.5,
      colorList: colorList,
      initialAngleInDegree: 0,
      chartType: ChartType.ring,
      ringStrokeWidth: 32,
      // centerText: "HYBRID",
      legendOptions: const LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: false,
        showChartValuesOutside: false,
        decimalPlaces: 0,
      ),
      // gradientList: ---To add gradient colors---
      // emptyColorGradient: ---Empty Color gradient---
    )
  );
}


}
