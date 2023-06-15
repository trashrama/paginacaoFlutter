import 'dart:io';
import 'dart:math';

void main() {
  int tamanho;

  List<int> listaF = [];
  List<String> entradasBrutas;
  List<int>? missAndHit;

  String algoritmoUsado;
  String? entrada = stdin.readLineSync();

  while (entrada == null || entrada.trim() == '') {
    entrada = stdin.readLineSync();
  }

  if (entrada.contains(',')) {
    entradasBrutas = entrada.split(',').toList();
  } else if (entrada.contains(' ')) {
    entradasBrutas = entrada.split(' ').toList();
  } else {
    entradasBrutas = [entrada];
  }

  if (entradasBrutas.isNotEmpty || entradasBrutas == []) {
    for (var item in entradasBrutas) {
      if (item.isNotEmpty) {
        try {
          int num = int.tryParse(item.trim())!;
          listaF.add(num);
        } catch (e) {
          print(
              'Insira apenas valores inteiros separados por espaço ou por vírgula!');
          listaF = [];
          break;
        }
      }
    }
  }

  while (true) {
    try {
      String aux = stdin.readLineSync()!;
      tamanho = int.tryParse(aux)!;
      break;
    } catch (e) {
      print('Digite um número inteiro, apenas!');
    }
  }

  algoritmoUsado = 'fifo';

  switch (algoritmoUsado) {
    case 'fifo':
      missAndHit = fifo(listaF, tamanho);
      break;
    case 'lfu':
      missAndHit = lfu(listaF, tamanho);
      break;
    case 'lru':
      missAndHit = lru(listaF, tamanho);
      break;
    case 'random':
      missAndHit = rand(listaF, tamanho);
      break;

    default:
  }
  print("Total de Hits: ${missAndHit![0]}\nTotal de Misses: ${missAndHit[1]}");
}

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
  List<int> listaMemoria = [];
  int hit = 0, miss = 0;

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
        int menor = 9223372036854775807;
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
