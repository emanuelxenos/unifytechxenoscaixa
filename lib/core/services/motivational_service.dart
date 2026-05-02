import 'dart:math';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class MotivationalService {
  static final MotivationalService _instance = MotivationalService._internal();
  factory MotivationalService() => _instance;
  MotivationalService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();

  final List<String> _frases = [
    "Olá {nome}, hoje o dia está incrível! Vamos transformar cada desafio em uma vitória!",
    "Bom dia {nome}! Que bom te ver. Você é o motor desta empresa e hoje vamos brilhar!",
    "Oi {nome}, você é fera demais! Sua energia contagia os clientes e a nossa equipe.",
    "Seja bem-vindo, {nome}. Lembre-se: grandes metas são alcançadas com passos constantes.",
    "Olá {nome}! Preparado para bater recordes hoje? Eu confio plenamente no seu talento!",
    "O sucesso é a soma de pequenos esforços repetidos dia após dia. Vamos pra cima, {nome}!",
    "Você não está apenas operando um caixa, {nome}, está construindo uma carreira de sucesso!",
    "Atenção aos detalhes é o que separa os bons dos excepcionais. E você é excepcional!",
    "Um cliente satisfeito é o nosso melhor marketing. Vamos dar o nosso melhor hoje, {nome}!",
    "Sua dedicação é o que faz a nossa empresa ser gigante. Obrigado por estar aqui, {nome}!",
    "Mantenha o foco, a calma e o sorriso no rosto, {nome}. O resto a gente resolve juntos!",
    "Hoje é o dia perfeito para superar suas próprias marcas! Vamos com tudo!",
    "Acredite em você como nós acreditamos. Você é essencial para o nosso sucesso, {nome}!",
    "Cada venda concluída é um passo a mais na sua evolução profissional. Sucesso hoje!",
    "Trabalhe com alegria e o resultado virá naturalmente. Tenha um dia fantástico, {nome}!",
    "A cada transação, você mostra sua competência. Tenha um dia brilhante, {nome}!",
    "Sua postura profissional é um exemplo para todos. Vamos fazer história hoje!",
    "Não há limites para quem trabalha com propósito. O seu é voar alto, {nome}!",
    "Sorria! O seu atendimento pode mudar o dia de alguém para melhor.",
    "A excelência não é um ato, mas um hábito. Continue sendo incrível, {nome}!",
    "Hoje o movimento será ótimo e sua agilidade será o nosso diferencial!",
    "Confiança é o primeiro segredo do sucesso. Confie no seu potencial, {nome}!",
    "Vamos atender com o coração e vender com a mente. Bom trabalho!",
    "Você é a linha de frente do nosso sucesso. Orgulho de ter você aqui, {nome}!",
    "A disciplina é a ponte entre metas e realizações. Mantenha o foco!",
    "Seja a melhor versão de si mesmo em cada atendimento de hoje!",
    "Sua agilidade no caixa é impressionante. Vamos bater as metas, {nome}!",
    "O trabalho bem feito gera frutos duradouros. Colha o sucesso hoje!",
    "Nossa missão é encantar. E você, {nome}, é mestre nisso!",
    "A cada 'obrigado' de um cliente, sinta a missão cumprida. Vamos lá!",
    "O otimismo é o imã da felicidade. Atraia coisas boas nesta jornada!",
    "Você é resiliente e capaz de superar qualquer correria hoje. Força!",
    "Pequenas gentilezas fazem grandes fidelizações. Encante o próximo cliente!",
    "O conhecimento se adquire com a prática. Cada venda é uma lição, {nome}!",
    "Sua presença ilumina este posto de trabalho. Vamos fazer um dia espetacular!",
    "Transforme o 'não' em 'talvez' e o 'talvez' em venda. Você consegue!",
    "A pressa é inimiga da perfeição, mas a agilidade é amiga do lucro. Use-a!",
    "A gratidão pelo trabalho abre portas para novas oportunidades. Sucesso!",
    "Você é o herói anônimo de cada venda concluída. Parabéns, {nome}!",
    "Encerre o dia com a sensação de dever cumprido e metas batidas!",
    "O mundo pertence aos que se atrevem, {nome}. Ouse vender mais hoje!",
    "Cada cliente é uma nova história. Faça parte da melhor delas!",
    "A persistência é o caminho do êxito. Continue firme, {nome}!",
    "Trabalhe como se o sucesso dependesse apenas de você hoje.",
    "A qualidade do seu trabalho reflete a qualidade da sua mente.",
    "Seja grato por cada venda, pequena ou grande. Todas importam!",
    "A agilidade no atendimento é a marca dos grandes profissionais.",
    "Sua inteligência emocional é sua maior ferramenta no caixa.",
    "Foque na solução, nunca no problema. Você é mestre nisso, {nome}!",
    "Acredite: você é muito mais capaz do que imagina!",
    "O segredo de progredir é começar. Vamos com tudo nessa abertura!",
    "A sua dedicação é o alicerce da nossa empresa. Obrigado, {nome}!",
    "Mantenha o entusiasmo. Você é o cartão de visitas da loja!",
    "O bom atendimento é aquele que deixa saudades no cliente.",
    "Seja a luz que ilumina o dia de quem passa pelo seu caixa.",
    "O fracasso é apenas a oportunidade de começar de novo com inteligência.",
    "Sua competência é o que nos move. Tenha uma jornada incrível!",
    "O sucesso não vem por acaso, vem por preparo e suor. Bom trabalho!",
    "Cada sorriso dado ao cliente volta em dobro para você, {nome}.",
    "A organização do seu espaço reflete a clareza do seu trabalho.",
    "Sua rapidez é um espetáculo à parte. Vamos bater os recordes!",
    "A confiança é a base de qualquer grande venda. Confie em você!",
    "A vida é 10% o que acontece e 90% como você reage. Reaja com vitória!",
    "Você é o protagonista da sua própria história profissional. Brilhe!",
    "Nada é impossível para uma mente determinada. Vá e vença, {nome}!",
    "O entusiasmo é o combustível do sucesso. Mantenha o tanque cheio!",
    "Sua voz transmite confiança. Use-a para encantar e vender.",
    "A cada meta batida, uma nova porta se abre para o seu futuro.",
    "Não espere por oportunidades, crie-as em cada atendimento!",
    "O trabalho em equipe divide a carga e multiplica o sucesso.",
    "Você é um exemplo de resiliência e foco. Continue assim, {nome}!",
    "A maior recompensa pelo trabalho bem feito é a satisfação pessoal.",
    "Transforme a rotina em uma jornada de descobertas e vendas!",
    "A sua simpatia é a nossa melhor estratégia de vendas.",
    "O futuro depende do que fazemos no presente. Faça um grande presente!",
    "Seja obstinado pelos seus sonhos. O trabalho é o caminho.",
    "Sua agilidade economiza o tempo do cliente e gera valor para a loja.",
    "A cada fechamento de venda, sinta o poder da sua competência.",
    "O impossível é apenas uma opinião. Prove o contrário hoje!",
    "Sua dedicação diária é o que constrói o nosso legado, {nome}.",
    "Foque nos seus pontos fortes e minimize as fraquezas. Você é gigante!",
    "A cada 'bom dia' sincero, você constrói uma ponte de confiança.",
    "Não pare até se orgulhar de si mesmo. Estamos orgulhosos de você!",
    "O sucesso é gostar de si mesmo e do que você faz. Ame seu trabalho!",
    "Sua energia renova o nosso ambiente. Obrigado pela parceria, {nome}!",
    "A paciência é uma virtude dos grandes negociadores. Use-a bem.",
    "Cada cliente bem atendido é um tijolo na sua escada de sucesso.",
    "Acredite na força dos seus sonhos e na potência do seu trabalho.",
    "O sucesso é a soma de decisões corretas tomadas sob pressão.",
    "Seja o motivo do sorriso de alguém hoje. Comece pelo caixa!",
    "A sua proatividade resolve problemas antes mesmo deles surgirem.",
    "O trabalho duro supera o talento quando o talento não trabalha duro.",
    "Mantenha a mente aberta e o coração focado na meta. Sucesso!",
    "Você é um ativo valioso para a nossa empresa. Valorize-se, {nome}!",
    "A cada venda adicional, você mostra o seu poder de persuasão.",
    "O segredo do sucesso é a constância do propósito. Siga firme!",
    "Sua agilidade mental é o que te faz ser um operador de elite.",
    "Otimismo não é esperar o melhor, é trabalhar pelo melhor sempre.",
    "A sua ética profissional é o que te diferencia no mercado.",
    "Seja resiliente: os ventos fortes só fazem as raízes serem mais fundas.",
    "O sucesso é o destino de quem não desiste no meio do caminho.",
    "Sua capacidade de aprender rápido é o seu maior superpoder.",
    "A cada atendimento, você planta uma semente de fidelidade.",
    "O bom humor é o tempero que faz o trabalho ser prazeroso.",
    "Você é capaz de lidar com qualquer fluxo de clientes. Confiança!",
    "A excelência é o resultado de se importar mais do que os outros.",
    "Sua trajetória aqui está apenas começando. O céu é o limite!",
    "O foco no cliente é o foco no nosso crescimento mútuo.",
    "Seja um mestre na arte de ouvir o cliente. Ali estão as vendas.",
    "A sua rapidez é sinônimo de eficiência operacional. Parabéns!",
    "O trabalho dignifica o homem e o sucesso premia o esforço.",
    "Sua energia positiva atrai boas vendas e ótimos clientes.",
    "A cada fechamento de caixa, celebre suas conquistas do dia.",
    "Não olhe para o relógio, faça o que ele faz: continue seguindo!",
    "O sucesso é caminhar de erro em erro sem perder o entusiasmo.",
    "Você é a peça que faltava para o nosso time ser invencível, {nome}!",
    "A curiosidade de aprender algo novo hoje vai te levar longe.",
    "Sua atenção evita erros e garante a nossa credibilidade.",
    "Seja audaz em suas metas e humilde em sua busca por aprender.",
    "O trabalho de hoje é o investimento para o seu sucesso de amanhã.",
    "A cada dificuldade superada, você se torna um profissional melhor.",
    "Sua proatividade é o combustível da nossa inovação diária.",
    "O foco na excelência gera resultados extraordinários. Vá e faça!",
    "Você tem o poder de transformar um dia comum em um dia épico!",
    "A sua alegria ao atender é o que faz os clientes voltarem sempre.",
    "O sucesso não é a chave para a felicidade, a felicidade é a chave do sucesso.",
    "Mantenha a calma sob pressão e mostre a sua maestria, {nome}.",
    "A cada venda sugerida, você aumenta o valor do seu trabalho.",
    "O futuro pertence àqueles que acreditam na beleza de seus sonhos.",
    "Você é um guerreiro do dia a dia, {nome}. Respeitamos sua luta!",
    "A agilidade é a cortesia dos reis e a marca dos grandes caixas.",
    "Sua competência técnica é a base do nosso suporte operacional.",
    "O sucesso é a soma de pequenos detalhes executados com perfeição.",
    "Seja a mudança que você quer ver na sua carreira. Comece agora!",
    "Sua dedicação é o ouro da nossa empresa. Continue brilhando!",
    "A cada meta alcançada, sinta o sabor da vitória. Você merece!",
    "O trabalho em equipe faz pessoas comuns alcançarem resultados incomuns.",
    "Sua visão estratégica ajuda a loja a crescer. Pense grande!",
    "O entusiasmo é a maior força da alma. Conserve-o sempre aceso!",
    "Encerre este dia sabendo que você deu o seu melhor. Até amanhã, {nome}!",
  ];

  Future<void> speakMotivational(String nomeOperador) async {
    try {
      final fraseBase = _frases[_random.nextInt(_frases.length)];
      
      // Garante que o nome do operador seja usado na frase sorteada
      String mensagem = fraseBase.replaceAll("{nome}", nomeOperador);
      
      // Sorteio para o "Te amo" (Chance de 20%)
      if (_random.nextInt(100) < 20) {
        mensagem += ". Sabe que eu te amo, né?";
      }

      final encodedMsg = Uri.encodeComponent(mensagem);
      
      // Motor Google Neural de alta disponibilidade - INFALÍVEL
      final url = "https://translate.google.com/translate_tts?ie=UTF-8&q=$encodedMsg&tl=pt-br&client=tw-ob";

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/voz_humana_final.mp3');
        await tempFile.writeAsBytes(response.bodyBytes);

        // O segredo está aqui: Aceleramos e ajustamos o pitch para tirar o tom robótico
        await _audioPlayer.setPlaybackRate(2.0); 
        await _audioPlayer.play(DeviceFileSource(tempFile.path));
        
        print("Tocando voz HUMANA (Google Neural Acelerada): $mensagem");
      } else {
        print("Erro crítico ao buscar voz: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro ao processar voz humana: $e");
    }
  }
}
