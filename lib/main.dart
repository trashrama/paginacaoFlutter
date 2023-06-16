import 'package:flutter/material.dart';
import 'dart:math';

final _formKey = GlobalKey<FormState>(); // Chave global para o formulário

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  List<String> entradaPages = [];

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
    listaMemoria.clear();

    for (var pag in paginas) {
      if (listaMemoria.contains(pag)) {
        hit++;
      } else {
        miss++;
        if (listaMemoria.length <= tamanho) {
          listaMemoria.add(pag);
        } else {
          listaMemoria.removeAt(random.nextInt(listaMemoria.length));
          listaMemoria.add(pag);
        }
      }
    }
    listaMemoria.clear();
    return [hit, miss];
  }

  List<int> lru(List<int> paginas, int tamanho) {
    List<int> listaMemoria = [];
    int hit = 0, miss = 0;
    listaMemoria.clear();

    for (var pag in paginas) {
      int index = listaMemoria.indexOf(pag);
      if (index != -1) {
        hit++;
        listaMemoria.remove(index);
      } else {
        miss++;
      }
      if (listaMemoria.length < tamanho) {
        listaMemoria.insert(0, pag);
      } else {
        listaMemoria.removeAt(listaMemoria.length - 1);
        listaMemoria.insert(0, pag);
      }
    }
    listaMemoria.clear();
    return [hit, miss];
  }

  List<int> lfu(List<int> paginas, int tamanho) {
    Map<int, int> listaMemoria = {};
    int hit, miss;
    hit = miss = 0;

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
          listaMemoria[pag] = 1;
        }
      }
    }

    listaMemoria.clear();
    return [hit, miss];
  }

  List<int> fifo(List<int> paginas, int tamanho) {
    List<int> listaMemoria = [];
    int hit = 0, miss = 0;

    //checar se o meu item ta na lista.
    //se ele já estiver, é hit
    //se ele não estiver, é miss

    //se a memoria tiver cheia, tira o primeiro e add a pagina

    listaMemoria.clear();
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

    listaMemoria.clear();
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
      return 'HITS: ${missAndHit[0]} | MISSES: ${missAndHit[1]}';
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
        backgroundColor: const Color.fromARGB(255, 221, 214, 226),
        appBar: AppBar(
          toolbarHeight: 120,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          centerTitle: true,
          title: ValueListenableBuilder<String>(
            valueListenable: titleNotifier,
            builder: (context, value, child) {
              final titulo = dropdownValue;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 60,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontFamily: 'IBM_Plex_Sans',
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                      shadows: [
                        Shadow(
                          color: Color.fromARGB(
                              255, 122, 122, 122), // Cor da sombra
                          offset: Offset(0,
                              2), // Deslocamento da sombra (horizontal, vertical)
                          blurRadius: 10.0, // Raio do desfoque da sombra
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB967FF), Color(0xFFFF71CE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  )
                ],
              );
            },
          ),
        ),
        body: SingleChildScrollView(
            child: Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.6,
                padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(255, 122, 122, 122),
                      offset: Offset(0, 2),
                      blurRadius: 10.0,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text('Digite a sequência de páginas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                          )),
                      TextFormField(
                        style: const TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 1),
                          fontSize: 15,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w200,
                          fontStyle: FontStyle.normal,
                        ),
                        decoration: const InputDecoration(
                          labelText: '1, 2, 3, 4',
                          labelStyle: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.6),
                            fontFamily: 'Raleway',
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.italic,
                          ),
                          alignLabelWithHint: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color(0xFFFF71CE),
                          )),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 115, 17, 201)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            listaF.clear();
                            entradaPages.clear();
                            return 'Insira uma sequência de números!';
                          } else {
                            if (value.contains(',')) {
                              entradaPages = value.split(',').toList();
                            } else if (value.contains(' ')) {
                              entradaPages = value.split(' ').toList();
                            } else {
                              entradaPages = [value];
                            }

                            if (entradaPages.isNotEmpty || entradaPages == []) {
                              for (var item in entradaPages) {
                                if (item.isNotEmpty) {
                                  try {
                                    int num = int.tryParse(item.trim())!;
                                    if (num < 0) num = num * (-1);
                                    listaF.add(num);
                                  } catch (e) {
                                    listaF.clear();
                                    entradaPages.clear();
                                    return 'Insira APENAS valores inteiros separados por espaço ou por vírgula!';
                                  }
                                }
                              }
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                          height: 20), // separar os itens do container
                      const Text('Digite o tamanho do cache da memória',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 15,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                          )),
                      TextFormField(
                          style: const TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontFamily: 'Raleway',
                            fontSize: 15,
                            fontWeight: FontWeight.w200,
                            fontStyle: FontStyle.normal,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Um número inteiro',
                            labelStyle: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 0.6),
                              fontFamily: 'Raleway',
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                            ),
                            alignLabelWithHint: true,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: Color(0xFFFF71CE),
                            )),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 115, 17, 201)),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              listaF.clear();
                              entradaPages.clear();
                              return 'Insira apenas um número inteiro';
                            }

                            try {
                              tamCache = int.tryParse(value)!;
                              if (tamCache! < 1) {
                                listaF.clear();
                                entradaPages.clear();
                                return 'Não pode ser menor que 0';
                              }
                            } catch (e) {
                              listaF.clear();
                              entradaPages.clear();
                              return 'Insira apenas um número inteiro';
                            }
                            return null;
                          }),
                      DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        underline: Container(
                          height: 2,
                          color: const Color(0xFFFF71CE),
                        ),
                        dropdownColor: Colors.purple[50],
                        items: dropdownItems.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item,
                                style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  color: Colors.black,
                                )),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                            titleNotifier.value =
                                'Paginação: $newValue'; // Atualiza o valor do título
                          });
                        },
                        alignment: Alignment
                            .center, // Define o alinhamento do texto no centro verticalmente
                      ),
                      const SizedBox(height: 40),
                      FilledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            // Faça algo com os valores do formulário
                            if (listaF.isNotEmpty && tamCache! > 0) {
                              resultado = rodaAlgoritmo(
                                  lista: listaF,
                                  tamanho: tamCache!,
                                  algoritmoUsado: dropdownValue);
                            }
                            entradaPages.clear();
                            listaF.clear();

                            setState(() {}); // Atualiza o estado
                          }
                        },
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(const Size(
                              200, 60)), // Define a largura e altura mínimas
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 199, 87,
                                  160)), // Definindo a cor de fundo
                        ),
                        child: const Text('ENVIAR',
                            style: TextStyle(
                                fontSize: 16, // Tamanho do texto
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Raleway',
                                fontStyle: FontStyle.normal) // Peso da fonte
                            ),
                      ),

                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      if (resultado != null)
                        Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(
                                    255, 153, 46, 224), // Cor da borda
                                width: 1.0, // Espessura da borda
                              ),
                              borderRadius: BorderRadius.circular(
                                  3.0), // Raio do canto da borda
                            ),
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  resultado!,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ))),
                    ],
                  ),
                ),
              )),
        )));
  }
}
