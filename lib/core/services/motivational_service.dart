import 'dart:math';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'gemini_tts_service.dart';

class MotivationalService {
  static final MotivationalService _instance = MotivationalService._internal();
  factory MotivationalService() => _instance;
  MotivationalService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final GeminiTTSService _geminiTTS = GeminiTTSService();
  final Random _random = Random();

  final List<String> _frases = [
    "Olá {nome}, hoje o dia está incrível! Vamos transformar cada desafio em uma vitória!",
    "Bom dia {nome}! Que bom te ver. Você é o motor desta empresa e hoje vamos brilhar!",
    "Oi {nome}, você é fera demais! Sua energia contagia os clientes e a nossa equipe.",
    "Seja bem-vindo, {nome}. Lembre-se: grandes metas são alcançadas com passos constantes.",
    "Olá {nome}! Preparado para bater recordes hoje? Eu confio plenamente no seu talento!",
    "O sucesso é a soma de pequenos esforços repetidos dia após dia. Vamos pra cima, {nome}!",
    "Você não está apenas operando um caixa, {nome}, está construindo uma carreira de sucesso!",
    "Atenção aos detalhes, {nome}, é o que separa os bons dos excepcionais. E você é excepcional!",
    "Um cliente satisfeito é o nosso melhor marketing. Vamos dar o nosso melhor hoje, {nome}!",
    "Sua dedicação é o que faz a nossa empresa ser gigante. Obrigado por estar aqui, {nome}!",
    "Mantenha o foco, a calma e o sorriso no rosto, {nome}. O resto a gente resolve juntos!",
    "Hoje é o dia perfeito para superar suas próprias marcas, {nome}! Vamos com tudo!",
    "Acredite em você como nós acreditamos. Você é essencial para o nosso sucesso, {nome}!",
    "Cada venda concluída é um passo a mais na sua evolução profissional, {nome}. Sucesso!",
    "Trabalhe com alegria e o resultado virá naturalmente. Tenha um dia fantástico, {nome}!",
    "A cada transação, você mostra sua competência. Tenha um dia brilhante, {nome}!",
    "Sua postura profissional é um exemplo para todos, {nome}. Vamos fazer história hoje!",
    "Não há limites para quem trabalha com propósito. O seu é voar alto, {nome}!",
    "Sorria, {nome}! O seu atendimento pode mudar o dia de alguém para melhor.",
    "A excelência não é um ato, mas um hábito. Continue sendo incrível, {nome}!",
    "Hoje o movimento será ótimo, {nome}, e sua agilidade será o nosso diferencial!",
    "Confiança é o primeiro segredo do sucesso. Confie no seu potencial, {nome}!",
    "Vamos atender com o coração e vender com a mente, {nome}. Bom trabalho!",
    "Você é a linha de frente do nosso sucesso. Orgulho de ter você aqui, {nome}!",
    "A disciplina é a ponte entre metas e realizações, {nome}. Mantenha o foco!",
    "Seja a melhor versão de si mesmo em cada atendimento de hoje, {nome}!",
    "Sua agilidade no caixa é impressionante. Vamos bater as metas, {nome}!",
    "O trabalho bem feito gera frutos duradouros, {nome}. Colha o sucesso hoje!",
    "Nossa missão é encantar. E você, {nome}, é mestre nisso!",
    "A cada 'obrigado' de um cliente, {nome}, sinta a missão cumprida. Vamos lá!",
    "O otimismo é o imã da felicidade, {nome}. Atraia coisas boas nesta jornada!",
    "Você é resiliente e capaz de superar qualquer correria hoje, {nome}. Força!",
    "Pequenas gentilezas fazem grandes fidelizações. Encante o próximo cliente, {nome}!",
    "O conhecimento se adquire com a prática. Cada venda é uma lição, {nome}!",
    "Sua presença ilumina este posto de trabalho, {nome}. Vamos fazer um dia espetacular!",
    "Transforme o 'não' em 'talvez' e o 'talvez' em venda. Você consegue, {nome}!",
    "A pressa é inimiga da perfeição, {nome}, mas a agilidade é amiga do lucro. Use-a!",
    "A gratidão pelo trabalho abre portas para novas oportunidades, {nome}. Sucesso!",
    "Você é o herói anônimo de cada venda concluída. Parabéns, {nome}!",
    "Encerre o dia com a sensação de dever cumprido e metas batidas, {nome}!",
    "O mundo pertence aos que se atrevem, {nome}. Ouse vender mais hoje!",
    "Cada cliente é uma nova história, {nome}. Faça parte da melhor delas!",
    "A persistência é o caminho do êxito. Continue firme, {nome}!",
    "Trabalhe como se o sucesso dependesse apenas de você hoje, {nome}!",
    "A qualidade do seu trabalho, {nome}, reflete a qualidade da sua mente.",
    "Seja grato por cada venda, {nome}, pequena ou grande. Todas importam!",
    "A agilidade no atendimento é a marca dos grandes profissionais como você, {nome}!",
    "Sua inteligência emocional é sua maior ferramenta no caixa, {nome}!",
    "Foque na solução, nunca no problema. Você é mestre nisso, {nome}!",
    "Acredite, {nome}: você é muito mais capaz do que imagina!",
    "O segredo de progredir é começar. Vamos com tudo nessa abertura, {nome}!",
    "A sua dedicação é o alicerce da nossa empresa. Obrigado, {nome}!",
    "Mantenha o entusiasmo, {nome}. Você é o cartão de visitas da loja!",
    "O bom atendimento é aquele que deixa saudades no cliente, né {nome}?",
    "Seja a luz que ilumina o dia de quem passa pelo seu caixa, {nome}!",
    "O fracasso é apenas a oportunidade de começar de novo com inteligência, {nome}!",
    "Sua competência é o que nos move, {nome}. Tenha uma jornada incrível!",
    "O sucesso não vem por acaso, {nome}, vem por preparo e suor. Bom trabalho!",
    "Cada sorriso dado ao cliente volta em dobro para você, {nome}.",
    "A organização do seu espaço, {nome}, reflete a clareza do seu trabalho.",
    "Sua rapidez é um espetáculo à parte, {nome}. Vamos bater os recordes!",
    "A confiança é a base de qualquer grande venda. Confie em você, {nome}!",
    "A vida é 10% o que acontece e 90% como você reage. Reaja com vitória, {nome}!",
    "Você é o protagonista da sua própria história profissional, {nome}. Brilhe!",
    "Nada é impossível para uma mente determinada. Vá e vença, {nome}!",
    "O entusiasmo é o combustível do sucesso. Mantenha o tanque cheio, {nome}!",
    "Sua voz transmite confiança, {nome}. Use-a para encantar e vender.",
    "A cada meta batida, uma nova porta se abre para o seu futuro, {nome}!",
    "Não espere por oportunidades, {nome}, crie-as em cada atendimento!",
    "O trabalho em equipe divide a carga e multiplica o sucesso, né {nome}?",
    "Você é um exemplo de resiliência e foco. Continue assim, {nome}!",
    "A maior recompensa pelo trabalho bem feito é a satisfação pessoal, {nome}!",
    "Transforme a rotina em uma jornada de descobertas e vendas, {nome}!",
    "A sua simpatia, {nome}, é a nossa melhor estratégia de vendas.",
    "O futuro depende do que fazemos no presente. Faça um grande presente, {nome}!",
    "Seja obstinado pelos seus sonhos, {nome}. O trabalho é o caminho.",
    "Sua agilidade economiza o tempo do cliente e gera valor para a loja, {nome}!",
    "A cada fechamento de venda, {nome}, sinta o poder da sua competência.",
    "O impossível é apenas uma opinião, {nome}. Prove o contrário hoje!",
    "Sua dedicação diária é o que constrói o nosso legado, {nome}.",
    "Foque nos seus pontos fortes e minimize as fraquezas. Você é gigante, {nome}!",
    "A cada 'bom dia' sincero, {nome}, você constrói uma ponte de confiança.",
    "Não pare até se orgulhar de si mesmo, {nome}. Estamos orgulhosos de você!",
    "O sucesso é gostar de si mesmo e do que você faz. Ame seu trabalho, {nome}!",
    "Sua energia renova o nosso ambiente. Obrigado pela parceria, {nome}!",
    "A paciência é uma virtude dos grandes negociadores, {nome}. Use-a bem.",
    "Cada cliente bem atendido é um tijolo na sua escada de sucesso, {nome}!",
    "Acredite na força dos seus sonhos e na potência do seu trabalho, {nome}.",
    "O sucesso é a soma de decisões corretas tomadas sob pressão, né {nome}?",
    "Seja o motivo do sorriso de alguém hoje, {nome}. Comece pelo caixa!",
    "A sua proatividade, {nome}, resolve problemas antes mesmo deles surgirem.",
    "O trabalho duro supera o talento quando o talento não trabalha duro, {nome}!",
    "Mantenha a mente aberta e o coração focado na meta, {nome}. Sucesso!",
    "Você é um ativo valioso para a nossa empresa. Valorize-se, {nome}!",
    "A cada venda adicional, {nome}, você mostra o seu poder de persuasão.",
    "O segredo do sucesso é a constância do propósito. Siga firme, {nome}!",
    "Sua agilidade mental é o que te faz ser um operador de elite, {nome}.",
    "Otimismo não é esperar o melhor, {nome}, é trabalhar pelo melhor sempre.",
    "A sua ética profissional é o que te diferencia no mercado, {nome}.",
    "Seja resiliente, {nome}: os ventos fortes só fazem as raízes serem mais fundas.",
    "O sucesso é o destino de quem não desiste no meio do caminho, {nome}!",
    "Sua capacidade de aprender rápido é o seu maior superpoder, {nome}!",
    "A cada atendimento, {nome}, você planta uma semente de fidelidade.",
    "O bom humor é o tempero que faz o trabalho ser prazeroso, né {nome}?",
    "Você é capaz de lidar com qualquer fluxo de clientes, {nome}. Confiança!",
    "A excelência é o resultado de se importar mais do que os outros, {nome}.",
    "Sua trajetória aqui está apenas começando. O céu é o limite, {nome}!",
    "O foco no cliente, {nome}, é o foco no nosso crescimento mútuo.",
    "Seja um mestre na arte de ouvir o cliente, {nome}. Ali estão as vendas.",
    "A sua rapidez é sinônimo de eficiência operacional, {nome}. Parabéns!",
    "O trabalho dignifica o homem e o sucesso premia o esforço, {nome}.",
    "Sua energia positiva atrai boas vendas e ótimos clientes, {nome}!",
    "A cada fechamento de caixa, {nome}, celebre suas conquistas do dia.",
    "Não olhe para o relógio, {nome}, faça o que ele faz: continue seguindo!",
    "O sucesso é caminhar de erro em erro sem perder o entusiasmo, {nome}!",
    "Você é a peça que faltava para o nosso time ser invencível, {nome}!",
    "A curiosidade de aprender algo novo hoje vai te levar longe, {nome}.",
    "Sua atenção evita erros e garante a nossa credibilidade, {nome}.",
    "Seja audaz em suas metas e humilde em sua busca por aprender, {nome}.",
    "O trabalho de hoje é o investimento para o seu sucesso de amanhã, {nome}.",
    "A cada dificuldade superada, {nome}, você se torna um profissional melhor.",
    "Sua proatividade é o combustível da nossa inovação diária, {nome}!",
    "O foco na excelência gera resultados extraordinários. Vá e faça, {nome}!",
    "Você tem o poder de transformar um dia comum em um dia épico, {nome}!",
    "A sua alegria ao atender é o que faz os clientes voltarem sempre, {nome}.",
    "O sucesso não é a chave para a felicidade, a felicidade é a chave do sucesso, {nome}.",
    "Mantenha a calma sob pressão e mostre a sua maestria, {nome}.",
    "A cada venda sugerida, {nome}, você aumenta o valor do seu trabalho.",
    "O futuro pertence àqueles que acreditam na beleza de seus sonhos, {nome}.",
    "Você é um guerreiro do dia a dia, {nome}. Respeitamos sua luta!",
    "A agilidade é a cortesia dos reis e a marca dos grandes caixas, né {nome}?",
    "Sua competência técnica é a base do nosso suporte operacional, {nome}.",
    "O sucesso é a soma de pequenos detalhes executados com perfeição, {nome}.",
    "Seja a mudança que você quer ver na sua carreira, {nome}. Comece agora!",
    "Sua dedicação é o ouro da nossa empresa. Continue brilhando, {nome}!",
    "Encerre este dia sabendo que você deu o seu melhor. Até amanhã, {nome}!",
  ];

  Future<void> speakMotivational(String nomeOperador) async {
    try {
      final fraseBase = _frases[_random.nextInt(_frases.length)];
      String mensagem = fraseBase.replaceAll("{nome}", nomeOperador);
      
      if (_random.nextInt(100) < 20) {
        mensagem += ". Sabe que eu te amo, né?";
      }

      // Tenta usar o Gemini AI (Voz de Elite)
      try {
        await _geminiTTS.speak(mensagem);
        return; // Sucesso, encerra aqui
      } catch (e) {
        print("Falha no Gemini, usando fallback estável: $e");
      }

      // FALLBACK: Motor Google (Se o Gemini falhar)
      final encodedMsg = Uri.encodeComponent(mensagem);
      final url = "https://translate.google.com/translate_tts?ie=UTF-8&q=$encodedMsg&tl=pt-br&client=tw-ob";

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/voz_humana_final.mp3');
        await tempFile.writeAsBytes(response.bodyBytes);

        await _audioPlayer.setPlaybackRate(2.0); 
        await _audioPlayer.play(DeviceFileSource(tempFile.path));
        print("Tocando voz de fallback (Google): $mensagem");
      }
    } catch (e) {
      print("Erro crítico no sistema de voz: $e");
    }
  }
}
