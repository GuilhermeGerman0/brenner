// lib/services/url_helper.dart

export 'url_helper_mobile.dart' // Exporta o arquivo mobile por padrão
    if (dart.library.html) 'url_helper_web.dart'; // MAS, se for web, exporta o arquivo web