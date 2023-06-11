import 'package:flutter/material.dart';
import 'dart:math';

final _formKey = GlobalKey<FormState>(); // Chave global para o formulário

void main() {
  runApp(const AlgDemo());
}

class AlgDemo extends StatelessWidget {
  const AlgDemo({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Algoritmos de Paginação: Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Algoritmos de Paginação: Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _entradaPages = [];

  int? tamCache;

  String dropdownValue = 'FIFO';

  List<int> listaF = [];

  String? resultado;

  late List<String> dropdownItems;
  late ValueNotifier<String> titleNotifier;

  List<int> rand(List<int> paginas, int tamanho) {
    List<int> listaMemoria = [];
    int hit = 0, miss = 0;

    var random = Random();

    for (var pag in paginas) {
      if (listaMemoria.contains(pag)) {
        hit++;
      } else {
        miss++;
        if (listaMemoria.length < tamanho) {
          listaMemoria.add(pag);
        } else {
          listaMemoria.removeAt(random.nextInt(listaMemoria.length));
          listaMemoria.add(pag);
        }
      }
    }
    return [hit, miss];
  }

  List<int> lru(List<int> paginas, int tamanho) {
    Map<int, int> listaMemoria = {};
    int hit = 0, miss = 0;
    int totalUsos = 0;
    for (var pag in paginas) {
      if (listaMemoria.containsKey(pag))
        hit++;
      else
        miss++;

      if (listaMemoria.length < tamanho) {
        listaMemoria[pag] = ++totalUsos;
      } else {
        int menor = 9999999999999;
        int? chaveMenor;
        listaMemoria.forEach((key, value) {
          if (value < menor) {
            menor = value;
            chaveMenor = key;
          }
        });

        listaMemoria.remove(chaveMenor);
        listaMemoria[pag] = ++totalUsos;
      }
    }

    return [hit, miss];
  }

  List<int> lfu(List<int> paginas, int tamanho) {
    Map<int, int> listaMemoria = {};
    int hit = 0, miss = 0;
    for (var pag in paginas) {
      if (listaMemoria.containsKey(pag)) {
        hit++;
        listaMemoria[pag] = listaMemoria[pag]! + 1;
      } else {
        miss++;

        if (listaMemoria.length < tamanho) {
          listaMemoria[pag] = 1;
        } else {
          int menor = 9999999999999;
          int? chaveMenor;
          listaMemoria.forEach((key, value) {
            if (value < menor) {
              menor = value;
              chaveMenor = key;
            }
          });

          listaMemoria.remove(chaveMenor);
        }
      }
    }

    return [hit, miss];
  }

  List<int> fifo(List<int> paginas, int tamanho) {
    List<int> listaMemoria = [];
    int hit = 0, miss = 0;

    //checar se o meu item ta na lista.
    //se ele já estiver, é hit
    //se ele não estiver, é miss

    //se a memoria tiver cheia, tira o primeiro e add a pagina

    for (var pag in paginas) {
      if (listaMemoria.contains(pag)) {
        hit++;
      } else {
        miss++;
        if (listaMemoria.length < tamanho) {
          listaMemoria.add(pag);
        } else {
          listaMemoria.removeAt(0);
          listaMemoria.add(pag);
        }
      }
    }
    return [hit, miss];
  }

  String rodaAlgoritmo(
      {required List<int> lista,
      required int tamanho,
      required String algoritmoUsado}) {
    List<int> missAndHit = [];

    algoritmoUsado = algoritmoUsado.toLowerCase().trim();

    switch (algoritmoUsado) {
      case 'fifo':
        missAndHit = fifo(lista, tamanho);
        break;
      case 'lfu':
        missAndHit = lfu(lista, tamanho);
        break;
      case 'lru':
        missAndHit = lru(lista, tamanho);
        break;
      case 'random':
        missAndHit = rand(lista, tamanho);
        break;

      default:
    }

    if (missAndHit.isNotEmpty) {
      print('hahaha sacanage');
      return 'Total de HITS: ${missAndHit[0]}\nTotal de MISSES: ${missAndHit[1]}';
    } else {
      return 'Ocorreu um erro ao executar o algoritmo de paginação.';
    }
  }

  @override
  void initState() {
    super.initState();
    dropdownItems = ['FIFO', 'LRU', 'LFU', 'RANDOM'];
    titleNotifier = ValueNotifier(widget.title);
  }

  @override
  void dispose() {
    titleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB967FF),
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: const Color(0xFFFF71CE),
        centerTitle: true,
        title: ValueListenableBuilder<String>(
          valueListenable: titleNotifier,
          builder: (context, value, child) {
            final titulo = 'Algoritmos de Paginação: $dropdownValue';
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  style:
                      const TextStyle(fontSize: 60, color: Color(0xFFFFFB96)),
                ),
                const Text(
                  'voce um dia me paga',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'IBM Plex Sans',
                      color: Color(0xFF26D493)),
                ),
              ],
            );
          },
        ),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Digite a sequência de páginas:'),
              TextFormField(
                decoration: const InputDecoration(labelText: '1, 2, 3, 4'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insira uma sequência de números separados por espaço, ou vírgula!';
                  } else {
                    if (value.contains(',')) {
                      _entradaPages = value.split(',').toList();
                    } else if (value.contains(' ')) {
                      _entradaPages = value.split(' ').toList();
                    } else {
                      _entradaPages = [value];
                    }

                    if (_entradaPages.isNotEmpty || _entradaPages == []) {
                      for (var item in _entradaPages) {
                        if (item.isNotEmpty) {
                          try {
                            int num = int.tryParse(item.trim())!;
                            listaF.add(num);
                          } catch (e) {
                            listaF.clear();
                            return 'Insira APENAS valores inteiros separados por espaço ou por vírgula!';
                          }
                        }
                      }
                    }
                  }
                  return null;
                },
              ),
              const Text('Digite o tamanho do cache da memória'),
              TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Um número inteiro'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Insira apenas um número inteiro';
                    }

                    try {
                      tamCache = int.tryParse(value)!;
                    } catch (e) {
                      return 'Insira apenas um número inteiro';
                    }
                    return null;
                  }),
              DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: dropdownItems.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                    titleNotifier.value =
                        'Algoritmos de Paginação: $newValue'; // Atualiza o valor do título
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Faça algo com os valores do formulário
                    resultado = rodaAlgoritmo(
                        lista: listaF,
                        tamanho: tamCache!,
                        algoritmoUsado: dropdownValue);
                  }
                },
                child: const Text('Enviar'),
              ),
              if (resultado != null)
                Text(
                  resultado!,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
