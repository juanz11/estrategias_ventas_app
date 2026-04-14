import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform, File;

class ApiService {
  static String get baseUrl {
    return 'https://balance.zcdigitalsolutions.com/api';
  }
  
  String? _token;

  // Inicializar y cargar token guardado
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Guardar token
  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Eliminar token
  Future<void> _removeToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Headers con autenticación
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    print('🔵 Intentando login con: $email');
    print('🔵 URL: $baseUrl/login');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('🔵 Status code: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        print('✅ Login exitoso! Token guardado');
        return data;
      } else {
        print('❌ Error en login: ${response.body}');
        throw Exception('Error en login: ${response.body}');
      }
    } catch (e) {
      print('❌ Excepción en login: $e');
      rethrow;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: _headers,
    );
    await _removeToken();
  }

  // OBTENER INGRESOS
  Future<List<dynamic>> getIngresos({
    bool? esPresupuesto,
    int? year,
    int? month,
  }) async {
    String url = '$baseUrl/ingresos';
    List<String> params = [];

    if (esPresupuesto != null) params.add('es_presupuesto=$esPresupuesto');
    if (year != null) params.add('year=$year');
    if (month != null) params.add('month=$month');

    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener ingresos');
    }
  }

  // CREAR INGRESO
  Future<Map<String, dynamic>> createIngreso({
    required String etiqueta,
    required String tipo,
    required double monto,
    required DateTime mes,
    required bool esPresupuesto,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ingresos'),
      headers: _headers,
      body: jsonEncode({
        'etiqueta': etiqueta,
        'tipo': tipo,
        'monto': monto,
        'mes': mes.toIso8601String().split('T')[0],
        'es_presupuesto': esPresupuesto,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear ingreso: ${response.body}');
    }
  }

  // ACTUALIZAR INGRESO
  Future<Map<String, dynamic>> updateIngreso(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/ingresos/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar ingreso');
    }
  }

  // ELIMINAR INGRESO
  Future<void> deleteIngreso(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ingresos/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar ingreso');
    }
  }

  // OBTENER GASTOS
  Future<List<dynamic>> getGastos({
    bool? esPresupuesto,
    String? categoria,
    int? year,
    int? month,
  }) async {
    String url = '$baseUrl/gastos';
    List<String> params = [];

    if (esPresupuesto != null) params.add('es_presupuesto=$esPresupuesto');
    if (categoria != null) params.add('categoria=$categoria');
    if (year != null) params.add('year=$year');
    if (month != null) params.add('month=$month');

    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener gastos');
    }
  }

  // CREAR GASTO (con archivo opcional)
  Future<Map<String, dynamic>> createGasto({
    required String categoria,
    required String subCategoria,
    required double monto,
    required bool esFijo,
    required bool pagoConTarjeta,
    required bool gastoHormiga,
    required String periodicidad,
    required DateTime mes,
    required bool esPresupuesto,
    File? archivo,
  }) async {
    if (archivo != null) {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/gastos'));
      request.headers['Authorization'] = 'Bearer $_token';
      request.headers['Accept'] = 'application/json';
      request.fields['categoria'] = categoria;
      request.fields['sub_categoria'] = subCategoria;
      request.fields['monto'] = monto.toString();
      request.fields['es_fijo'] = esFijo ? '1' : '0';
      request.fields['pago_con_tarjeta'] = pagoConTarjeta ? '1' : '0';
      request.fields['gasto_hormiga'] = gastoHormiga ? '1' : '0';
      request.fields['periodicidad'] = periodicidad;
      request.fields['mes'] = mes.toIso8601String().split('T')[0];
      request.fields['es_presupuesto'] = esPresupuesto ? '1' : '0';
      final ext = archivo.path.split('.').last.toLowerCase();
      final mime = ext == 'pdf' ? 'application/pdf' : 'image/$ext';
      request.files.add(await http.MultipartFile.fromPath('archivo', archivo.path,
          contentType: http.MediaType.parse(mime)));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 201) return jsonDecode(response.body);
      throw Exception('Error al crear gasto: ${response.body}');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/gastos'),
      headers: _headers,
      body: jsonEncode({
        'categoria': categoria,
        'sub_categoria': subCategoria,
        'monto': monto,
        'es_fijo': esFijo,
        'pago_con_tarjeta': pagoConTarjeta,
        'gasto_hormiga': gastoHormiga,
        'periodicidad': periodicidad,
        'mes': mes.toIso8601String().split('T')[0],
        'es_presupuesto': esPresupuesto,
      }),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception('Error al crear gasto: ${response.body}');
  }

  // ACTUALIZAR GASTO
  Future<Map<String, dynamic>> updateGasto(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/gastos/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar gasto');
    }
  }

  // ELIMINAR GASTO
  Future<void> deleteGasto(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/gastos/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar gasto');
    }
  }

  // OBTENER CATEGORIAS
  Future<List<dynamic>> getCategorias() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categorias-gasto'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener categorías');
    }
  }

  // CREAR CATEGORIA
  Future<Map<String, dynamic>> createCategoria(String nombre) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categorias-gasto'),
      headers: _headers,
      body: jsonEncode({'nombre': nombre}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear categoría');
    }
  }

  // ACTUALIZAR CATEGORIA
  Future<Map<String, dynamic>> updateCategoria(int id, String nombre) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categorias-gasto/$id'),
      headers: _headers,
      body: jsonEncode({'nombre': nombre}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar categoría: ${response.body}');
    }
  }

  // ELIMINAR CATEGORIA
  Future<void> deleteCategoria(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/categorias-gasto/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar categoría');
    }
  }

  // OBTENER DEUDAS
  Future<List<dynamic>> getDeudas({String? tipo}) async {
    String url = '$baseUrl/deudas';
    if (tipo != null) url += '?tipo=$tipo';

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener deudas');
    }
  }

  // DEUDAS VENCIDAS HOY
  Future<List<dynamic>> getDeudasVencidasHoy() async {
    final response = await http.get(
      Uri.parse('$baseUrl/deudas-vencidas-hoy'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener deudas vencidas');
    }
  }

  // CREAR DEUDA
  Future<Map<String, dynamic>> createDeuda({
    required String concepto,
    required double monto,
    required DateTime fecha,
    required String tipo,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deudas'),
      headers: _headers,
      body: jsonEncode({
        'concepto': concepto,
        'monto': monto,
        'fecha': fecha.toIso8601String().split('T')[0],
        'tipo': tipo,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear deuda: ${response.body}');
    }
  }

  // ACTUALIZAR DEUDA
  Future<Map<String, dynamic>> updateDeuda(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/deudas/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar deuda');
    }
  }

  // ELIMINAR DEUDA
  Future<void> deleteDeuda(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deudas/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar deuda');
    }
  }

  // SUBIR ARCHIVO A GASTO (PUT con multipart)
  Future<Map<String, dynamic>> subirArchivoGasto(int gastoId, File archivo,
      {Map<String, dynamic>? extraFields}) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/gastos/$gastoId'));
    request.headers['Authorization'] = 'Bearer $_token';
    request.headers['Accept'] = 'application/json';
    request.fields['_method'] = 'PUT';

    if (extraFields != null) {
      extraFields.forEach((k, v) {
        if (v != null) request.fields[k] = v.toString();
      });
    }

    final ext = archivo.path.split('.').last.toLowerCase();
    final mime = ext == 'pdf' ? 'application/pdf' : 'image/$ext';
    request.files.add(await http.MultipartFile.fromPath('archivo', archivo.path,
        contentType: http.MediaType.parse(mime)));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al subir archivo: ${response.body}');
  }

  // ELIMINAR ARCHIVO DE GASTO
  Future<Map<String, dynamic>> eliminarArchivoGasto(int gastoId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/gastos/$gastoId/archivo'),
      headers: _headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al eliminar archivo');
  }

  // SUBIR ARCHIVO A DEUDA
  Future<Map<String, dynamic>> subirArchivoDeuda(int deudaId, File archivo) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/deudas/$deudaId'),
    );

    request.headers['Authorization'] = 'Bearer $_token';
    request.headers['Accept'] = 'application/json';
    request.fields['_method'] = 'PUT'; // Laravel method spoofing

    final extension = archivo.path.split('.').last.toLowerCase();
    final mimeType = ['pdf'].contains(extension) ? 'application/pdf' : 'image/$extension';

    request.files.add(await http.MultipartFile.fromPath(
      'archivo',
      archivo.path,
      contentType: http.MediaType.parse(mimeType),
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al subir archivo: ${response.body}');
    }
  }

  // ELIMINAR ARCHIVO DE DEUDA
  Future<Map<String, dynamic>> eliminarArchivoDeuda(int deudaId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deudas/$deudaId/archivo'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al eliminar archivo');
    }
  }
}
